extends CharacterBody3D
class_name WraithAI

signal state_changed(new_state: int)
signal wraith_spotted(uv_ratio: float)
signal player_caught()
signal floorboard_creaked(position: Vector3, is_rafter: bool)

enum State {
	PROWL,        # Patrolling rafters and distant corners
	STALK,        # Stealthily creeping toward player
	HUNT,         # Aggressive charge when player is in dark or vulnerable
	STUNNED,      # Hit by grindstone sparks, disoriented
	REPELLED,     # Driven back by prolonged UV bloom or iron chime
	BANISHED,     # Dawn arrives, dissolved
	SIEGE,        # Rattling and assaulting an exterior window
	APPEASED      # Feeding on Das Opferbrot bread offering
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
@onready var floor_creak_audio: AudioStreamPlayer3D = get_node_or_null("Audio/FloorCreakAudio")
@onready var shingle_gale_audio: AudioStreamPlayer3D = get_node_or_null("Audio/ShingleGaleAudio")
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# AI State
var current_state: State = State.PROWL
var state_timer: float = 0.0
var creak_timer: float = 4.0
var shingle_timer: float = 5.0
var target_offering: Node = null
var player_ref: Node3D = null

# Sensory & Reveal timers
var uv_exposure_timer: float = 0.0
var uv_decay_timer: float = 0.0
var spark_ignite_timer: float = 0.0
var is_visible_to_player: bool = false
var window_siege_cooldown: float = 30.0
var target_window: Node3D = null
var rafter_denial_timer: float = 0.0
var scent_mask_timer: float = 0.0
var slow_timer: float = 0.0
var slow_multiplier: float = 1.0


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
	_update_visual_reveal(0.0, 0.0)

func set_rafter_denial(duration: float) -> void:
	rafter_denial_timer = duration
	if current_target_point.y > 2.0:
		_pick_next_waypoint()

func set_scent_masked(duration: float) -> void:
	scent_mask_timer = duration
	if current_state == State.STALK:
		set_state(State.PROWL)

func apply_movement_slow(multiplier: float, duration: float) -> void:
	slow_multiplier = clamp(multiplier, 0.1, 1.0)
	slow_timer = duration

func _find_player() -> void:
	if not is_inside_tree():
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _generate_initial_waypoints() -> void:
	# Default patrol spots around the workshop floor and upper rafters
	patrol_waypoints = [
		Vector3(-6.0, 0.5, -4.0),
		Vector3(6.0, 0.5, -4.0),
		Vector3(-5.0, 0.5, 4.0),
		Vector3(5.0, 0.5, 4.0),
		Vector3(0.0, 0.5, -6.5),
		Vector3(0.0, 0.5, 6.0),
		Vector3(-2.5, 3.4, 0.0),
		Vector3(2.5, 3.4, 1.2)
	]
	_pick_next_waypoint()

func _pick_next_waypoint() -> void:
	if patrol_waypoints.size() > 0:
		var available = patrol_waypoints
		if rafter_denial_timer > 0.0:
			available = []
			for wp in patrol_waypoints:
				if wp.y < 2.0:
					available.append(wp)
		if available.size() > 0:
			current_target_point = available.pick_random()
		else:
			current_target_point = patrol_waypoints[0]

func _physics_process(delta: float) -> void:
	if current_state == State.BANISHED:
		return

	if not player_ref:
		_find_player()

	_handle_sensory_decay(delta)
	
	if rafter_denial_timer > 0.0:
		rafter_denial_timer -= delta
		var cur_y = global_position.y if is_inside_tree() else position.y
		if cur_y > 2.0:
			velocity.y = -4.0
	
	if scent_mask_timer > 0.0:
		scent_mask_timer -= delta
	
	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_multiplier = 1.0
	
	if current_state == State.PROWL or current_state == State.STALK:
		window_siege_cooldown -= delta
		if window_siege_cooldown <= 0.0 and current_state == State.PROWL:
			_attempt_window_siege()
	
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
		State.SIEGE:
			_process_siege(delta)
		State.APPEASED:
			_process_appeased(delta)

	move_and_slide()
	_handle_footstep_effects(delta)
	
	# Floorboard and rafter timber stress creaks
	creak_timer -= delta
	if creak_timer <= 0.0:
		if velocity.length() > 0.3:
			trigger_floor_creak()
		creak_timer = randf_range(4.5, 7.5)

	# Roof shingle gale vibration when traversing upper rafters
	var cur_pos = global_position if is_inside_tree() else position
	if cur_pos.y > 2.8 and velocity.length() > 0.4:
		shingle_timer -= delta
		if shingle_timer <= 0.0:
			if not shingle_gale_audio:
				shingle_gale_audio = get_node_or_null("Audio/ShingleGaleAudio")
			if shingle_gale_audio and is_inside_tree():
				shingle_gale_audio.pitch_scale = randf_range(0.92, 1.08)
				shingle_gale_audio.play()
			shingle_timer = randf_range(5.0, 9.0)

func trigger_floor_creak() -> void:
	if not floor_creak_audio:
		floor_creak_audio = get_node_or_null("Audio/FloorCreakAudio")
	var current_pos = global_position if is_inside_tree() else position
	var is_rafter = current_pos.y > 2.8
	if floor_creak_audio and is_inside_tree():
		if is_rafter:
			floor_creak_audio.pitch_scale = randf_range(1.15, 1.28)
		else:
			floor_creak_audio.pitch_scale = randf_range(0.88, 1.02)
		floor_creak_audio.play()
	floorboard_creaked.emit(current_pos, is_rafter)

func _find_active_bread_offering() -> Node:
	if not is_inside_tree():
		return null
	var stations = get_tree().get_nodes_in_group("bread_offering_station")
	for s in stations:
		if is_instance_valid(s) and s.get("is_offering_active") == true and not s.get("is_being_consumed"):
			var cur_p = global_position if is_inside_tree() else position
			var st_p = s.global_position if s.is_inside_tree() else s.position
			var d = cur_p.distance_to(st_p)
			if d <= 14.0:
				return s
	return null

func _check_and_divert_to_bread_offering() -> bool:
	if target_offering == null or not is_instance_valid(target_offering) or not target_offering.get("is_offering_active"):
		target_offering = _find_active_bread_offering()
	
	if target_offering and is_instance_valid(target_offering) and target_offering.get("is_offering_active"):
		var cur_p = global_position if is_inside_tree() else position
		var off_p = target_offering.global_position if target_offering.is_inside_tree() else target_offering.position
		var to_off = off_p - cur_p
		to_off.y = 0.0
		var dist = to_off.length()
		if dist <= 1.6:
			set_state(State.APPEASED)
			return true
		var move_dir = to_off.normalized()
		velocity.x = move_dir.x * stalk_speed * slow_multiplier
		velocity.z = move_dir.z * stalk_speed * slow_multiplier
		if move_dir != Vector3.ZERO and is_inside_tree():
			look_at(global_position + move_dir, Vector3.UP)
		return true
	return false

func _process_prowl(delta: float) -> void:
	state_timer -= delta
	
	if _check_and_divert_to_bread_offering():
		return
	
	# Check if arriving at target window
	if target_window and is_instance_valid(target_window):
		var to_win = target_window.global_position - global_position
		to_win.y = 0.0
		if to_win.length() <= 2.2:
			set_state(State.SIEGE)
			return
			
	var to_target = current_target_point - global_position
	to_target.y = 0.0
	
	if to_target.length() < 1.0 or state_timer <= 0.0:
		_pick_next_waypoint()
		state_timer = randf_range(4.0, 8.0)
		if player_ref and randf() < 0.4:
			set_state(State.STALK)
			return

	var move_dir = to_target.normalized()
	velocity.x = move_dir.x * prowl_speed * slow_multiplier
	velocity.z = move_dir.z * prowl_speed * slow_multiplier
	if move_dir != Vector3.ZERO:
		look_at(global_position + move_dir, Vector3.UP)

func _process_stalk(delta: float) -> void:
	state_timer -= delta
	
	if _check_and_divert_to_bread_offering():
		return
		
	if not player_ref or scent_mask_timer > 0.0:
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
	velocity.x = move_dir.x * stalk_speed * slow_multiplier
	velocity.z = move_dir.z * stalk_speed * slow_multiplier
	if move_dir != Vector3.ZERO:
		look_at(global_position + move_dir, Vector3.UP)

func _process_hunt(delta: float) -> void:
	if _check_and_divert_to_bread_offering():
		return
		
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
	velocity.x = move_dir.x * hunt_speed * slow_multiplier
	velocity.z = move_dir.z * hunt_speed * slow_multiplier
	if move_dir != Vector3.ZERO:
		look_at(global_position + move_dir, Vector3.UP)

func _process_appeased(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	state_timer -= delta
	
	if target_offering and is_instance_valid(target_offering):
		if target_offering.has_method("start_consumption") and not target_offering.is_being_consumed:
			target_offering.start_consumption()
		var cur_p = global_position if is_inside_tree() else position
		var off_p = target_offering.global_position if target_offering.is_inside_tree() else target_offering.position
		var to_off = off_p - cur_p
		to_off.y = 0.0
		if to_off != Vector3.ZERO and is_inside_tree():
			look_at(global_position + to_off.normalized(), Vector3.UP)
			
	if state_timer <= 0.0:
		if target_offering and is_instance_valid(target_offering):
			if target_offering.has_method("finish_consumption"):
				target_offering.finish_consumption()
		target_offering = null
		set_state(State.PROWL)

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

func _process_siege(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	state_timer -= delta
	
	if not target_window or not is_instance_valid(target_window):
		set_state(State.PROWL)
		return
		
	var to_win = target_window.global_position - global_position
	to_win.y = 0.0
	if to_win != Vector3.ZERO:
		look_at(global_position + to_win.normalized(), Vector3.UP)
		
	if state_timer <= 0.0:
		if target_window.has_method("breach_plank"):
			target_window.breach_plank()
		_play_growl()
		target_window = null
		window_siege_cooldown = randf_range(35.0, 55.0)
		set_state(State.PROWL)

func _attempt_window_siege() -> void:
	var windows = get_tree().get_nodes_in_group("window_breach")
	var candidates: Array = []
	for w in windows:
		if w is WindowBreach and w.current_planks > 0:
			candidates.append(w)
	if candidates.size() > 0:
		target_window = candidates.pick_random()
		current_target_point = target_window.global_position
		window_siege_cooldown = 45.0

func set_state(new_state: State) -> void:
	if current_state == State.SIEGE and new_state != State.SIEGE:
		if target_window and target_window.has_method("stop_rattle"):
			target_window.stop_rattle()

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
		State.SIEGE:
			state_timer = 4.0
			if target_window and target_window.has_method("start_rattle"):
				target_window.start_rattle(4.0)
		State.APPEASED:
			state_timer = 18.0
			if target_offering and is_instance_valid(target_offering):
				if target_offering.has_method("start_consumption"):
					target_offering.start_consumption()

func expose_to_uv_light(source: Node) -> void:
	uv_decay_timer = 0.35 # Keep reveal alive while being hit
	var dt = get_process_delta_time()
	if dt <= 0.0:
		dt = 0.05
	uv_exposure_timer += dt
	var ratio = clamp(uv_exposure_timer / 0.8, 0.0, 1.0)
	var ember_ratio = clamp(spark_ignite_timer / 2.0, 0.0, 1.0)
	_update_visual_reveal(ratio, ember_ratio)
	wraith_spotted.emit(ratio)
	
	# If currently feeding on an offering, UV light immediately interrupts and repels
	if current_state == State.APPEASED:
		if target_offering and is_instance_valid(target_offering):
			if target_offering.has_method("interrupt_consumption"):
				target_offering.interrupt_consumption()
		target_offering = null
		_play_screech()
		set_state(State.REPELLED)
		return

	# If currently sieging a window, UV light immediately drives the wraith away
	if current_state == State.SIEGE:
		if target_window and target_window.has_method("stop_rattle"):
			target_window.stop_rattle()
		target_window = null
		window_siege_cooldown = randf_range(40.0, 60.0)
		_play_screech()
		set_state(State.REPELLED)
		return
	
	# Prolonged UV exposure forces wraith retreat
	if uv_exposure_timer >= uv_recoil_threshold and current_state != State.REPELLED and current_state != State.STUNNED:
		_play_screech()
		set_state(State.REPELLED)


func ignite_with_sparks(duration: float) -> void:
	spark_ignite_timer = duration
	if ember_particles:
		ember_particles.emitting = true
	_play_screech()
	_update_visual_reveal(1.0, 1.0)
	set_state(State.STUNNED)
	state_timer = duration

func repel_by_holy_runes() -> void:
	_play_screech()
	set_state(State.REPELLED)

func repel_by_horseshoe(ward_pos: Vector3) -> void:
	_play_screech()
	var current_pos = global_position if is_inside_tree() else position
	var push_dir = (current_pos - ward_pos)
	push_dir.y = 0.0
	if push_dir.length_squared() < 0.01:
		push_dir = Vector3(0, 0, -1)
	velocity = push_dir.normalized() * 6.5
	set_state(State.REPELLED)
	state_timer = 3.5

func repel_by_torch(torch_pos: Vector3) -> void:
	_play_screech()
	var current_pos = global_position if is_inside_tree() else position
	var push_dir = (current_pos - torch_pos)
	push_dir.y = 0.0
	if push_dir.length_squared() < 0.01:
		push_dir = Vector3(0, 0, -1)
	velocity = push_dir.normalized() * 7.5
	set_state(State.REPELLED)
	state_timer = 4.0

func repel_by_hearth_bellows(hearth_pos: Vector3, duration: float = 4.0) -> void:
	_play_screech()
	var current_pos = global_position if is_inside_tree() else position
	var push_dir = (current_pos - hearth_pos)
	push_dir.y = 0.0
	if push_dir.length_squared() < 0.01:
		push_dir = Vector3(0, 0, -1)
	velocity = push_dir.normalized() * 7.0
	set_state(State.REPELLED)
	state_timer = duration

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

	var uv_ratio = clamp(uv_exposure_timer / 0.8, 0.0, 1.0)
	var ember_ratio = clamp(spark_ignite_timer / 2.0, 0.0, 1.0)
	_update_visual_reveal(uv_ratio, ember_ratio)

func _update_visual_reveal(ratio: float, ember_ratio: float = 0.0) -> void:
	if not body_mesh:
		body_mesh = get_node_or_null("Visuals/BodyMesh")
	if not antler_mesh:
		antler_mesh = get_node_or_null("Visuals/Antlers")
		
	if body_mesh and body_mesh.get_surface_override_material(0):
		var mat = body_mesh.get_surface_override_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("reveal_amount", ratio)
			mat.set_shader_parameter("ember_amount", ember_ratio)
		elif mat is StandardMaterial3D:
			# Adjust transparency / rim glow
			var combined = max(ratio, ember_ratio)
			mat.albedo_color.a = lerp(0.05, 0.95, combined)
			mat.emission_energy_multiplier = lerp(0.0, 3.5, combined)
			
	if antler_mesh:
		antler_mesh.visible = (ratio > 0.15 or ember_ratio > 0.1)



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
	if hoof_audio and not hoof_audio.playing and is_inside_tree():
		hoof_audio.pitch_scale = randf_range(0.85, 1.15)
		hoof_audio.play()

func _play_growl() -> void:
	if growl_audio and not growl_audio.playing and is_inside_tree():
		growl_audio.pitch_scale = randf_range(0.8, 1.0)
		growl_audio.play()

func _play_screech() -> void:
	if screech_audio and is_inside_tree():
		screech_audio.pitch_scale = randf_range(0.9, 1.1)
		screech_audio.play()
