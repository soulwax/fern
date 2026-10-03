extends "res://Scripts/Workshop/Interactable.gd"
class_name WindowBreach

signal fortified(status: bool)
signal breached(current_planks: int)
signal rattle_started()
signal rattle_stopped()

@export var max_planks: int = 3
@export var current_planks: int = 2 # Starts at 2/3 planks

@onready var window_frame: Node3D = $WindowFrame
@onready var plank_visual_1: Node3D = $Planks/Plank1
@onready var plank_visual_2: Node3D = $Planks/Plank2
@onready var plank_visual_3: Node3D = $Planks/Plank3
@onready var hammer_audio: AudioStreamPlayer3D = $HammerAudio
@onready var rattle_audio: AudioStreamPlayer3D = $RattleAudio
@onready var draft_audio: AudioStreamPlayer3D = $DraftAudio

var is_rattling: bool = false
var rattle_timer: float = 0.0
var base_frame_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	if window_frame:
		base_frame_pos = window_frame.position
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

func _process(delta: float) -> void:
	if is_rattling:
		rattle_timer -= delta
		# Shudder vibration on the frame
		if window_frame:
			var jitter_x = randf_range(-0.03, 0.03)
			var jitter_y = randf_range(-0.02, 0.02)
			window_frame.position = base_frame_pos + Vector3(jitter_x, jitter_y, 0.0)
		
		if rattle_timer <= 0.0:
			stop_rattle()

func start_rattle(duration: float = 3.5) -> void:
	_ensure_nodes()
	is_rattling = true
	rattle_timer = duration
	if rattle_audio and not rattle_audio.playing:
		rattle_audio.pitch_scale = randf_range(0.92, 1.08)
		rattle_audio.play()
	rattle_started.emit()

func stop_rattle() -> void:
	is_rattling = false
	if window_frame:
		window_frame.position = base_frame_pos
	if rattle_audio and rattle_audio.playing:
		rattle_audio.stop()
	rattle_stopped.emit()

func breach_plank() -> bool:
	_ensure_nodes()
	stop_rattle()
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
	return current_planks >= max_planks

func is_breached() -> bool:
	return current_planks < max_planks

func _update_visuals() -> void:
	_ensure_nodes()
	if plank_visual_1:
		plank_visual_1.visible = (current_planks >= 1)
	if plank_visual_2:
		plank_visual_2.visible = (current_planks >= 2)
	if plank_visual_3:
		plank_visual_3.visible = (current_planks >= 3)
		
	if current_planks < max_planks:
		prompt_message = "[E] Nail Timber Plank (%d/%d)" % [current_planks, max_planks]
		is_enabled = true
	else:
		prompt_message = "Window Fully Barricaded"
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
	if current_planks < max_planks:
		current_planks += 1
		if hammer_audio:
			hammer_audio.pitch_scale = randf_range(0.9, 1.1)
			hammer_audio.play()
		_update_visuals()
		_update_draft()
		var is_full = (current_planks >= max_planks)
		fortified.emit(is_full)
		var game_state = get_node_or_null("/root/GameState")
		if game_state and game_state.has_method("notify_window_repaired"):
			game_state.notify_window_repaired()
