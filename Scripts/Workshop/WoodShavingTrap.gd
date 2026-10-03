class_name WoodShavingTrap
extends Node3D

## Curly Pine Shaving Soundtrap (Die Hobelspäne-Falle)
## Piles of dry carpenter shavings that crunch and rustle loudly when
## trampled by Der Alp or the player, allowing precise auditory triangulation.

signal shavings_stepped_on(pos: Vector3, by_wraith: bool)

@export var trigger_radius: float = 1.25

@onready var crunch_audio: AudioStreamPlayer3D = $CrunchAudio
@onready var dust_puff: GPUParticles3D = $DustPuff
@onready var shavings_mesh: MeshInstance3D = $ShavingsMesh

var step_cooldown: float = 0.0
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not crunch_audio:
		crunch_audio = get_node_or_null("CrunchAudio")
	if not dust_puff:
		dust_puff = get_node_or_null("DustPuff")
	if not shavings_mesh:
		shavings_mesh = get_node_or_null("ShavingsMesh")

func _ready() -> void:
	_ensure_nodes()

func _process(delta: float) -> void:
	_ensure_nodes()
	if step_cooldown > 0.0:
		step_cooldown -= delta

	if step_cooldown <= 0.0:
		_check_trample()

func _check_trample() -> void:
	_update_wraith_reference()

	var trap_pos = global_position if is_inside_tree() else position

	# Check wraith trample
	if wraith_ref and is_instance_valid(wraith_ref):
		var wraith_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var horiz_dist = Vector2(trap_pos.x - wraith_pos.x, trap_pos.z - wraith_pos.z).length()
		var is_ground = absf(trap_pos.y - wraith_pos.y) < 1.4

		var is_moving = false
		if "velocity" in wraith_ref:
			is_moving = wraith_ref.velocity.length() > 0.3
		else:
			is_moving = true

		if is_ground and horiz_dist <= trigger_radius and is_moving:
			trigger_crunch(true)
			return

func trigger_crunch(by_wraith: bool = true) -> void:
	_ensure_nodes()
	step_cooldown = 0.45

	if crunch_audio and crunch_audio.is_inside_tree():
		crunch_audio.pitch_scale = randf_range(0.92, 1.08)
		crunch_audio.play()

	if dust_puff:
		dust_puff.restart()
		dust_puff.emitting = true

	var trap_pos = global_position if is_inside_tree() else position
	shavings_stepped_on.emit(trap_pos, by_wraith)

func _update_wraith_reference() -> void:
	if wraith_ref and is_instance_valid(wraith_ref):
		return
	var main_tree = get_tree()
	if main_tree:
		wraith_ref = main_tree.root.find_child("InvisibleWraith", true, false)
