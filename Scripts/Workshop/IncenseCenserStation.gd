class_name IncenseCenserStation
extends Interactable

## Juniper Rosin Incense Censer (Das Wacholder-Räucherfass)
## Hanging perforated copper thurible burner filled with spruce rosin, dried juniper, and thyme.
## Stoking the coals ([E], censer_ignite.wav) emits a fragrant consecrated smoke cloud
## lasting 35.0 seconds that suppresses creeping floor mist by 70% and exposes invisible
## entity hoofprint wakes in the dark.

signal censer_lit(duration: float)
signal censer_quenched()

@export var max_charges: int = 2
@export var current_charges: int = 2
@export var smoke_duration: float = 35.0
@export var purification_radius: float = 7.0

@onready var censer_mesh: MeshInstance3D = $CenserMesh
@onready var chain_mesh: MeshInstance3D = $ChainMesh
@onready var coal_light: OmniLight3D = $CoalLight
@onready var smoke_particles: GPUParticles3D = $SmokeParticles
@onready var ignite_audio: AudioStreamPlayer3D = $IgniteAudio

var is_active: bool = false
var smoke_timer: float = 0.0
var floor_mist_ref: Node = null
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not censer_mesh:
		censer_mesh = get_node_or_null("CenserMesh")
	if not chain_mesh:
		chain_mesh = get_node_or_null("ChainMesh")
	if not coal_light:
		coal_light = get_node_or_null("CoalLight")
	if not smoke_particles:
		smoke_particles = get_node_or_null("SmokeParticles")
	if not ignite_audio:
		ignite_audio = get_node_or_null("IgniteAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_prompt()

func _update_prompt() -> void:
	if is_active:
		prompt_message = "Purifying Incense Smoldering (%ds)" % int(ceil(smoke_timer))
		is_enabled = false
	elif current_charges > 0:
		prompt_message = "[E] Stoke Juniper Rosin Censer (%d charges)" % current_charges
		is_enabled = true
	else:
		prompt_message = "Incense Rosin Consumed"
		is_enabled = false

func _find_mist_and_wraith() -> void:
	if not is_inside_tree():
		return
	if not floor_mist_ref:
		var mists = get_tree().get_nodes_in_group("floor_mist")
		if mists.size() > 0:
			floor_mist_ref = mists[0]
	if not wraith_ref:
		var wraiths = get_tree().get_nodes_in_group("unseen_entity")
		if wraiths.size() > 0:
			wraith_ref = wraiths[0]

func _process(delta: float) -> void:
	_ensure_nodes()
	if not is_active:
		return

	smoke_timer -= delta
	if smoke_timer <= 0.0:
		quench_censer()
		return

	_find_mist_and_wraith()

	# Expose wraith when inside incense smoke cone
	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var my_pos = global_position if is_inside_tree() else position
		var dist = (w_pos - my_pos).length()
		if dist <= purification_radius:
			if wraith_ref.has_method("expose_to_uv_light"):
				wraith_ref.expose_to_uv_light(self)

func _on_interacted(_player: Node) -> void:
	light_censer()

func light_censer() -> bool:
	if is_active or current_charges <= 0:
		return false

	_ensure_nodes()
	current_charges -= 1
	is_active = true
	smoke_timer = smoke_duration

	if ignite_audio and is_inside_tree():
		ignite_audio.play()

	if coal_light:
		coal_light.light_energy = 1.6

	if smoke_particles:
		smoke_particles.emitting = true

	# Suppress floor mist
	_find_mist_and_wraith()
	if floor_mist_ref and is_instance_valid(floor_mist_ref):
		if "mist_density" in floor_mist_ref:
			floor_mist_ref.set("mist_density", floor_mist_ref.get("mist_density") * 0.3)

	_update_prompt()
	censer_lit.emit(smoke_duration)
	return true

func quench_censer() -> void:
	is_active = false
	smoke_timer = 0.0

	if coal_light:
		coal_light.light_energy = 0.1

	if smoke_particles:
		smoke_particles.emitting = false

	# Restore floor mist
	if floor_mist_ref and is_instance_valid(floor_mist_ref):
		if "mist_density" in floor_mist_ref:
			floor_mist_ref.set("mist_density", floor_mist_ref.get("mist_density") / 0.3)

	_update_prompt()
	censer_quenched.emit()
