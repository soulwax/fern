extends CharacterBody3D
class_name WraithAI

signal state_changed(new_state: int)
signal wraith_spotted(uv_ratio: float)
signal player_caught()

enum State {
	PROWL,        # Patrolling rafters and distant corners
	STALK,        # Stealthily creeping toward player
	HUNT,         # Aggressive charge when player is in dark or vulnerable
	STUNNED,      # Hit by grindstone sparks, disoriented
	REPELLED,     # Driven back by prolonged UV bloom or iron chime
	BANISHED      # Dawn arrives, dissolved
}

@export_group("Speeds")
@export var prowl_speed: float = 2.0
@export var stalk_speed: float = 3.2
@export var hunt_speed: float = 6.2
@export var flee_speed: float = 7.0

@export_group("Sensory & Vulnerability")
@export var uv_recoil_threshold: float = 1.6 # Seconds of continuous UV to force retreat
@export var kill_distance: float = 1.4

@onready var visual_mesh: Node3D = $Visuals
@onready var body_mesh: MeshInstance3D = $Visuals/BodyMesh
@onready var antler_mesh: Node3D = $Visuals/Antlers
@onready var ember_particles: GPUParticles3D = $Visuals/EmberParticles
@onready var hoof_audio: AudioStreamPlayer3D = $Audio/HoofCrunchAudio
@onready var growl_audio: AudioStreamPlayer3D = $Audio/GrowlAudio
@onready var screech_audio: AudioStreamPlayer3D = $Audio/ScreechAudio
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# AI State
var current_state: State = State.PROWL
var state_timer: float = 0.0
var player_ref: Node3D = null

# Sensory & Reveal timers
var uv_exposure_timer: float = 0.0
var uv_decay_timer: float = 0.0
var spark_ignite_timer: float = 0.0
var is_visible_to_player: bool = false

# Footstep tracking
var step_dist_accumulator: float = 0.0
var step_stride: float = 1.3
var patrol_waypoints: Array[Vector3] = []
var current_target_point: Vector3 = Vector3.ZERO

# Hoofprint decal scene
var hoofprint_scene: PackedScene = preload("res://Scenes/Monster/HoofprintDecal.tscn")

func _ready() -> void:
	add_to_group("unseen_entity")
	_find_player()
	_generate_initial_waypoints()
	_update_visual_reveal(0.0)

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _generate_initial_waypoints() -> void:
	# Default patrol spots around the workshop
	patrol_waypoints = [
		Vector3(-6.0, 0.5, -4.0),
		Vector3(6.0, 0.5, -4.0),
		Vector3(-5.0, 0.5, 4.0),
		Vector3(5.0, 0.5, 4.0),
		Vector3(0.0, 0.5, -6.5),
		Vector3(0.0, 0.5, 6.0)
	]
	_pick_next_waypoint()

func _pick_next_waypoint() -> void:
	if patrol_waypoints.size() > 0:
		current_target_point = patrol_waypoints.pick_random()

func _physics_process(delta: float) -> void:
	if current_state == State.BANISHED:
		return

	if not player_ref:
		_find_player()

	_handle_sensory_decay(delta)
	
	match current_state:
		State.PROWL:
			_process_prowl(delta)
		State.STALK:
			_process_stalk(delta)
		State.HUNT:
			_process_hunt(delta)
		State.STUNNED:
			_process_stunned(delta)
		State.REPELLED:
			_process_repelled(delta)

	move_and_slide()
	_handle_footstep_effects(delta)

func _process_prowl(delta: float) -> void:
	state_timer -= delta
	var to_target = current_target_point - global_position
	to_target.y = 0.0
	
	if to_target.length() < 1.0 or state_timer <= 0.0:
		_pick_next_waypoint()
		state_timer = randf_range(4.0, 8.0)
		if player_ref and randf() < 0.4:
			set_state(State.STALK)
			return

	var move_dir = to_target.normalized()
	velocity.x = move_dir.x * prowl_speed
	velocity.z = move_dir.z * prowl_speed
	if move_dir != Vector3.ZERO:
		look_at(global_position + move_dir, Vector3.UP)

func _process_stalk(delta: float) -> void:
	state_timer -= delta
	if not player_ref:
		set_state(State.PROWL)
		return
		
	var to_player = player_ref.global_position - global_position
	to_player.y = 0.0
	var dist = to_player.length()
	
	if dist <= kill_distance:
		player_caught.emit()
		return
		
	if dist < 4.0 and randf() < 0.02:
		# Growl in proximity
		_play_growl()
		set_state(State.HUNT)
		return
		
	if state_timer <= 0.0:
		set_state(State.PROWL)
		return

	var move_dir = to_player.normalized()
	velocity.x = move_dir.x * stalk_speed
	velocity.z = move_dir.z * stalk_speed
	if move_dir != Vector3.ZERO:
		look_at(global_position + move_dir, Vector3.UP)

func _process_hunt(delta: float) -> void:
	if not player_ref:
		set_state(State.PROWL)
		return
		
	var to_player = player_ref.global_position - global_position
	to_player.y = 0.0
	var dist = to_player.length()
	
	if dist <= kill_distance:
		player_caught.emit()
		return
		
	var move_dir = to_player.normalized()
	velocity.x = move_dir.x * hunt_speed
	velocity.z = move_dir.z * hunt_speed
	if move_dir != Vector3.ZERO:
		look_at(global_position + move_dir, Vector3.UP)

func _process_stunned(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 15.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 15.0 * delta)
	state_timer -= delta
	if state_timer <= 0.0:
		set_state(State.REPELLED)

func _process_repelled(delta: float) -> void:
	state_timer -= delta
	if player_ref:
		var away_from_player = global_position - player_ref.global_position
		away_from_player.y = 0.0
		var move_dir = away_from_player.normalized()
		velocity.x = move_dir.x * flee_speed
		velocity.z = move_dir.z * flee_speed
		if move_dir != Vector3.ZERO:
			look_at(global_position + move_dir, Vector3.UP)
			
	if state_timer <= 0.0:
		set_state(State.PROWL)

func set_state(new_state: State) -> void:
	current_state = new_state
	state_changed.emit(current_state)
	match new_state:
		State.PROWL:
			state_timer = randf_range(5.0, 10.0)
		State.STALK:
			state_timer = randf_range(8.0, 14.0)
		State.HUNT:
			state_timer = 6.0
			_play_growl()
		State.STUNNED:
			_play_screech()
		State.REPELLED:
			state_timer = 4.0

func expose_to_uv_light(source: Node) -> void:
	uv_decay_timer = 0.35 # Keep reveal alive while being hit
	uv_exposure_timer += get_process_delta_time()
	var ratio = clamp(uv_exposure_timer / 0.8, 0.0, 1.0)
	_update_visual_reveal(ratio)
	wraith_spotted.emit(ratio)
	
	# Prolonged UV exposure forces wraith retreat
	if uv_exposure_timer >= uv_recoil_threshold and current_state != State.REPELLED and current_state != State.STUNNED:
		_play_screech()
		set_state(State.REPELLED)

func ignite_with_sparks(duration: float) -> void:
	spark_ignite_timer = duration
	if ember_particles:
		ember_particles.emitting = true
	_update_visual_reveal(1.0)
	set_state(State.STUNNED)
	state_timer = duration

func repel_by_holy_runes() -> void:
	_play_screech()
	set_state(State.REPELLED)

func banish() -> void:
	current_state = State.BANISHED
	velocity = Vector3.ZERO
	_play_screech()
	# Fade out visuals
	var tween = create_tween()
	tween.tween_property(visual_mesh, "scale", Vector3.ZERO, 2.5)
	await tween.finished
	queue_free()

func _handle_sensory_decay(delta: float) -> void:
	if uv_decay_timer > 0.0:
		uv_decay_timer -= delta
	else:
		uv_exposure_timer = max(0.0, uv_exposure_timer - delta * 1.5)
		
	if spark_ignite_timer > 0.0:
		spark_ignite_timer -= delta
		if spark_ignite_timer <= 0.0 and ember_particles:
			ember_particles.emitting = false

	var reveal_ratio = clamp(max(uv_exposure_timer / 0.8, (1.0 if spark_ignite_timer > 0.0 else 0.0)), 0.0, 1.0)
	_update_visual_reveal(reveal_ratio)

func _update_visual_reveal(ratio: float) -> void:
	if body_mesh and body_mesh.get_surface_override_material(0):
		var mat = body_mesh.get_surface_override_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("reveal_amount", ratio)
		elif mat is StandardMaterial3D:
			# Adjust transparency / rim glow
			mat.albedo_color.a = lerp(0.05, 0.95, ratio)
			mat.emission_energy_multiplier = lerp(0.0, 3.0, ratio)
			
	if antler_mesh:
		antler_mesh.visible = (ratio > 0.15)

func _handle_footstep_effects(delta: float) -> void:
	var horiz_vel = Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horiz_vel > 0.3:
		step_dist_accumulator += horiz_vel * delta
		if step_dist_accumulator >= step_stride:
			step_dist_accumulator = 0.0
			_spawn_hoofprint()
			_play_hoof_crunch()

func _spawn_hoofprint() -> void:
	if not hoofprint_scene:
		return
	var print_inst = hoofprint_scene.instantiate()
	get_parent().add_child(print_inst)
	print_inst.global_position = Vector3(global_position.x, 0.02, global_position.z)
	print_inst.rotation.y = rotation.y

func _play_hoof_crunch() -> void:
	if hoof_audio and not hoof_audio.playing:
		hoof_audio.pitch_scale = randf_range(0.85, 1.15)
		hoof_audio.play()

func _play_growl() -> void:
	if growl_audio and not growl_audio.playing:
		growl_audio.pitch_scale = randf_range(0.8, 1.0)
		growl_audio.play()

func _play_screech() -> void:
	if screech_audio:
		screech_audio.pitch_scale = randf_range(0.9, 1.1)
		screech_audio.play()
