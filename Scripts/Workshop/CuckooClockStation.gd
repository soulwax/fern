class_name CuckooClockStation
extends Interactable

## Black Forest Cuckoo Automaton (Die Schwarzwald-Kuckucksuhr)
## Authentic 19th-century carved wooden clock with mechanical escapement,
## whistle bellows, and spring-loaded carved bird automaton.
## When Der Alp creeps within 6.0m, the delicate wooden gears chatter and jam violently,
## providing a crucial domestic acoustic alarm before an ambush.

signal cuckoo_called()
signal automaton_jammed()
signal automaton_rewound()

@export var jam_detection_radius: float = 6.0

@onready var clock_case: MeshInstance3D = $ClockCase
@onready var bird_door: Node3D = $BirdDoor
@onready var pendulum: Node3D = $Pendulum
@onready var weight_left: Node3D = $WeightLeft
@onready var weight_right: Node3D = $WeightRight
@onready var cuckoo_audio: AudioStreamPlayer3D = $CuckooAudio
@onready var jam_audio: AudioStreamPlayer3D = $JamAudio

var is_jammed: bool = false
var jam_cooldown: float = 0.0
var pendulum_time: float = 0.0
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not clock_case:
		clock_case = get_node_or_null("ClockCase")
	if not bird_door:
		bird_door = get_node_or_null("BirdDoor")
	if not pendulum:
		pendulum = get_node_or_null("Pendulum")
	if not weight_left:
		weight_left = get_node_or_null("WeightLeft")
	if not weight_right:
		weight_right = get_node_or_null("WeightRight")
	if not cuckoo_audio:
		cuckoo_audio = get_node_or_null("CuckooAudio")
	if not jam_audio:
		jam_audio = get_node_or_null("JamAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_visual_state()

func _process(delta: float) -> void:
	_ensure_nodes()
	
	if jam_cooldown > 0.0:
		jam_cooldown -= delta

	if is_jammed:
		prompt_message = "[E] Rewind Cuckoo Clock Mechanism"
		is_enabled = true
		if pendulum:
			# Jittery arrested pendulum
			pendulum.rotation_degrees.z = randf_range(-1.5, 1.5)
	else:
		prompt_message = "Cuckoo Clock Escapement Active"
		is_enabled = false
		pendulum_time += delta * 4.5
		if pendulum:
			pendulum.rotation_degrees.z = sin(pendulum_time) * 14.0
		
		if jam_cooldown <= 0.0:
			_check_wraith_proximity()

func _check_wraith_proximity() -> void:
	_update_wraith_reference()
	if not wraith_ref or not is_instance_valid(wraith_ref):
		return

	var clock_pos = global_position if is_inside_tree() else position
	var wraith_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position

	var dist = clock_pos.distance_to(wraith_pos)
	if dist <= jam_detection_radius:
		trigger_jam()

func trigger_jam() -> void:
	_ensure_nodes()
	is_jammed = true
	jam_cooldown = 15.0
	
	if bird_door:
		bird_door.rotation_degrees.y = 45.0 # Partial door pop
	if jam_audio and is_inside_tree():
		jam_audio.pitch_scale = randf_range(0.95, 1.05)
		jam_audio.play()

	_update_visual_state()
	automaton_jammed.emit()

func trigger_cuckoo() -> void:
	_ensure_nodes()
	if is_jammed:
		return
	if bird_door:
		bird_door.rotation_degrees.y = 90.0 # Full open
	if cuckoo_audio and is_inside_tree():
		cuckoo_audio.pitch_scale = randf_range(0.98, 1.02)
		cuckoo_audio.play()
	cuckoo_called.emit()

func rewind_mechanism() -> void:
	_ensure_nodes()
	is_jammed = false
	jam_cooldown = 8.0
	if bird_door:
		bird_door.rotation_degrees.y = 0.0 # Shut door
	if weight_left:
		weight_left.position.y = -0.25
	if weight_right:
		weight_right.position.y = -0.28
	_update_visual_state()
	automaton_rewound.emit()

func _on_interacted(_player: Node) -> void:
	if is_jammed:
		rewind_mechanism()

func _update_visual_state() -> void:
	if bird_door and not is_jammed:
		bird_door.rotation_degrees.y = 0.0

func _update_wraith_reference() -> void:
	if not wraith_ref or not is_instance_valid(wraith_ref):
		if is_inside_tree():
			var wraiths = get_tree().get_nodes_in_group("unseen_entity")
			if wraiths.size() > 0:
				wraith_ref = wraiths[0] as Node3D
