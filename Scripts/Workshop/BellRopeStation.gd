class_name BellRopeStation
extends Interactable

## Belfry Bell-Rope Shockwave (Der Glockenstrick & Der Sakrale Schallstoß)
## Heavy hemp bell-pull rope descending through a timber ceiling sleeve from the roof belfry.
## Pulling the cord ([E], bell_rope_pull.wav) rings the heavy bronze bell (belfry_chime.wav).
## The concussive acoustic shockwave reverberates through the rafters, stunning any unseen
## presence clinging overhead (Y > 2.2m) for 3.0s and forcing it violently down onto the floorboards.

signal belfry_rung()
signal rafter_entity_stunned(pos: Vector3)

@export var cooldown_duration: float = 12.0
@export var rafter_threshold_y: float = 2.2
@export var stun_duration: float = 3.0
@export var acoustic_radius: float = 16.0

@onready var rope_mesh: MeshInstance3D = $RopeMesh
@onready var collar_mesh: MeshInstance3D = $CollarMesh
@onready var rope_audio: AudioStreamPlayer3D = $RopeAudio
@onready var chime_audio: AudioStreamPlayer3D = $ChimeAudio

var current_cooldown: float = 0.0
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not rope_mesh:
		rope_mesh = get_node_or_null("RopeMesh")
	if not collar_mesh:
		collar_mesh = get_node_or_null("CollarMesh")
	if not rope_audio:
		rope_audio = get_node_or_null("RopeAudio")
	if not chime_audio:
		chime_audio = get_node_or_null("ChimeAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	prompt_message = "[E] Pull Belfry Bell-Rope"
	is_enabled = true

func _find_wraith() -> void:
	if not is_inside_tree():
		return
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	if wraiths.size() > 0:
		wraith_ref = wraiths[0]

func _process(delta: float) -> void:
	_ensure_nodes()
	if current_cooldown > 0.0:
		current_cooldown -= delta
		if current_cooldown <= 0.0:
			prompt_message = "[E] Pull Belfry Bell-Rope"
			is_enabled = true
		else:
			prompt_message = "Bell Resonating (%ds)" % int(ceil(current_cooldown))
			is_enabled = false

func _on_interacted(_player: Node) -> void:
	pull_rope()

func pull_rope() -> bool:
	if current_cooldown > 0.0:
		return false

	_ensure_nodes()
	current_cooldown = cooldown_duration
	prompt_message = "Bell Resonating"
	is_enabled = false

	if rope_audio and is_inside_tree():
		rope_audio.play()

	if chime_audio and is_inside_tree():
		chime_audio.play()

	belfry_rung.emit()

	# Acoustic rafter shockwave
	if not wraith_ref or not is_instance_valid(wraith_ref):
		_find_wraith()

	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var my_pos = global_position if is_inside_tree() else position
		var dist = (w_pos - my_pos).length()

		if dist <= acoustic_radius and w_pos.y >= rafter_threshold_y:
			# Force entity descent and stun
			if wraith_ref.has_method("ignite_with_sparks"):
				wraith_ref.ignite_with_sparks(stun_duration)
			elif wraith_ref.has_method("set_state"):
				wraith_ref.set_state(wraith_ref.State.STUNNED)

			# Enforce downward rafter denial
			if wraith_ref.has_method("set_rafter_denial"):
				wraith_ref.set_rafter_denial(15.0)

			wraith_ref.velocity.y = -6.0
			rafter_entity_stunned.emit(w_pos)

	return true
