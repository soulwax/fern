class_name BreadOfferingStation
extends Interactable

## Folkloric Appeasement Offering Station (Das Opferbrot)
## Traditional rye bread offering placed on a carved wooden trencher.
## In Germanic folklore, an Alp can be appeased or delayed by placing
## freshly baked rye bread on a table. When Der Alp stalks or hunts,
## it senses the offering and detours to feed for 18 seconds, giving the player vital time.

signal offering_placed(station: Node)
signal offering_consumed(station: Node)

@export var consumption_duration: float = 18.0
@export var cooldown_duration: float = 25.0

@onready var trencher_mesh: MeshInstance3D = $TrencherMesh
@onready var bread_mesh: Node3D = $BreadVisuals
@onready var loaf_mesh: MeshInstance3D = $BreadVisuals/LoafMesh
@onready var crumb_particles: GPUParticles3D = get_node_or_null("CrumbParticles")
@onready var place_audio: AudioStreamPlayer3D = $PlaceAudio
@onready var feed_audio: AudioStreamPlayer3D = $FeedAudio

var is_offering_active: bool = false
var is_being_consumed: bool = false
var consumption_timer: float = 0.0
var cooldown_timer: float = 0.0

func _ensure_nodes() -> void:
	if not trencher_mesh:
		trencher_mesh = get_node_or_null("TrencherMesh")
	if not bread_mesh:
		bread_mesh = get_node_or_null("BreadVisuals")
	if not loaf_mesh and bread_mesh:
		loaf_mesh = bread_mesh.get_node_or_null("LoafMesh")
	if not crumb_particles:
		crumb_particles = get_node_or_null("CrumbParticles")
	if not place_audio:
		place_audio = get_node_or_null("PlaceAudio")
	if not feed_audio:
		feed_audio = get_node_or_null("FeedAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	add_to_group("bread_offering_station")
	_update_visual_state()

func _process(delta: float) -> void:
	_ensure_nodes()
	
	if is_being_consumed:
		consumption_timer -= delta
		prompt_message = "Der Alp is Feeding on the Offering (%.0fs)..." % ceil(max(0.0, consumption_timer))
		is_enabled = false
		
		# Shrink bread visual as it is consumed
		if loaf_mesh:
			var scale_factor = clamp(consumption_timer / consumption_duration, 0.05, 1.0)
			loaf_mesh.scale = Vector3(scale_factor, scale_factor, scale_factor)
			
		if consumption_timer <= 0.0:
			finish_consumption()
		return

	if is_offering_active:
		prompt_message = "Rye Offering Placed (Appeasing Der Alp)"
		is_enabled = false
		return

	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		prompt_message = "Preparing Next Rye Offering (%.0fs)" % ceil(cooldown_timer)
		is_enabled = false
		return

	prompt_message = "[E] Slice & Place Rye Offering on Trencher (Opferbrot)"
	is_enabled = true

func _on_interacted(_player: Node) -> void:
	if not is_offering_active and cooldown_timer <= 0.0 and not is_being_consumed:
		place_offering()

func place_offering() -> void:
	_ensure_nodes()
	is_offering_active = true
	is_being_consumed = false
	consumption_timer = consumption_duration
	
	if bread_mesh:
		bread_mesh.visible = true
	if loaf_mesh:
		loaf_mesh.scale = Vector3.ONE
	if crumb_particles:
		crumb_particles.emitting = true
		
	if place_audio:
		place_audio.pitch_scale = randf_range(0.95, 1.05)
		place_audio.play()
		
	offering_placed.emit(self)
	_update_visual_state()

func start_consumption() -> void:
	_ensure_nodes()
	if not is_offering_active or is_being_consumed:
		return
	is_being_consumed = true
	consumption_timer = consumption_duration
	if crumb_particles:
		crumb_particles.emitting = true
	if feed_audio:
		feed_audio.play()

func finish_consumption() -> void:
	_ensure_nodes()
	is_offering_active = false
	is_being_consumed = false
	cooldown_timer = cooldown_duration
	
	if bread_mesh:
		bread_mesh.visible = false
	if crumb_particles:
		crumb_particles.emitting = false
	if feed_audio and feed_audio.playing:
		feed_audio.stop()
		
	offering_consumed.emit(self)
	_update_visual_state()

func interrupt_consumption() -> void:
	# If wraith is driven off by UV light while eating
	_ensure_nodes()
	if is_being_consumed:
		is_being_consumed = false
		if feed_audio and feed_audio.playing:
			feed_audio.stop()
		if crumb_particles:
			crumb_particles.emitting = false

func _update_visual_state() -> void:
	if bread_mesh:
		bread_mesh.visible = is_offering_active or is_being_consumed
