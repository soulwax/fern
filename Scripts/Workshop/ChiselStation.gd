class_name ChiselStation
extends Interactable

## Cold-Iron Framing Chisel Station (Das Handgeschmiedete Stemmeisen)
## Heavy socket chisel forged from Black Forest bog iron.
## Acts as a desperate parry defense against lunging wraith attacks,
## repelling the phantom with a concussive metallic clang, but dulling the blade.
## Can be resharpened at the workshop grindstone.

signal chisel_equipped()
signal chisel_struck(wraith_pos: Vector3)
signal chisel_resharpened()

@export var parry_range: float = 2.4

@onready var chisel_mesh: MeshInstance3D = $ChiselMesh
@onready var strike_sparks: GPUParticles3D = $StrikeSparks
@onready var strike_audio: AudioStreamPlayer3D = $StrikeAudio

var is_sharp: bool = true
var is_equipped: bool = false
var player_ref: Node3D = null
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not chisel_mesh:
		chisel_mesh = get_node_or_null("ChiselMesh")
	if not strike_sparks:
		strike_sparks = get_node_or_null("StrikeSparks")
	if not strike_audio:
		strike_audio = get_node_or_null("StrikeAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_visual_state()

func _process(_delta: float) -> void:
	_ensure_nodes()
	if is_equipped:
		if is_sharp:
			prompt_message = "Cold-Iron Chisel Ready (Parry Ward)"
			_check_wraith_parry()
		else:
			prompt_message = "[E] Place Dulled Chisel (Resharpen at Grindstone)"
		is_enabled = not is_sharp
	else:
		if is_sharp:
			prompt_message = "[E] Take Cold-Iron Framing Chisel"
			is_enabled = true
		else:
			prompt_message = "[E] Take Dulled Chisel to Grindstone"
			is_enabled = true

func _on_interacted(player: Node) -> void:
	if not is_equipped:
		equip_chisel(player)
	elif not is_sharp:
		unequip_chisel()

func equip_chisel(player: Node) -> void:
	is_equipped = true
	player_ref = player as Node3D
	_update_visual_state()
	chisel_equipped.emit()

func unequip_chisel() -> void:
	is_equipped = false
	player_ref = null
	_update_visual_state()

func parry_attack(wraith: Node3D) -> void:
	if not is_sharp:
		return
	_ensure_nodes()
	is_sharp = false
	
	var strike_pos = global_position if is_inside_tree() else position
	if is_equipped and player_ref:
		strike_pos = player_ref.global_position if player_ref.is_inside_tree() else player_ref.position

	if strike_audio and is_inside_tree():
		strike_audio.pitch_scale = randf_range(0.96, 1.04)
		strike_audio.play()

	if strike_sparks:
		strike_sparks.restart()
		strike_sparks.emitting = true

	if wraith.has_method("repel_by_torch"):
		wraith.repel_by_torch(strike_pos)
	elif wraith.has_method("repel_by_horseshoe"):
		wraith.repel_by_horseshoe(strike_pos)
	elif wraith.has_method("repel_by_holy_runes"):
		wraith.repel_by_holy_runes()

	_update_visual_state()
	chisel_struck.emit(strike_pos)

func resharpen() -> void:
	_ensure_nodes()
	is_sharp = true
	_update_visual_state()
	chisel_resharpened.emit()

func _check_wraith_parry() -> void:
	if not is_sharp or not is_equipped:
		return
	_update_wraith_reference()
	if not wraith_ref or not is_instance_valid(wraith_ref):
		return

	var char_pos = player_ref.global_position if (player_ref and player_ref.is_inside_tree()) else position
	var wraith_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position

	if char_pos.distance_to(wraith_pos) <= parry_range:
		parry_attack(wraith_ref)

func _update_visual_state() -> void:
	if chisel_mesh:
		chisel_mesh.visible = not is_equipped

func _update_wraith_reference() -> void:
	if not wraith_ref or not is_instance_valid(wraith_ref):
		if is_inside_tree():
			var wraiths = get_tree().get_nodes_in_group("unseen_entity")
			if wraiths.size() > 0:
				wraith_ref = wraiths[0] as Node3D
