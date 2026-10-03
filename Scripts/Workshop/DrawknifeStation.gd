class_name DrawknifeStation
extends Interactable

## Carpenter's Drawknife & Consecrated Shaving Snare (Das Zugmesser & Der Hobelspan-Wall)
## Authentic 19th-century curved two-handled drawknife at the shaving horse (Schnitzbank).
## Drawing the blade across dry spruce billets (drawknife_peel.wav) harvests fragrant
## ribbon snares.
## Deploying shavings across doorway or window chokepoints entangles Der Alp's limbs,
## reducing its movement speed by 40% (0.6x) for 5.0 seconds.

signal shaving_carved()
signal snare_deployed(pos: Vector3)
signal wraith_snared(pos: Vector3)

@export var max_snares: int = 4
@export var current_snares: int = 3
@export var snare_slow_multiplier: float = 0.60
@export var snare_slow_duration: float = 5.0
@export var snare_trigger_radius: float = 2.5

@onready var horse_mesh: MeshInstance3D = $HorseMesh
@onready var drawknife_mesh: MeshInstance3D = $DrawknifeMesh
@onready var peel_audio: AudioStreamPlayer3D = $PeelAudio

var deployed_snares: Array[Vector3] = []
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not horse_mesh:
		horse_mesh = get_node_or_null("HorseMesh")
	if not drawknife_mesh:
		drawknife_mesh = get_node_or_null("DrawknifeMesh")
	if not peel_audio:
		peel_audio = get_node_or_null("PeelAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_prompt()

func _update_prompt() -> void:
	if current_snares > 0:
		prompt_message = "[E] Carve & Lay Shaving Snare (%d remaining)" % current_snares
		is_enabled = true
	else:
		prompt_message = "Shaving Billets Depleted"
		is_enabled = false

func _find_wraith() -> void:
	if not is_inside_tree():
		return
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	if wraiths.size() > 0:
		wraith_ref = wraiths[0]

func _process(_delta: float) -> void:
	_ensure_nodes()

	if deployed_snares.is_empty():
		return

	if not wraith_ref or not is_instance_valid(wraith_ref):
		_find_wraith()

	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var i = deployed_snares.size() - 1
		while i >= 0:
			var s_pos = deployed_snares[i]
			var dist = (w_pos - s_pos).length()
			if dist <= snare_trigger_radius:
				# Trigger snare
				if wraith_ref.has_method("apply_movement_slow"):
					wraith_ref.apply_movement_slow(snare_slow_multiplier, snare_slow_duration)
				wraith_snared.emit(s_pos)
				deployed_snares.remove_at(i)
			i -= 1

func _on_interacted(player: Node) -> void:
	carve_and_deploy_snare(player)

func carve_and_deploy_snare(player: Node = null) -> bool:
	if current_snares <= 0:
		return false

	_ensure_nodes()
	current_snares -= 1

	if peel_audio and is_inside_tree():
		peel_audio.play()

	var deploy_pos: Vector3
	if player and is_instance_valid(player):
		deploy_pos = player.global_position if player.is_inside_tree() else player.position
	else:
		deploy_pos = global_position if is_inside_tree() else position

	deployed_snares.append(deploy_pos)
	shaving_carved.emit()
	snare_deployed.emit(deploy_pos)
	_update_prompt()
	return true
