class_name ZincBasinStation
extends Interactable

## Zinc Rainwater Basin & Acoustic Droplet Resonator (Das Zink-Regenfass)
## Authentic 19th-century galvanized zinc rainwater tub catching cold mountain runoff.
## Drips with periodic metallic pings (drip_tap.wav).
## When Der Alp stalks across the roof or ceiling catwalk rafters overhead (Y > 2.4m, radius < 4.0m),
## its electrostatic aura arrests the surface tension, triggering a sudden violent splash (water_splash.wav).
## Players can also interact ([E]) to draw fresh water and revive the Farnblume.

signal drip_pinged()
signal overhead_anomaly_detected()
signal water_refilled()

@export var drip_interval: float = 1.3
@export var rafter_detect_radius: float = 4.0
@export var rafter_detect_height: float = 2.4

@onready var basin_mesh: MeshInstance3D = $BasinMesh
@onready var water_mesh: MeshInstance3D = $WaterMesh
@onready var drip_audio: AudioStreamPlayer3D = $DripAudio
@onready var splash_audio: AudioStreamPlayer3D = $SplashAudio

var drip_timer: float = 0.0
var splash_cooldown: float = 0.0
var is_drip_arrested: bool = false
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not basin_mesh:
		basin_mesh = get_node_or_null("BasinMesh")
	if not water_mesh:
		water_mesh = get_node_or_null("WaterMesh")
	if not drip_audio:
		drip_audio = get_node_or_null("DripAudio")
	if not splash_audio:
		splash_audio = get_node_or_null("SplashAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	prompt_message = "[E] Collect Rainwater for Farnblume"
	is_enabled = true
	drip_timer = drip_interval

func _find_wraith() -> void:
	if not is_inside_tree():
		return
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	if wraiths.size() > 0:
		wraith_ref = wraiths[0]

func _process(delta: float) -> void:
	_ensure_nodes()

	if splash_cooldown > 0.0:
		splash_cooldown -= delta

	if not wraith_ref or not is_instance_valid(wraith_ref):
		_find_wraith()

	var is_overhead = false
	if wraith_ref and is_instance_valid(wraith_ref):
		var my_pos = global_position if is_inside_tree() else position
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var dx = w_pos.x - my_pos.x
		var dz = w_pos.z - my_pos.z
		var dist_xz = sqrt(dx * dx + dz * dz)
		if dist_xz <= rafter_detect_radius and w_pos.y >= rafter_detect_height:
			is_overhead = true

	if is_overhead:
		if not is_drip_arrested:
			is_drip_arrested = true
			if splash_cooldown <= 0.0:
				splash_cooldown = 4.5
				if splash_audio and is_inside_tree():
					splash_audio.play()
				overhead_anomaly_detected.emit()
	else:
		is_drip_arrested = false
		drip_timer -= delta
		if drip_timer <= 0.0:
			drip_timer = drip_interval
			if drip_audio and is_inside_tree():
				drip_audio.play()
			drip_pinged.emit()

func _on_interacted(player: Node) -> void:
	collect_water(player)

func collect_water(player: Node = null) -> void:
	_ensure_nodes()
	if splash_audio and is_inside_tree():
		splash_audio.play()

	# Replenish Farnblume if player or flower controller is found
	if player:
		var flower = player.get_node_or_null("Farnblume")
		if not flower:
			flower = player.get_node_or_null("Camera3D/Farnblume")
		if flower and flower.has_method("restore_luminescence"):
			flower.restore_luminescence()
		elif player.has_method("revive_flower"):
			player.revive_flower()

	water_refilled.emit()
