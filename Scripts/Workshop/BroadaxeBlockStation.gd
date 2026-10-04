class_name BroadaxeBlockStation
extends Interactable

## Carpenter's Broadaxe & Oak Heartwood Chopping Block (Das Breitbeil im Haublock)
## Heavy hand-forged 19th-century broadaxe embedded in a solid oak chopping block.
## Striking the axe into the heartwood ([E], axe_timber_strike.wav) discharges a grounding
## acoustic-mechanical shockwave through the floorboards, grounding supernatural energy within
## 4.8m on the ground floor and locking Der Alp's visible stag-silhouette for 10.0 seconds.

signal axe_struck(strikes_remaining: int)
signal wraith_grounded(pos: Vector3)

@export var max_strikes: int = 3
@export var current_strikes: int = 3
@export var grounding_radius: float = 4.8
@export var grounding_duration: float = 10.0
@export var reset_cooldown: float = 12.0

@onready var block_mesh: MeshInstance3D = $BlockMesh
@onready var axe_mesh: MeshInstance3D = $AxeMesh
@onready var strike_particles: GPUParticles3D = $StrikeParticles
@onready var axe_audio: AudioStreamPlayer3D = $AxeAudio

var current_cooldown: float = 0.0
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not block_mesh:
		block_mesh = get_node_or_null("BlockMesh")
	if not axe_mesh:
		axe_mesh = get_node_or_null("AxeMesh")
	if not strike_particles:
		strike_particles = get_node_or_null("StrikeParticles")
	if not axe_audio:
		axe_audio = get_node_or_null("AxeAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_prompt()

func _update_prompt() -> void:
	if current_cooldown > 0.0:
		prompt_message = "Freeing Axe Blade (%ds)" % int(ceil(current_cooldown))
		is_enabled = false
	elif current_strikes > 0:
		prompt_message = "[E] Strike Broadaxe into Heartwood (%d/%d)" % [current_strikes, max_strikes]
		is_enabled = true
	else:
		prompt_message = "Blade Deep in Timber (Working free...)"
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
	if current_cooldown > 0.0:
		current_cooldown -= delta
		if current_cooldown <= 0.0:
			current_strikes = max_strikes
			_update_prompt()
		else:
			prompt_message = "Freeing Axe Blade (%ds)" % int(ceil(current_cooldown))

func _on_interacted(_player: Node) -> void:
	strike_axe()

func strike_axe() -> bool:
	if current_cooldown > 0.0 or current_strikes <= 0:
		return false

	_ensure_nodes()
	current_strikes -= 1

	if axe_audio and is_inside_tree():
		axe_audio.play()

	if strike_particles:
		strike_particles.emitting = true

	# Animate broadaxe heavy cleave shudder
	if axe_mesh and is_inside_tree():
		var orig_y = axe_mesh.position.y
		var tween = create_tween()
		tween.tween_property(axe_mesh, "position:y", orig_y - 0.06, 0.05)
		tween.tween_property(axe_mesh, "position:y", orig_y + 0.02, 0.08)
		tween.tween_property(axe_mesh, "position:y", orig_y, 0.12)

	_find_wraith()
	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var my_pos = global_position if is_inside_tree() else position
		var dist = (w_pos - my_pos).length()
		# Only grounds wraith if on or near ground floor (Y < 2.0)
		if dist <= grounding_radius and w_pos.y < 2.0:
			if wraith_ref.has_method("apply_broadaxe_grounding"):
				wraith_ref.apply_broadaxe_grounding(grounding_duration)
			elif wraith_ref.has_method("ignite_with_sparks"):
				wraith_ref.ignite_with_sparks(grounding_duration)
			wraith_grounded.emit(w_pos)

	if current_strikes <= 0:
		current_cooldown = reset_cooldown

	_update_prompt()
	axe_struck.emit(current_strikes)
	return true
