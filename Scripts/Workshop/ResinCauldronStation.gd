class_name ResinCauldronStation
extends Interactable

## Pine Pitch Resin Cauldron (Der Pechkessel)
## Antique cast-iron pitch pot simmering on the carpenter's brick hearth.
## Stoking the embers boils aromatic pine pitch and amber spruce resin,
## filling the upper workshop rafters with consecrated vapors that force
## Der Alp out of the elevated ceiling beams down to the ground floor.

signal cauldron_stoked(duration: float)
signal cauldron_settled()

@export var max_boil_duration: float = 45.0
@export var simmer_light_energy: float = 0.6
@export var boil_light_energy: float = 1.8

@onready var pot_mesh: MeshInstance3D = $PotMesh
@onready var resin_surface: MeshInstance3D = $ResinSurface
@onready var vapor_particles: GPUParticles3D = $VaporParticles
@onready var boil_audio: AudioStreamPlayer3D = $BoilAudio
@onready var hearth_glow: OmniLight3D = $HearthGlow

var is_boiling: bool = false
var boil_timer: float = 0.0
var flicker_t: float = 0.0

func _ensure_nodes() -> void:
	if not pot_mesh:
		pot_mesh = get_node_or_null("PotMesh")
	if not resin_surface:
		resin_surface = get_node_or_null("ResinSurface")
	if not vapor_particles:
		vapor_particles = get_node_or_null("VaporParticles")
	if not boil_audio:
		boil_audio = get_node_or_null("BoilAudio")
	if not hearth_glow:
		hearth_glow = get_node_or_null("HearthGlow")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_visual_state()

func _process(delta: float) -> void:
	_ensure_nodes()
	flicker_t += delta * 6.0
	
	if is_boiling:
		boil_timer -= delta
		prompt_message = "Pine Pitch Simmering (%.0fs)" % ceil(boil_timer)
		is_enabled = false
		
		if hearth_glow:
			hearth_glow.light_energy = boil_light_energy + sin(flicker_t) * 0.35 + randf_range(-0.1, 0.1)

		# Periodically reaffirm rafter denial to any newly spawned or active wraiths
		_apply_rafter_denial(boil_timer)

		if boil_timer <= 0.0:
			settle()
	else:
		prompt_message = "[E] Stoke Pine Pitch Cauldron"
		is_enabled = true
		if hearth_glow:
			hearth_glow.light_energy = simmer_light_energy + sin(flicker_t) * 0.12

func _on_interacted(_player: Node) -> void:
	if not is_boiling:
		stoke()

func stoke() -> void:
	_ensure_nodes()
	is_boiling = true
	boil_timer = max_boil_duration
	_update_visual_state()
	
	if boil_audio and is_inside_tree():
		boil_audio.pitch_scale = randf_range(0.96, 1.04)
		boil_audio.play()

	_apply_rafter_denial(max_boil_duration)
	cauldron_stoked.emit(max_boil_duration)

func settle() -> void:
	_ensure_nodes()
	is_boiling = false
	boil_timer = 0.0
	_update_visual_state()
	if boil_audio and boil_audio.playing:
		boil_audio.stop()
	cauldron_settled.emit()

func _update_visual_state() -> void:
	if vapor_particles:
		vapor_particles.emitting = is_boiling
	if hearth_glow:
		hearth_glow.light_energy = boil_light_energy if is_boiling else simmer_light_energy

func _apply_rafter_denial(duration: float) -> void:
	if not is_inside_tree():
		return
	var wraiths := _unseen_entities()
	for w in wraiths:
		if w.has_method("set_rafter_denial"):
			w.set_rafter_denial(duration)

func _unseen_entities() -> Array:
	var game_state := get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("get_unseen_entities"):
		return game_state.get_unseen_entities()
	return get_tree().get_nodes_in_group("unseen_entity") if is_inside_tree() else []
