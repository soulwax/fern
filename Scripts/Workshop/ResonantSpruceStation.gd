class_name ResonantSpruceStation
extends Interactable

## Resonant Spruce Soundboard & String Harp (Die Haselfichte & Der Resonanzkasten)
## Unfinished singing-spruce (Haselfichte) soundboard strung with gut wires resting on sawbenches.
## Under Der Alp's supernatural proximity (<5.5m), the strings induce sympathetic acoustic
## resonance, humming with an eerie microtonal drone (soundboard_drone.wav).
## Plucking the harmonic wires ([E], soundboard_pluck.wav) emits a crystalline acoustic shock
## that scrambles the wraith's spatial tracking for 14.0 seconds, breaking hunting locks.

signal soundboard_plucked(duration: float)
signal proximity_hum_started()
signal proximity_hum_stopped()

@export var drone_radius: float = 5.5
@export var scramble_radius: float = 8.0
@export var scramble_duration: float = 14.0
@export var cooldown_duration: float = 18.0

@onready var trestle_mesh: MeshInstance3D = $TrestleMesh
@onready var soundboard_mesh: MeshInstance3D = $SoundboardMesh
@onready var string_mesh: MeshInstance3D = $StringMesh
@onready var drone_audio: AudioStreamPlayer3D = $DroneAudio
@onready var pluck_audio: AudioStreamPlayer3D = $PluckAudio

var current_cooldown: float = 0.0
var is_droning: bool = false
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not trestle_mesh:
		trestle_mesh = get_node_or_null("TrestleMesh")
	if not soundboard_mesh:
		soundboard_mesh = get_node_or_null("SoundboardMesh")
	if not string_mesh:
		string_mesh = get_node_or_null("StringMesh")
	if not drone_audio:
		drone_audio = get_node_or_null("DroneAudio")
	if not pluck_audio:
		pluck_audio = get_node_or_null("PluckAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_prompt()

func _update_prompt() -> void:
	if current_cooldown > 0.0:
		prompt_message = "Spruce Wood Resonating (%ds)" % int(ceil(current_cooldown))
		is_enabled = false
	else:
		prompt_message = "[E] Pluck Singing-Spruce Soundboard"
		is_enabled = true

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
			_update_prompt()
		else:
			prompt_message = "Spruce Wood Resonating (%ds)" % int(ceil(current_cooldown))

	_find_wraith()
	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var my_pos = global_position if is_inside_tree() else position
		var dist = (w_pos - my_pos).length()

		if dist <= drone_radius:
			if not is_droning:
				is_droning = true
				if drone_audio and is_inside_tree() and not drone_audio.playing:
					drone_audio.play()
				proximity_hum_started.emit()
		elif dist > drone_radius + 0.6:
			if is_droning:
				is_droning = false
				if drone_audio and drone_audio.playing:
					drone_audio.stop()
				proximity_hum_stopped.emit()

func _on_interacted(_player: Node) -> void:
	pluck_soundboard()

func pluck_soundboard() -> bool:
	if current_cooldown > 0.0:
		return false

	_ensure_nodes()
	current_cooldown = cooldown_duration

	if pluck_audio and is_inside_tree():
		pluck_audio.play()

	# Animate string vibration
	if string_mesh and is_inside_tree():
		var tween = create_tween()
		tween.tween_property(string_mesh, "scale:y", 1.8, 0.05)
		tween.tween_property(string_mesh, "scale:y", 0.6, 0.08)
		tween.tween_property(string_mesh, "scale:y", 1.0, 0.12)

	_find_wraith()
	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var my_pos = global_position if is_inside_tree() else position
		var dist = (w_pos - my_pos).length()
		if dist <= scramble_radius:
			if wraith_ref.has_method("apply_soundboard_scramble"):
				wraith_ref.apply_soundboard_scramble(scramble_duration)
			elif wraith_ref.has_method("set_scent_masked"):
				wraith_ref.set_scent_masked(scramble_duration)

	_update_prompt()
	soundboard_plucked.emit(scramble_duration)
	return true
