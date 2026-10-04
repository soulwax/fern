class_name GlassCarillonProp
extends Node3D

## Acoustic Glass Rafter Carillons (Das Glasglockenspiel)
## Hand-blown Black Forest forest-glass bells suspended from loft rafters.
## Sensitive to air drafts and the unseen mass of Der Alp.
## Resonates with crystalline spatial chimes when the wraith moves overhead.

signal chime_triggered()

@export var detection_radius: float = 5.2

@onready var bells_root: Node3D = $Bells
@onready var chime_audio: AudioStreamPlayer3D = $ChimeAudio

var chime_cooldown: float = 3.0
var sway_time: float = 0.0
var is_swaying: bool = false
var sway_duration: float = 0.0

func _ensure_nodes() -> void:
	if not bells_root:
		bells_root = get_node_or_null("Bells")
	if not chime_audio:
		chime_audio = get_node_or_null("ChimeAudio")

func _ready() -> void:
	_ensure_nodes()
	add_to_group("glass_carillon")

func _process(delta: float) -> void:
	_ensure_nodes()
	chime_cooldown -= delta
	
	if is_swaying:
		sway_time += delta * 4.0
		sway_duration -= delta
		if bells_root:
			var sway_angle = sin(sway_time) * (sway_duration / 2.5) * 6.0
			bells_root.rotation_degrees.z = sway_angle
			bells_root.rotation_degrees.x = cos(sway_time * 0.8) * (sway_duration / 2.5) * 4.0
		if sway_duration <= 0.0:
			is_swaying = false
			if bells_root:
				bells_root.rotation_degrees = Vector3.ZERO
				
	if chime_cooldown <= 0.0:
		_check_wraith_proximity()

func _check_wraith_proximity() -> void:
	if not is_inside_tree():
		return
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	for w in wraiths:
		if is_instance_valid(w):
			var cur_p = global_position if is_inside_tree() else position
			var wr_p = w.global_position if w.is_inside_tree() else w.position
			var d = cur_p.distance_to(wr_p)
			if d <= detection_radius:
				trigger_chime()
				break

func trigger_chime() -> void:
	_ensure_nodes()
	chime_cooldown = randf_range(6.5, 11.0)
	is_swaying = true
	sway_duration = 2.5
	sway_time = 0.0
	
	if chime_audio:
		chime_audio.pitch_scale = randf_range(0.96, 1.04)
		chime_audio.play()
		
	chime_triggered.emit()
