extends Node3D
class_name HangingProp

signal chain_swung(impulse: Vector3)

@export var max_swing_angle_deg: float = 14.0
@export var swing_frequency: float = 2.5
@export var swing_damping: float = 0.8

@onready var visual_pivot: Node3D = $Pivot
@onready var creak_audio: AudioStreamPlayer3D = $CreakAudio
@onready var chain_clink_audio: AudioStreamPlayer3D = get_node_or_null("ChainClinkAudio")
@onready var proximity_area: Area3D = $ProximityArea

var is_swinging: bool = false
var swing_time: float = 0.0
var current_amplitude: float = 0.0
var swing_direction: Vector3 = Vector3.RIGHT

func _ready() -> void:
	_ensure_nodes()
	if proximity_area and not proximity_area.body_entered.is_connected(_on_body_entered):
		proximity_area.body_entered.connect(_on_body_entered)
	set_process(false)

func _ensure_nodes() -> void:
	if not visual_pivot:
		visual_pivot = get_node_or_null("Pivot")
	if not creak_audio:
		creak_audio = get_node_or_null("CreakAudio")
	if not chain_clink_audio:
		chain_clink_audio = get_node_or_null("ChainClinkAudio")
	if not proximity_area:
		proximity_area = get_node_or_null("ProximityArea")

func _process(delta: float) -> void:
	if is_swinging:
		swing_time += delta
		var decay = exp(-swing_damping * swing_time)
		var angle = deg_to_rad(max_swing_angle_deg) * decay * cos(swing_frequency * swing_time)
		
		_ensure_nodes()
		if visual_pivot:
			visual_pivot.rotation.x = angle * swing_direction.z
			visual_pivot.rotation.z = angle * swing_direction.x
			
		if decay < 0.02:
			is_swinging = false
			if visual_pivot:
				visual_pivot.rotation = Vector3.ZERO
			set_process(false)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("unseen_entity") or body.is_in_group("player"):
		var vel = Vector3.ZERO
		if "velocity" in body:
			vel = body.velocity
		trigger_swing(vel)

func trigger_swing(impulse_velocity: Vector3 = Vector3.ZERO) -> void:
	_ensure_nodes()
	is_swinging = true
	set_process(true)
	swing_time = 0.0
	
	if impulse_velocity.length() > 0.5:
		swing_direction = impulse_velocity.normalized()
	else:
		swing_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
		
	if creak_audio and is_inside_tree() and not creak_audio.playing:
		creak_audio.pitch_scale = randf_range(0.92, 1.08)
		creak_audio.play()

	if chain_clink_audio and is_inside_tree():
		chain_clink_audio.pitch_scale = randf_range(0.90, 1.12)
		chain_clink_audio.play()

	chain_swung.emit(impulse_velocity)

