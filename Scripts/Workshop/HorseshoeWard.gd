class_name HorseshoeWard
extends Interactable

## The Warded Iron Horseshoe (Das Hufeisen am Türsturz)
## Mounted above the entrance lintel to deflect doorway ambushes by Der Alp.
## Emits a cold-iron harmonic strike and repels the wraith, then requires
## re-consecration with holy Farnblume bloom.

signal ward_triggered(ward_position: Vector3)
signal ward_consecrated

@export var ward_radius: float = 2.4

@onready var ward_audio: AudioStreamPlayer3D = $WardAudio
@onready var spark_particles: GPUParticles3D = $ColdIronSparks
@onready var holy_embers: GPUParticles3D = $HolyEmbers
@onready var ward_light: OmniLight3D = $WardLight
@onready var horseshoe_mesh: MeshInstance3D = $HorseshoeMesh

var is_ward_active: bool = true
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not ward_audio:
		ward_audio = get_node_or_null("WardAudio")
	if not spark_particles:
		spark_particles = get_node_or_null("ColdIronSparks")
	if not holy_embers:
		holy_embers = get_node_or_null("HolyEmbers")
	if not ward_light:
		ward_light = get_node_or_null("WardLight")
	if not horseshoe_mesh:
		horseshoe_mesh = get_node_or_null("HorseshoeMesh")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	prompt_message = "Cold Iron Ward Active"
	_update_visual_state()

func _process(_delta: float) -> void:
	_ensure_nodes()
	if not is_ward_active:
		return

	_update_wraith_reference()
	if wraith_ref and is_instance_valid(wraith_ref):
		var ward_pos = global_position if is_inside_tree() else position
		var wraith_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		# Ignore vertical height difference for rafter prowling
		var horiz_dist = Vector2(ward_pos.x - wraith_pos.x, ward_pos.z - wraith_pos.z).length()
		if horiz_dist <= ward_radius and absf(ward_pos.y - wraith_pos.y) < 2.0:
			trigger_deflection(wraith_ref)

func trigger_deflection(wraith: Node3D) -> void:
	if not is_ward_active:
		return
	is_ward_active = false
	prompt_message = "[E] Consecrate Cold Iron Horseshoe"

	if ward_audio:
		ward_audio.pitch_scale = randf_range(0.96, 1.04)
		ward_audio.play()

	if spark_particles:
		spark_particles.restart()
		spark_particles.emitting = true

	var ward_pos = global_position if is_inside_tree() else position
	if wraith.has_method("repel_by_horseshoe"):
		wraith.repel_by_horseshoe(ward_pos)
	elif wraith.has_method("repel_by_holy_runes"):
		wraith.repel_by_holy_runes()

	_update_visual_state()
	ward_triggered.emit(ward_pos)

func _on_interacted(_player: Node) -> void:
	if is_ward_active:
		return
	consecrate()

func consecrate() -> void:
	is_ward_active = true
	prompt_message = "Cold Iron Ward Active"

	if ward_audio:
		ward_audio.pitch_scale = 1.25 # Uplifting high chime on consecration
		ward_audio.play()

	_update_visual_state()
	ward_consecrated.emit()

func _update_visual_state() -> void:
	if holy_embers:
		holy_embers.emitting = is_ward_active
	if ward_light:
		ward_light.light_energy = 0.6 if is_ward_active else 0.0

func _update_wraith_reference() -> void:
	if wraith_ref and is_instance_valid(wraith_ref):
		return
	var main_tree = get_tree()
	if main_tree:
		wraith_ref = main_tree.root.find_child("InvisibleWraith", true, false)
