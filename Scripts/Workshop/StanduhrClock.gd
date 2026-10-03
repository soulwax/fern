class_name StanduhrClock
extends Node3D

## The Black Forest Standuhr (Mechanical Clock of Dread)
## Features authentic escapement tick-tock, hourly chimes, and supernatural
## time dilation (pitch down & cessation of ticking) when Der Alp prowls nearby.

@onready var tick_audio: AudioStreamPlayer3D = $TickAudio
@onready var chime_audio: AudioStreamPlayer3D = $ChimeAudio
@onready var pendulum: Node3D = $PendulumAnchor/Pendulum

var wraith_node: Node3D = null
var base_swing_speed: float = 3.14159
var current_swing_speed: float = 3.14159
var pendulum_phase: float = 0.0
var is_frozen: bool = false

func _ensure_nodes() -> void:
	if not tick_audio:
		tick_audio = get_node_or_null("TickAudio")
	if not chime_audio:
		chime_audio = get_node_or_null("ChimeAudio")
	if not pendulum:
		pendulum = get_node_or_null("PendulumAnchor/Pendulum")

func _ready() -> void:
	_ensure_nodes()
	if tick_audio and not tick_audio.playing:
		tick_audio.play()

	# Connect to GameState hour changes for hourly chimes
	var game_state = get_node_or_null("/root/GameState")
	if game_state and game_state.has_signal("hour_changed"):
		if not game_state.hour_changed.is_connected(_on_hour_changed):
			game_state.hour_changed.connect(_on_hour_changed)

func _process(delta: float) -> void:
	_ensure_nodes()
	_update_wraith_reference()

	var wraith_dist: float = 999.0
	if wraith_node and is_instance_valid(wraith_node):
		var clock_pos = global_position if is_inside_tree() else position
		var wraith_pos = wraith_node.global_position if wraith_node.is_inside_tree() else wraith_node.position
		wraith_dist = clock_pos.distance_to(wraith_pos)

	# Supernatural Dread Dilation:
	# Far (>5.5m): Normal cadence (1.0x pitch)
	# Approaching (2.5m - 5.5m): Deceleration (pitch down 1.0 -> 0.45)
	# Critical Proximity (<2.5m): Mechanical arrest / Dead Silence!
	if wraith_dist < 2.5:
		if not is_frozen:
			is_frozen = true
			tick_audio.stream_paused = true
		current_swing_speed = 0.0
	elif wraith_dist < 5.5:
		if is_frozen:
			is_frozen = false
			tick_audio.stream_paused = false
		var factor: float = clampf((wraith_dist - 2.5) / 3.0, 0.0, 1.0)
		var target_pitch: float = lerpf(0.45, 1.0, factor)
		tick_audio.pitch_scale = lerpf(tick_audio.pitch_scale, target_pitch, delta * 6.0)
		current_swing_speed = base_swing_speed * target_pitch
	else:
		if is_frozen:
			is_frozen = false
			tick_audio.stream_paused = false
		tick_audio.pitch_scale = lerpf(tick_audio.pitch_scale, 1.0, delta * 4.0)
		current_swing_speed = base_swing_speed

	# Oscillate pendulum
	if not is_frozen:
		pendulum_phase += delta * current_swing_speed
		if pendulum:
			pendulum.rotation.z = sin(pendulum_phase) * 0.16
	elif pendulum:
		# Tremble slightly while frozen
		pendulum.rotation.z = sin(pendulum_phase) * 0.16 + (randf() * 0.01 - 0.005)

func _update_wraith_reference() -> void:
	if wraith_node and is_instance_valid(wraith_node):
		return
	var main_tree = get_tree()
	if main_tree:
		wraith_node = main_tree.root.find_child("InvisibleWraith", true, false)

func _on_hour_changed(_new_hour: int, _hour_name: String = "") -> void:
	chime()

func chime() -> void:
	_ensure_nodes()
	if chime_audio and chime_audio.is_inside_tree():
		chime_audio.stop()
		chime_audio.pitch_scale = randf_range(0.98, 1.02)
		chime_audio.play()
