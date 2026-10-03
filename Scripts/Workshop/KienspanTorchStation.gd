class_name KienspanTorchStation
extends Interactable

## Kienspan Resin Pitch Torch Station (Die Pechfackel)
## 19th-century Black Forest pine pitch torch mounted in a forged wall sconce.
## When ignited, casts intense warm firelight and mobile protection aura
## that deters and repels Der Alp during candle outages.

signal torch_ignited()
signal torch_extinguished()
signal wraith_repelled(torch_pos: Vector3)

@export var max_burn_duration: float = 25.0
@export var recharge_cooldown: float = 12.0
@export var repel_radius: float = 4.2
@export var light_energy_base: float = 2.4

@onready var sconce_mesh: MeshInstance3D = $SconceMesh
@onready var torch_mesh: Node3D = $TorchMesh
@onready var flame_particles: GPUParticles3D = $TorchMesh/FlameParticles
@onready var torch_light: OmniLight3D = $TorchMesh/TorchLight
@onready var burn_audio: AudioStreamPlayer3D = $TorchMesh/BurnAudio

var is_lit: bool = false
var is_held: bool = false
var burn_timer: float = 0.0
var cooldown_timer: float = 0.0
var player_ref: Node3D = null
var wraith_ref: Node3D = null
var flicker_time: float = 0.0

var original_torch_parent: Node = null
var original_torch_transform: Transform3D

func _ensure_nodes() -> void:
	if not sconce_mesh:
		sconce_mesh = get_node_or_null("SconceMesh")
	if not torch_mesh:
		torch_mesh = get_node_or_null("TorchMesh")
	if torch_mesh:
		if not flame_particles:
			flame_particles = torch_mesh.get_node_or_null("FlameParticles")
		if not torch_light:
			torch_light = torch_mesh.get_node_or_null("TorchLight")
		if not burn_audio:
			burn_audio = torch_mesh.get_node_or_null("BurnAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	if torch_mesh:
		original_torch_parent = torch_mesh.get_parent()
		original_torch_transform = torch_mesh.transform
	_update_visual_state()

func _process(delta: float) -> void:
	_ensure_nodes()
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		prompt_message = "Preparing Pine Pitch Torch (%.0fs)" % ceil(cooldown_timer)
		is_enabled = false
		return

	if is_lit:
		burn_timer -= delta
		flicker_time += delta * 12.0
		if torch_light:
			torch_light.light_energy = light_energy_base + sin(flicker_time) * 0.45 + randf_range(-0.15, 0.15)
		
		# Proximity check against Der Alp
		_check_repel_wraith()

		if is_held:
			prompt_message = "[E] Place Torch in Sconce (%.0fs left)" % ceil(burn_timer)
		else:
			prompt_message = "[E] Take Burning Torch (%.0fs left)" % ceil(burn_timer)
		is_enabled = true

		if burn_timer <= 0.0:
			extinguish_torch()
	else:
		prompt_message = "[E] Take & Light Kienspan Torch"
		is_enabled = true

func _on_interacted(player: Node) -> void:
	_ensure_nodes()
	if cooldown_timer > 0.0:
		return

	if not is_lit:
		ignite_torch(player)
	elif is_held:
		return_to_sconce()
	else:
		take_torch(player)

func ignite_torch(player: Node) -> void:
	_ensure_nodes()
	is_lit = true
	burn_timer = max_burn_duration
	take_torch(player)
	_update_visual_state()
	if burn_audio and is_inside_tree():
		burn_audio.play()
	torch_ignited.emit()

func take_torch(player: Node) -> void:
	is_held = true
	player_ref = player as Node3D
	# Attach to player camera if present
	if player_ref and is_inside_tree() and torch_mesh:
		var cam = player_ref.get_node_or_null("Head/Camera3D")
		if cam:
			torch_mesh.reparent(cam)
			torch_mesh.transform = Transform3D.IDENTITY
			torch_mesh.position = Vector3(-0.35, -0.22, -0.45)
			torch_mesh.rotation_degrees = Vector3(-15, 12, 10)

func return_to_sconce() -> void:
	is_held = false
	if torch_mesh and original_torch_parent and is_inside_tree():
		torch_mesh.reparent(original_torch_parent)
		torch_mesh.transform = original_torch_transform

func extinguish_torch() -> void:
	_ensure_nodes()
	is_lit = false
	is_held = false
	burn_timer = 0.0
	cooldown_timer = recharge_cooldown
	return_to_sconce()
	_update_visual_state()
	if burn_audio and burn_audio.playing:
		burn_audio.stop()
	torch_extinguished.emit()

func _update_visual_state() -> void:
	if flame_particles:
		flame_particles.emitting = is_lit
	if torch_light:
		torch_light.visible = is_lit
		if is_lit:
			torch_light.light_energy = light_energy_base

func _check_repel_wraith() -> void:
	if not is_lit:
		return
	_update_wraith_reference()
	if not wraith_ref or not is_instance_valid(wraith_ref):
		return

	var torch_pos = global_position if is_inside_tree() else position
	if is_held and player_ref:
		torch_pos = player_ref.global_position if player_ref.is_inside_tree() else player_ref.position
	var wraith_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position

	var dist = torch_pos.distance_to(wraith_pos)
	if dist <= repel_radius:
		if wraith_ref.has_method("repel_by_torch"):
			wraith_ref.repel_by_torch(torch_pos)
		elif wraith_ref.has_method("repel_by_horseshoe"):
			wraith_ref.repel_by_horseshoe(torch_pos)
		elif wraith_ref.has_method("repel_by_holy_runes"):
			wraith_ref.repel_by_holy_runes()
		wraith_repelled.emit(torch_pos)

func _update_wraith_reference() -> void:
	if not wraith_ref or not is_instance_valid(wraith_ref):
		if is_inside_tree():
			var wraiths = get_tree().get_nodes_in_group("unseen_entity")
			if wraiths.size() > 0:
				wraith_ref = wraiths[0] as Node3D
