extends Node3D
class_name WorkbenchPropGroup

signal tools_rattled()

@export var detection_radius: float = 3.8

@onready var props_root: Node3D = $Props
@onready var rattle_audio: AudioStreamPlayer3D = $RattleAudio
@onready var proximity_area: Area3D = $ProximityArea

var is_vibrating: bool = false
var vibrate_time: float = 0.0
var rattle_cooldown: float = 0.0
var cached_props_origin: Vector3 = Vector3.ZERO
var cached_wraith: Node3D = null

func _ready() -> void:
	_ensure_components()
	if props_root:
		cached_props_origin = props_root.position

func _ensure_components() -> void:
	if not props_root:
		props_root = get_node_or_null("Props")
	if not rattle_audio:
		rattle_audio = get_node_or_null("RattleAudio")
	if not proximity_area:
		proximity_area = get_node_or_null("ProximityArea")

func _process(delta: float) -> void:
	_ensure_components()
	if rattle_cooldown > 0.0:
		rattle_cooldown -= delta
		
	# Check proximity to wraith
	if not cached_wraith or not is_instance_valid(cached_wraith):
		var wraiths = get_tree().get_nodes_in_group("unseen_entity") if get_tree() else []
		if wraiths.size() > 0:
			cached_wraith = wraiths[0]
			
	if cached_wraith and is_instance_valid(cached_wraith):
		var dist = global_position.distance_to(cached_wraith.global_position)
		if dist <= detection_radius and rattle_cooldown <= 0.0:
			trigger_rattle()
			
	if is_vibrating:
		vibrate_time -= delta
		if props_root:
			# Jitter vibration
			props_root.position = cached_props_origin + Vector3(
				randf_range(-0.008, 0.008),
				randf_range(0.0, 0.006),
				randf_range(-0.008, 0.008)
			)
			props_root.rotation.y = randf_range(-0.04, 0.04)
		if vibrate_time <= 0.0:
			is_vibrating = false
			if props_root:
				props_root.position = cached_props_origin
				props_root.rotation = Vector3.ZERO

func trigger_rattle() -> void:
	_ensure_components()
	is_vibrating = true
	vibrate_time = 0.75
	rattle_cooldown = randf_range(5.0, 8.0)
	
	if rattle_audio and is_inside_tree():
		rattle_audio.pitch_scale = randf_range(0.94, 1.08)
		rattle_audio.play()
		
	tools_rattled.emit()
