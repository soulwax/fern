extends CharacterBody3D
class_name PlayerController

signal interacted_with(target: Node)
signal prompt_changed(prompt_text: String)

@export_group("Movement")
@export var walk_speed: float = 3.2
@export var sprint_speed: float = 5.6
@export var crouch_speed: float = 1.8
@export var jump_velocity: float = 4.0
@export var acceleration: float = 10.0
@export var friction: float = 12.0
@export var gravity: float = 12.0

@export_group("Look")
@export var mouse_sensitivity: float = 0.0022
@export var min_pitch: float = -85.0
@export var max_pitch: float = 85.0

@export_group("Headbob")
@export var headbob_enabled: bool = true
@export var headbob_frequency: float = 2.4
@export var headbob_amplitude: float = 0.04

@export_group("Interaction")
@export var interact_distance: float = 2.8

# Node references
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var hand_socket: Node3D = $Head/Camera3D/HandSocket
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# Internal state
var is_sprinting: bool = false
var is_crouching: bool = false
var headbob_time: float = 0.0
var original_cam_y: float = 0.0
var step_cycle_dist: float = 0.0
var step_interval: float = 1.7
var current_prompt: String = ""

# Current interactable focused
var current_interactable: Node = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera:
		original_cam_y = camera.position.y
	_ensure_input_mappings()

func _ensure_input_mappings() -> void:
	var actions = {
		"move_forward": [KEY_W, KEY_UP],
		"move_backward": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"sprint": [KEY_SHIFT],
		"crouch": [KEY_CTRL, KEY_C],
		"jump": [KEY_SPACE],
		"interact": [KEY_E],
		"flower_cup": [KEY_R],
		"flower_toggle": [KEY_F, MOUSE_BUTTON_LEFT]
	}
	
	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			for key_code in actions[action_name]:
				if key_code is Key:
					var event = InputEventKey.new()
					event.physical_keycode = key_code
					InputMap.action_add_event(action_name, event)
				elif key_code is MouseButton:
					var m_event = InputEventMouseButton.new()
					m_event.button_index = key_code
					InputMap.action_add_event(action_name, m_event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump") and not is_crouching:
		velocity.y = jump_velocity

	# Crouch state
	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching
	
	# Determine target speed
	var target_speed = walk_speed
	if is_crouching:
		target_speed = crouch_speed
	elif is_sprinting:
		target_speed = sprint_speed

	# Movement input
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	input_dir = input_dir.normalized()

	# Transform input direction relative to player orientation
	var wish_dir = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if wish_dir != Vector3.ZERO:
		velocity.x = lerp(velocity.x, wish_dir.x * target_speed, delta * acceleration)
		velocity.z = lerp(velocity.z, wish_dir.z * target_speed, delta * acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * friction)
		velocity.z = lerp(velocity.z, 0.0, delta * friction)

	move_and_slide()
	
	# Headbob & Footstep cycle
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horizontal_speed > 0.3:
		step_cycle_dist += horizontal_speed * delta
		if step_cycle_dist >= step_interval:
			step_cycle_dist = 0.0
			_trigger_footstep()
			
		if headbob_enabled:
			headbob_time += delta * horizontal_speed * headbob_frequency
			camera.position.y = original_cam_y + sin(headbob_time) * headbob_amplitude
			camera.position.x = cos(headbob_time * 0.5) * (headbob_amplitude * 0.6)
	else:
		if headbob_enabled:
			camera.position.y = lerp(camera.position.y, original_cam_y, delta * 8.0)
			camera.position.x = lerp(camera.position.x, 0.0, delta * 8.0)

	_check_interaction()

func _trigger_footstep() -> void:
	if footstep_player and footstep_player.stream:
		footstep_player.pitch_scale = randf_range(0.92, 1.08)
		footstep_player.play()

func _check_interaction() -> void:
	if not interact_ray:
		return
		
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		# Traverse up to find an interactable node if collider is a child
		var interactable = _find_interactable(collider)
		if interactable != current_interactable:
			current_interactable = interactable
			if current_interactable and current_interactable.has_method("get_interaction_prompt"):
				var prompt = current_interactable.get_interaction_prompt()
				_set_prompt(prompt)
			elif current_interactable:
				_set_prompt("[E] Interact")
			else:
				_set_prompt("")
		
		if current_interactable and Input.is_action_just_pressed("interact"):
			if current_interactable.has_method("interact"):
				current_interactable.interact(self)
				interacted_with.emit(current_interactable)
	else:
		if current_interactable != null:
			current_interactable = null
			_set_prompt("")

func _find_interactable(node: Node) -> Node:
	var curr = node
	while curr and curr != get_tree().root:
		if curr.is_in_group("interactable") or curr.has_method("interact"):
			return curr
		curr = curr.get_parent()
	return null

func _set_prompt(text: String) -> void:
	if current_prompt != text:
		current_prompt = text
		prompt_changed.emit(current_prompt)
