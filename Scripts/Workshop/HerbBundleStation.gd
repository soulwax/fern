class_name HerbBundleStation
extends Interactable

## Midsummer Eve Consecrated Herb Bundles (Johanniskraut-Bündel)
## Bundles of Saint John's wort and mugwort hung from the ceiling drying rafters.
## When crushed, releases an aromatic botanical cloud that soothes cardiac terror
## and masks the player's scent and sprint footsteps from Der Alp for 20 seconds.

signal herb_crushed(duration: float)
signal herbs_depleted()

@export var max_charges: int = 2
@export var stealth_duration: float = 20.0

@onready var bundle_mesh: MeshInstance3D = $BundleMesh
@onready var crush_audio: AudioStreamPlayer3D = $CrushAudio
@onready var fragrant_particles: GPUParticles3D = $FragrantParticles
@onready var uv_rune_glow: OmniLight3D = $UVRuneGlow

var current_charges: int = 2
var stealth_active_timer: float = 0.0

func _ensure_nodes() -> void:
	if not bundle_mesh:
		bundle_mesh = get_node_or_null("BundleMesh")
	if not crush_audio:
		crush_audio = get_node_or_null("CrushAudio")
	if not fragrant_particles:
		fragrant_particles = get_node_or_null("FragrantParticles")
	if not uv_rune_glow:
		uv_rune_glow = get_node_or_null("UVRuneGlow")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	current_charges = max_charges
	_update_visual_state()

func _process(delta: float) -> void:
	_ensure_nodes()
	if stealth_active_timer > 0.0:
		stealth_active_timer -= delta
		prompt_message = "Botanical Scent Mask Active (%.0fs)" % ceil(stealth_active_timer)
		is_enabled = false
		return

	if current_charges > 0:
		prompt_message = "[E] Crush Midsummer Herb Sprig (%d/%d)" % [current_charges, max_charges]
		is_enabled = true
	else:
		prompt_message = "Herb Bundles Depleted"
		is_enabled = false

func _on_interacted(_player: Node) -> void:
	if current_charges > 0 and stealth_active_timer <= 0.0:
		crush_herb()

func crush_herb() -> void:
	_ensure_nodes()
	if current_charges <= 0:
		return

	current_charges -= 1
	stealth_active_timer = stealth_duration

	if crush_audio and is_inside_tree():
		crush_audio.pitch_scale = randf_range(0.96, 1.04)
		crush_audio.play()

	if fragrant_particles:
		fragrant_particles.restart()
		fragrant_particles.emitting = true

	# Apply stealth to wraith
	if is_inside_tree():
		var wraiths = get_tree().get_nodes_in_group("unseen_entity")
		for w in wraiths:
			if w.has_method("set_scent_masked"):
				w.set_scent_masked(stealth_duration)

	_update_visual_state()
	herb_crushed.emit(stealth_duration)
	if current_charges <= 0:
		herbs_depleted.emit()

func _update_visual_state() -> void:
	if bundle_mesh:
		bundle_mesh.visible = (current_charges > 0)
	if uv_rune_glow:
		uv_rune_glow.visible = (current_charges > 0)
