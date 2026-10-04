class_name HolyWaterStoupStation
extends Interactable

## Holy Water Stoup & Boxwood Aspergillum (Das Weihwasserbecken & Der Buchsbaum-Aspergill)
## Carved wall stoup filled with consecrated Epiphany water (Dreikönigswasser) with dried boxwood.
## Sprinkling consecrated droplets ([E], holy_sprinkle.wav) blesses a 4.5m perimeter for 30s.
## When Der Alp enters the consecrated perimeter, the holy droplets vaporize into scalding steam
## (holy_steam_sizzle.wav), temporarily blinding and disorienting the wraith for 5.0 seconds.

signal water_sprinkled(duration: float)
signal wraith_scalded(pos: Vector3)

@export var max_charges: int = 3
@export var current_charges: int = 3
@export var blessing_duration: float = 30.0
@export var blessing_radius: float = 4.5

@onready var stoup_mesh: MeshInstance3D = $StoupMesh
@onready var aspergillum_mesh: MeshInstance3D = $AspergillumMesh
@onready var holy_light: OmniLight3D = $HolyLight
@onready var sprinkle_particles: GPUParticles3D = $SprinkleParticles
@onready var steam_particles: GPUParticles3D = $SteamParticles
@onready var sprinkle_audio: AudioStreamPlayer3D = $SprinkleAudio
@onready var steam_audio: AudioStreamPlayer3D = $SteamAudio

var is_blessed: bool = false
var blessing_timer: float = 0.0
var steam_cooldown: float = 0.0
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not stoup_mesh:
		stoup_mesh = get_node_or_null("StoupMesh")
	if not aspergillum_mesh:
		aspergillum_mesh = get_node_or_null("AspergillumMesh")
	if not holy_light:
		holy_light = get_node_or_null("HolyLight")
	if not sprinkle_particles:
		sprinkle_particles = get_node_or_null("SprinkleParticles")
	if not steam_particles:
		steam_particles = get_node_or_null("SteamParticles")
	if not sprinkle_audio:
		sprinkle_audio = get_node_or_null("SprinkleAudio")
	if not steam_audio:
		steam_audio = get_node_or_null("SteamAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_prompt()

func _update_prompt() -> void:
	if is_blessed:
		prompt_message = "Threshold Consecrated (%ds)" % int(ceil(blessing_timer))
		is_enabled = false
	elif current_charges > 0:
		prompt_message = "[E] Sprinkle Consecrated Water (%d/%d)" % [current_charges, max_charges]
		is_enabled = true
	else:
		prompt_message = "Holy Water Stoup Depleted"
		is_enabled = false

func _find_wraith() -> void:
	if wraith_ref and is_instance_valid(wraith_ref):
		return
	if is_inside_tree():
		var wraiths = get_tree().get_nodes_in_group("unseen_entity")
		if wraiths.size() > 0:
			wraith_ref = wraiths[0]
			return
	if get_parent():
		var w = get_parent().get_node_or_null("InvisibleWraith")
		if w:
			wraith_ref = w

func _process(delta: float) -> void:
	_ensure_nodes()
	if steam_cooldown > 0.0:
		steam_cooldown -= delta

	if not is_blessed:
		return

	blessing_timer -= delta
	if blessing_timer <= 0.0:
		quench_blessing()
		return

	_find_wraith()
	if wraith_ref and is_instance_valid(wraith_ref) and steam_cooldown <= 0.0:
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var my_pos = global_position if is_inside_tree() else position
		var dist = (w_pos - my_pos).length()
		if dist <= blessing_radius:
			_scald_wraith(w_pos)

func _on_interacted(_player: Node) -> void:
	sprinkle_water()

func sprinkle_water() -> bool:
	if is_blessed or current_charges <= 0:
		return false

	_ensure_nodes()
	current_charges -= 1
	is_blessed = true
	blessing_timer = blessing_duration

	if sprinkle_audio and is_inside_tree():
		sprinkle_audio.play()

	if holy_light:
		holy_light.light_energy = 1.4

	if sprinkle_particles:
		sprinkle_particles.emitting = true

	# Animate aspergillum flick
	if aspergillum_mesh and is_inside_tree():
		var tween = create_tween()
		tween.tween_property(aspergillum_mesh, "rotation:z", deg_to_rad(-45.0), 0.15)
		tween.tween_property(aspergillum_mesh, "rotation:z", 0.0, 0.3)

	_update_prompt()
	water_sprinkled.emit(blessing_duration)
	return true

func _scald_wraith(target_pos: Vector3) -> void:
	steam_cooldown = 4.0
	if steam_audio and is_inside_tree():
		steam_audio.play()

	if steam_particles:
		steam_particles.emitting = true

	if wraith_ref:
		if wraith_ref.has_method("apply_holy_water_blind"):
			wraith_ref.apply_holy_water_blind(5.0)
		elif wraith_ref.has_method("set_state"):
			wraith_ref.set_state(3) # State.STUNNED

	wraith_scalded.emit(target_pos)

func quench_blessing() -> void:
	is_blessed = false
	blessing_timer = 0.0
	if holy_light:
		holy_light.light_energy = 0.1
	if sprinkle_particles:
		sprinkle_particles.emitting = false
	_update_prompt()
