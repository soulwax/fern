extends Node3D
class_name HangingProp

@export var max_swing_angle_deg: float = 14.0
@export var swing_frequency: float = 2.5
@export var swing_damping: float = 0.8

@onready var visual_pivot: Node3D = $Pivot
@onready var creak_audio: AudioStreamPlayer3D = $CreakAudio
@onready var proximity_area: Area3D = $ProximityArea

var is_swinging: bool = false
var swing_time: float = 0.0
var current_amplitude: float = 0.0
var swing_direction: Vector3 = Vector3.RIGHT

func _ready() -> void:
	if proximity_area:
		proximity_area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_swinging:
		swing_time += delta
		var decay = exp(-swing_damping * swing_time)
		var angle = deg_to_rad(max_swing_angle_deg) * decay * cos(swing_frequency * swing_time)
		
		if visual_pivot:
			visual_pivot.rotation.x = angle * swing_direction.z
			visual_pivot.rotation.z = angle * swing_direction.x
			
		if decay < 0.02:
			is_swinging = false
			if visual_pivot:
				visual_pivot.rotation = Vector3.ZERO

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("unseen_entity") or body.is_in_group("player"):
		trigger_swing(body.velocity)

func trigger_swing(impulse_velocity: Vector3 = Vector3.ZERO) -> void:
	is_swinging = true
	swing_time = 0.0
	
	if impulse_velocity.length() > 0.5:
		swing_direction = impulse_velocity.normalized()
	else:
		swing_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
		
	if creak_audio and not creak_audio.playing:
		creak_audio.pitch_scale = randf_range(0.92, 1.08)
		creak_audio.play()
