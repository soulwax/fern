extends Node3D
class_name FarnblumeController

signal bloom_energy_changed(current_energy: float, max_energy: float)
signal cupped_state_changed(is_cupped: bool)

@export var max_energy: float = 100.0
@export var deplete_rate: float = 2.5
@export var cupped_recovery_rate: float = 5.0
@export var water_refill_amount: float = 100.0

@export var beam_range: float = 9.0
@export var beam_angle: float = 34.0
@export var full_spot_energy: float = 3.5
@export var full_omni_energy: float = 1.2

@onready var spot_light: SpotLight3D = $SpotLight3D
@onready var omni_light: OmniLight3D = $OmniLight3D
@onready var detection_shapecast: ShapeCast3D = $ShapeCast3D
@onready var flower_mesh: Node3D = $FlowerModel
@onready var hum_audio: AudioStreamPlayer3D = $HumAudio

var current_energy: float = 100.0
var is_cupped: bool = false
var target_flower_scale: Vector3 = Vector3.ONE

func _ready() -> void:
	current_energy = max_energy
	if spot_light:
		spot_light.spot_range = beam_range
		spot_light.spot_angle = beam_angle
	bloom_energy_changed.emit(current_energy, max_energy)

func _process(delta: float) -> void:
	# Input toggle for cupping the bloom (R key)
	if Input.is_action_just_pressed("flower_cup"):
		set_cupped(not is_cupped)
		
	# Energy management
	if is_cupped:
		# Cupped hands recover energy slowly
		current_energy = min(max_energy, current_energy + cupped_recovery_rate * delta)
	else:
		# Active bloom burns energy scaled by difficulty
		var wilt_mult = 1.0
		var game_state = get_node_or_null("/root/GameState")
		if game_state and game_state.has_method("get_wilt_rate_multiplier"):
			wilt_mult = game_state.get_wilt_rate_multiplier()
		current_energy = max(0.0, current_energy - deplete_rate * delta * wilt_mult)

	bloom_energy_changed.emit(current_energy, max_energy)
	
	# Light power scaling
	var energy_ratio = current_energy / max_energy
	var effective_ratio = energy_ratio if not is_cupped else energy_ratio * 0.15
	
	if spot_light:
		spot_light.light_energy = full_spot_energy * effective_ratio
		spot_light.visible = (effective_ratio > 0.02)
		
	if omni_light:
		omni_light.light_energy = full_omni_energy * (0.3 + 0.7 * effective_ratio)

	# Slight procedural flower breathing
	if flower_mesh:
		var breath = sin(Time.get_ticks_msec() * 0.003) * 0.04
		var cupped_shrink = 0.55 if is_cupped else 1.0
		flower_mesh.scale = Vector3.ONE * (cupped_shrink + breath * energy_ratio)

	# Wraith UV detection
	_detect_unseen_entities()

func set_cupped(cupped: bool) -> void:
	is_cupped = cupped
	cupped_state_changed.emit(is_cupped)

func replenish_in_water() -> void:
	current_energy = max_energy
	bloom_energy_changed.emit(current_energy, max_energy)

func _detect_unseen_entities() -> void:
	if is_cupped or current_energy <= 5.0:
		return
		
	if not detection_shapecast:
		return
		
	detection_shapecast.force_shapecast_update()
	if detection_shapecast.is_colliding():
		for i in range(detection_shapecast.get_collision_count()):
			var collider = detection_shapecast.get_collider(i)
			if collider and collider.is_in_group("unseen_entity"):
				if collider.has_method("expose_to_uv_light"):
					collider.expose_to_uv_light(self)
