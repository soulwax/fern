extends "res://Scripts/Workshop/Interactable.gd"
class_name WindowBreach

signal fortified(status: bool)
signal breached(current_planks: int)
signal rattle_started()
signal rattle_stopped()
signal latch_secured()
signal latch_battered(health_left: int)

@export var max_planks: int = 3
@export var current_planks: int = 2 # Starts at 2/3 planks
@export var max_latch_health: int = 2

@onready var window_frame: Node3D = $WindowFrame
@onready var plank_visual_1: Node3D = $Planks/Plank1
@onready var plank_visual_2: Node3D = $Planks/Plank2
@onready var plank_visual_3: Node3D = $Planks/Plank3
@onready var hammer_audio: AudioStreamPlayer3D = $HammerAudio
@onready var rattle_audio: AudioStreamPlayer3D = $RattleAudio
@onready var draft_audio: AudioStreamPlayer3D = $DraftAudio
@onready var latch_mesh: Node3D = $LatchBar
@onready var latch_audio: AudioStreamPlayer3D = $LatchAudio
@onready var frost_overlay: MeshInstance3D = get_node_or_null("FrostOverlay")

var is_rattling: bool = false
var rattle_timer: float = 0.0
var base_frame_pos: Vector3 = Vector3.ZERO
var current_frost_alpha: float = 0.0

# Drop-latch state
var is_latched: bool = true
var latch_health: int = 2

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	if window_frame:
		base_frame_pos = window_frame.position
	latch_health = max_latch_health
	_update_visuals()
	_update_draft()

func _ensure_nodes() -> void:
	if not window_frame:
		window_frame = get_node_or_null("WindowFrame")
	if not plank_visual_1:
		plank_visual_1 = get_node_or_null("Planks/Plank1")
	if not plank_visual_2:
		plank_visual_2 = get_node_or_null("Planks/Plank2")
	if not plank_visual_3:
		plank_visual_3 = get_node_or_null("Planks/Plank3")
	if not hammer_audio:
		hammer_audio = get_node_or_null("HammerAudio")
	if not rattle_audio:
		rattle_audio = get_node_or_null("RattleAudio")
	if not draft_audio:
		draft_audio = get_node_or_null("DraftAudio")
	if not latch_mesh:
		latch_mesh = get_node_or_null("LatchBar")
	if not latch_audio:
		latch_audio = get_node_or_null("LatchAudio")
	if not frost_overlay:
		frost_overlay = get_node_or_null("FrostOverlay")

func _process(delta: float) -> void:
	_ensure_nodes()
	_update_frost_ingress(delta)
	if is_rattling:
		rattle_timer -= delta
		# Shudder vibration on the frame
		if window_frame:
			var jitter_x = randf_range(-0.03, 0.03)
			var jitter_y = randf_range(-0.02, 0.02)
			window_frame.position = base_frame_pos + Vector3(jitter_x, jitter_y, 0.0)
		
		# Jitter the drop-latch bar
		if latch_mesh and is_latched:
			latch_mesh.rotation_degrees.z = randf_range(-4.0, 4.0)

		if rattle_timer <= 0.0:
			stop_rattle()

func _update_frost_ingress(delta: float) -> void:
	if not is_inside_tree():
		return
	var wraiths := _unseen_entities()
	var target_frost: float = 0.0
	for w in wraiths:
		if is_instance_valid(w):
			var cur_p = global_position if is_inside_tree() else position
			var wr_p = w.global_position if w.is_inside_tree() else w.position
			var d = cur_p.distance_to(wr_p)
			if d < 6.5:
				var intensity = clamp((6.5 - d) / 5.0, 0.0, 1.0)
				target_frost = max(target_frost, intensity)
	current_frost_alpha = move_toward(current_frost_alpha, target_frost, delta * 0.45)
	if frost_overlay:
		frost_overlay.visible = current_frost_alpha > 0.01
		var mat = frost_overlay.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.albedo_color.a = current_frost_alpha * 0.85

func start_rattle(duration: float = 3.5) -> void:
	_ensure_nodes()
	is_rattling = true
	rattle_timer = duration
	if rattle_audio and not rattle_audio.playing:
		rattle_audio.pitch_scale = randf_range(0.92, 1.08)
		rattle_audio.play()
	if is_latched and latch_audio and is_inside_tree():
		latch_audio.pitch_scale = randf_range(0.95, 1.05)
		latch_audio.play()
	rattle_started.emit()

func stop_rattle() -> void:
	is_rattling = false
	if window_frame:
		window_frame.position = base_frame_pos
	if latch_mesh and is_latched:
		latch_mesh.rotation_degrees.z = 0.0
	if rattle_audio and rattle_audio.playing:
		rattle_audio.stop()
	rattle_stopped.emit()

func breach_plank() -> bool:
	_ensure_nodes()
	stop_rattle()
	
	# If the heavy wrought-iron drop latch is secured, it absorbs the blow!
	if is_latched and latch_health > 0:
		latch_health -= 1
		if latch_audio and is_inside_tree():
			latch_audio.pitch_scale = 0.88
			latch_audio.play()
		latch_battered.emit(latch_health)
		if latch_health <= 0:
			is_latched = false
			if latch_mesh:
				latch_mesh.rotation_degrees.z = -75.0 # Drop open
		_update_visuals()
		return false # Impact absorbed by drop-latch!
	
	if current_planks > 0:
		current_planks -= 1
		_update_visuals()
		_update_draft()
		breached.emit(current_planks)
		var game_state = get_node_or_null("/root/GameState")
		if game_state and game_state.has_method("notify_window_breached"):
			game_state.notify_window_breached()
		return true
	return false

func is_fully_fortified() -> bool:
	return current_planks >= max_planks and is_latched and latch_health >= max_latch_health

func is_breached() -> bool:
	return current_planks < max_planks or not is_latched

func secure_latch() -> void:
	_ensure_nodes()
	is_latched = true
	latch_health = max_latch_health
	if latch_mesh:
		latch_mesh.rotation_degrees.z = 0.0
	if latch_audio and is_inside_tree():
		latch_audio.pitch_scale = 1.12
		latch_audio.play()
	_update_visuals()
	latch_secured.emit()

func _update_visuals() -> void:
	_ensure_nodes()
	if plank_visual_1:
		plank_visual_1.visible = (current_planks >= 1)
	if plank_visual_2:
		plank_visual_2.visible = (current_planks >= 2)
	if plank_visual_3:
		plank_visual_3.visible = (current_planks >= 3)
	
	if latch_mesh:
		latch_mesh.rotation_degrees.z = 0.0 if is_latched else -75.0
		
	if is_rattling or not is_latched or latch_health < max_latch_health:
		prompt_message = "[E] Wedge & Slam Window Latch"
		is_enabled = true
	elif current_planks < max_planks:
		prompt_message = "[E] Nail Timber Plank (%d/%d)" % [current_planks, max_planks]
		is_enabled = true
	else:
		prompt_message = "Window & Latch Fully Fortified"
		is_enabled = false

func _update_draft() -> void:
	_ensure_nodes()
	if draft_audio:
		if current_planks < max_planks:
			var missing = max_planks - current_planks
			draft_audio.volume_db = -20.0 + (missing * 3.5)
			if not draft_audio.playing:
				draft_audio.play()
		else:
			if draft_audio.playing:
				draft_audio.stop()

func _on_interacted(player: Node) -> void:
	_ensure_nodes()
	if is_rattling or not is_latched or latch_health < max_latch_health:
		secure_latch()
		return

	if current_planks < max_planks:
		current_planks += 1
		if hammer_audio:
			hammer_audio.pitch_scale = randf_range(0.9, 1.1)
			hammer_audio.play()
		_update_visuals()
		_update_draft()
		var is_full = (current_planks >= max_planks and is_latched)
		fortified.emit(is_full)
		var game_state = get_node_or_null("/root/GameState")
		if game_state and game_state.has_method("notify_window_repaired"):
			game_state.notify_window_repaired()

func _unseen_entities() -> Array:
	var game_state := get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("get_unseen_entities"):
		return game_state.get_unseen_entities()
	return get_tree().get_nodes_in_group("unseen_entity") if is_inside_tree() else []
