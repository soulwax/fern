class_name SaltLineStation
extends Interactable

## Consecrated Salt Line (Die Salzlinie)
## Strewn across workshop thresholds to ward against night wraiths.
## Sizzles violently and emits holy sparks to repel Der Alp when crossed,
## with a 2-charge durability before requiring fresh salt from the player.

signal salt_triggered(charges_left: int)
signal salt_replenished

@export var max_charges: int = 2
@export var barrier_radius: float = 1.3

@onready var salt_mesh: MeshInstance3D = $SaltMesh
@onready var sizzle_sparks: GPUParticles3D = $SizzleSparks
@onready var sizzle_audio: AudioStreamPlayer3D = $SizzleAudio
@onready var holy_glow: OmniLight3D = $HolyGlow

var current_charges: int = 2
var wraith_ref: Node3D = null
var trigger_cooldown: float = 0.0

func _ensure_nodes() -> void:
	if not salt_mesh:
		salt_mesh = get_node_or_null("SaltMesh")
	if not sizzle_sparks:
		sizzle_sparks = get_node_or_null("SizzleSparks")
	if not sizzle_audio:
		sizzle_audio = get_node_or_null("SizzleAudio")
	if not holy_glow:
		holy_glow = get_node_or_null("HolyGlow")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	current_charges = max_charges
	_update_visual_state()

func _process(delta: float) -> void:
	_ensure_nodes()
	if trigger_cooldown > 0.0:
		trigger_cooldown -= delta

	if current_charges <= 0:
		prompt_message = "[E] Strew Fresh Salt Line"
		return
	else:
		prompt_message = "Salt Barrier Active (%d)" % current_charges

	if trigger_cooldown <= 0.0:
		_check_wraith_crossing()

func _check_wraith_crossing() -> void:
	_update_wraith_reference()
	if not wraith_ref or not is_instance_valid(wraith_ref):
		return

	var line_pos = global_position if is_inside_tree() else position
	var wraith_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position

	var is_ground = absf(line_pos.y - wraith_pos.y) < 1.8
	var horiz_dist = Vector2(line_pos.x - wraith_pos.x, line_pos.z - wraith_pos.z).length()

	if is_ground and horiz_dist <= barrier_radius:
		trigger_sizzle(wraith_ref)

func trigger_sizzle(wraith: Node3D) -> void:
	if current_charges <= 0:
		return

	current_charges -= 1
	trigger_cooldown = 2.5

	if sizzle_audio and sizzle_audio.is_inside_tree():
		sizzle_audio.pitch_scale = randf_range(0.95, 1.05)
		sizzle_audio.play()

	if sizzle_sparks:
		sizzle_sparks.restart()
		sizzle_sparks.emitting = true

	if wraith.has_method("repel_by_holy_runes"):
		wraith.repel_by_holy_runes()
	elif wraith.has_method("repel_by_horseshoe"):
		wraith.repel_by_horseshoe(global_position if is_inside_tree() else position)

	_update_visual_state()
	salt_triggered.emit(current_charges)

func _on_interacted(_player: Node) -> void:
	if current_charges < max_charges:
		replenish()

func replenish() -> void:
	_ensure_nodes()
	current_charges = max_charges
	trigger_cooldown = 0.0
	_update_visual_state()
	salt_replenished.emit()

func _update_visual_state() -> void:
	if not salt_mesh:
		return
	if current_charges > 0:
		salt_mesh.visible = true
		if holy_glow:
			holy_glow.light_energy = 0.35 * (float(current_charges) / float(max_charges))
	else:
		salt_mesh.visible = false
		if holy_glow:
			holy_glow.light_energy = 0.0

func _update_wraith_reference() -> void:
	if wraith_ref and is_instance_valid(wraith_ref):
		return
	var main_tree = get_tree()
	if main_tree:
		wraith_ref = main_tree.root.find_child("InvisibleWraith", true, false)
