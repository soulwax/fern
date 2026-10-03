class_name HearthBellowsStation
extends Interactable

## Charcoal Hearth & Leather Bellows Blast (Das Kohlenbecken & Der Schmiedebalg)
## Authentic 19th-century forge hearth with glowing charcoal embers.
## When Der Alp draws near (<5.0m), the supernatural chill quenches glowing coals
## into a sharp vapor hiss (ember_hiss.wav).
## Pumping the bellows ([E], bellows_pump.wav) blasts air into the coals, erupting
## into radiant orange light, flying sparks, and repelling the entity.

signal bellows_pumped()
signal hearth_chilled()

@export var chill_detection_radius: float = 5.0
@export var flare_repel_radius: float = 6.0
@export var baseline_light_energy: float = 1.5
@export var chilled_light_energy: float = 0.2
@export var flared_light_energy: float = 4.0

@onready var hearth_mesh: MeshInstance3D = $HearthMesh
@onready var bellows_mesh: MeshInstance3D = $BellowsMesh
@onready var coals_mesh: MeshInstance3D = $CoalsMesh
@onready var hearth_light: OmniLight3D = $HearthLight
@onready var bellows_audio: AudioStreamPlayer3D = $BellowsAudio
@onready var hiss_audio: AudioStreamPlayer3D = $HissAudio

var is_chilled: bool = false
var flare_duration: float = 0.0
var bellows_cooldown: float = 0.0
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not hearth_mesh:
		hearth_mesh = get_node_or_null("HearthMesh")
	if not bellows_mesh:
		bellows_mesh = get_node_or_null("BellowsMesh")
	if not coals_mesh:
		coals_mesh = get_node_or_null("CoalsMesh")
	if not hearth_light:
		hearth_light = get_node_or_null("HearthLight")
	if not bellows_audio:
		bellows_audio = get_node_or_null("BellowsAudio")
	if not hiss_audio:
		hiss_audio = get_node_or_null("HissAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	prompt_message = "[E] Pump Leather Bellows"
	is_enabled = true
	_update_light(baseline_light_energy)

func _find_wraith() -> void:
	if not is_inside_tree():
		return
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	if wraiths.size() > 0:
		wraith_ref = wraiths[0]

func _process(delta: float) -> void:
	_ensure_nodes()

	if bellows_cooldown > 0.0:
		bellows_cooldown -= delta

	if flare_duration > 0.0:
		flare_duration -= delta
		var t = clamp(flare_duration / 4.0, 0.0, 1.0)
		var current_energy = lerp(baseline_light_energy, flared_light_energy, t)
		_update_light(current_energy)
		prompt_message = "Hearth Blazing"
		is_enabled = false
		return

	if not wraith_ref or not is_instance_valid(wraith_ref):
		_find_wraith()

	if wraith_ref and is_instance_valid(wraith_ref):
		var my_pos = global_position if is_inside_tree() else position
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var dist = (my_pos - w_pos).length()

		if dist <= chill_detection_radius:
			if not is_chilled:
				is_chilled = true
				if hiss_audio and is_inside_tree():
					hiss_audio.play()
				hearth_chilled.emit()
			_update_light(chilled_light_energy)
		else:
			if is_chilled:
				is_chilled = false
			_update_light(baseline_light_energy)
	else:
		_update_light(baseline_light_energy)

	if bellows_cooldown <= 0.0:
		prompt_message = "[E] Pump Leather Bellows"
		is_enabled = true
	else:
		prompt_message = "Bellows Recharging"
		is_enabled = false

func _update_light(energy: float) -> void:
	if hearth_light:
		hearth_light.light_energy = energy

func _on_interacted(_player: Node) -> void:
	pump_bellows()

func pump_bellows() -> void:
	if bellows_cooldown > 0.0:
		return

	_ensure_nodes()
	bellows_cooldown = 8.0
	flare_duration = 4.0
	is_chilled = false

	if bellows_audio and is_inside_tree():
		bellows_audio.play()

	_update_light(flared_light_energy)
	bellows_pumped.emit()

	# Repel wraith in proximity
	if not wraith_ref or not is_instance_valid(wraith_ref):
		_find_wraith()

	if wraith_ref and is_instance_valid(wraith_ref):
		var my_pos = global_position if is_inside_tree() else position
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var dist = (my_pos - w_pos).length()
		if dist <= flare_repel_radius:
			if wraith_ref.has_method("repel_by_hearth_bellows"):
				wraith_ref.repel_by_hearth_bellows(my_pos, 4.0)
