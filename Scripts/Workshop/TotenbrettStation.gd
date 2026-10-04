class_name TotenbrettStation
extends Interactable

## Ancestral Memorial Death Planks Station (Die Totenbretter)
## In Black Forest tradition, woodcarvers kept memorial planks inscribed with
## ancestral prayers and folk runes. When consecrated with cold chisel and oil,
## the carved runes flare with sacred violet luminescence.
## When Der Alp enters within 3.5m, the ancestral ward erupts, repelling the creature for 4.0s.

signal totenbrett_consecrated(duration: float)
signal totenbrett_ward_discharged()

@export var ward_duration: float = 40.0
@export var repel_distance: float = 3.5

@onready var plank_mesh: MeshInstance3D = $PlankMesh
@onready var rune_light: OmniLight3D = $RuneLight
@onready var ward_particles: GPUParticles3D = get_node_or_null("WardParticles")
@onready var consecrate_audio: AudioStreamPlayer3D = $ConsecrateAudio

var is_consecrated: bool = false
var ward_timer: float = 0.0

func _ensure_nodes() -> void:
	if not plank_mesh:
		plank_mesh = get_node_or_null("PlankMesh")
	if not rune_light:
		rune_light = get_node_or_null("RuneLight")
	if not ward_particles:
		ward_particles = get_node_or_null("WardParticles")
	if not consecrate_audio:
		consecrate_audio = get_node_or_null("ConsecrateAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	add_to_group("totenbrett_station")
	_update_visuals()

func _process(delta: float) -> void:
	_ensure_nodes()
	if is_consecrated:
		ward_timer -= delta
		prompt_message = "Ancestral Ward Active (%.0fs)" % ceil(max(0.0, ward_timer))
		is_enabled = false
		
		# Pulse rune light gently
		if rune_light:
			rune_light.light_energy = 1.8 + 0.4 * sin(Time.get_ticks_msec() * 0.005)
			
		_check_for_approaching_wraith()
		
		if ward_timer <= 0.0:
			discharge_ward()
		return
		
	prompt_message = "[E] Inscribe & Consecrate Totenbrett (Ancestral Ward)"
	is_enabled = true

func _on_interacted(_player: Node) -> void:
	if not is_consecrated:
		consecrate_totenbrett()

func consecrate_totenbrett() -> void:
	_ensure_nodes()
	is_consecrated = true
	ward_timer = ward_duration
	
	if consecrate_audio:
		consecrate_audio.pitch_scale = randf_range(0.98, 1.02)
		consecrate_audio.play()
		
	if rune_light:
		rune_light.visible = true
	if ward_particles:
		ward_particles.emitting = true
		
	totenbrett_consecrated.emit(ward_duration)
	_update_visuals()

func _check_for_approaching_wraith() -> void:
	if not is_inside_tree():
		return
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	for w in wraiths:
		if is_instance_valid(w):
			var cur_p = global_position if is_inside_tree() else position
			var wr_p = w.global_position if w.is_inside_tree() else w.position
			var d = cur_p.distance_to(wr_p)
			if d <= repel_distance:
				# Repel Der Alp!
				if w.has_method("set_state") and w.current_state != WraithAI.State.REPELLED:
					if w.has_method("_play_screech"):
						w._play_screech()
					w.set_state(WraithAI.State.REPELLED)
					totenbrett_ward_discharged.emit()

func discharge_ward() -> void:
	_ensure_nodes()
	is_consecrated = false
	ward_timer = 0.0
	if rune_light:
		rune_light.visible = false
	if ward_particles:
		ward_particles.emitting = false
	totenbrett_ward_discharged.emit()
	_update_visuals()

func _update_visuals() -> void:
	if rune_light:
		rune_light.visible = is_consecrated
	if ward_particles:
		ward_particles.emitting = is_consecrated
