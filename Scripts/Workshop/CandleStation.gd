extends "res://Scripts/Workshop/Interactable.gd"

signal candle_snuffed
signal candle_relit

@export var is_lit: bool = true
@export var base_energy: float = 1.6
@export var flicker_intensity: float = 0.3
@export var detection_radius: float = 3.5

@onready var light: OmniLight3D = $OmniLight3D
@onready var flame_mesh: MeshInstance3D = $FlameMesh
@onready var smoke_particles: GPUParticles3D = $SmokeParticles
@onready var audio_snuff: AudioStreamPlayer3D = $AudioSnuff
@onready var audio_strike: AudioStreamPlayer3D = $AudioStrike
@onready var wraith_detector: Area3D = $WraithDetector

var _time_passed: float = 0.0
var _cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	_update_visual_state(false)
	if wraith_detector:
		wraith_detector.body_entered.connect(_on_body_entered)
		wraith_detector.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
	
	if is_lit and light:
		# Calculate draft intensity from open window breaches
		var windows = get_tree().get_nodes_in_group("window_breach")
		var open_breaches: int = 0
		for w in windows:
			if "current_planks" in w and w.current_planks <= 0:
				open_breaches += 1

		var draft_boost: float = 1.0 + (open_breaches * 0.65)
		var effective_intensity: float = flicker_intensity * draft_boost

		# Calculate entity proximity draft
		var wraith = get_tree().root.find_child("InvisibleWraith", true, false)
		var wraith_dist: float = 999.0
		var draft_dir: Vector3 = Vector3.ZERO
		if wraith and is_instance_valid(wraith):
			var c_pos = global_position if is_inside_tree() else position
			var w_pos = wraith.global_position if wraith.is_inside_tree() else wraith.position
			wraith_dist = c_pos.distance_to(w_pos)
			if wraith_dist < 4.5:
				var push = (c_pos - w_pos)
				push.y = 0.0
				draft_dir = push.normalized() * clampf((4.5 - wraith_dist) / 4.5, 0.0, 1.0)
				effective_intensity += (4.5 - wraith_dist) * 0.25

		_time_passed += delta * (12.0 * draft_boost)
		var flicker = sin(_time_passed) * 0.5 + sin(_time_passed * 2.3) * 0.3 + randf_range(-0.15, 0.15) * draft_boost
		light.light_energy = maxf(0.15, base_energy + flicker * effective_intensity)

		# Tilt flame mesh with draft vector
		if flame_mesh:
			flame_mesh.rotation.x = draft_dir.z * 0.45 + sin(_time_passed * 1.5) * 0.08 * draft_boost
			flame_mesh.rotation.z = -draft_dir.x * 0.45 + cos(_time_passed * 1.8) * 0.08 * draft_boost
			flame_mesh.scale.y = maxf(0.6, 1.0 + sin(_time_passed * 2.5) * 0.18 * draft_boost)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("monster") and is_lit and _cooldown_timer <= 0.0:
		snuff_candle()

func _on_area_entered(area: Node) -> void:
	if area.is_in_group("monster") and is_lit and _cooldown_timer <= 0.0:
		snuff_candle()

func snuff_candle() -> void:
	if not is_lit:
		return
	is_lit = false
	_cooldown_timer = 3.0
	_update_visual_state(true)
	candle_snuffed.emit()

func relight_candle() -> void:
	if is_lit:
		return
	is_lit = true
	_update_visual_state(true)
	candle_relit.emit()

func _update_visual_state(play_audio: bool) -> void:
	if light:
		light.visible = is_lit
	if flame_mesh:
		flame_mesh.visible = is_lit
	
	if is_lit:
		prompt_message = ""
		is_enabled = false
		if play_audio and audio_strike:
			audio_strike.play()
	else:
		prompt_message = "[E] Strike Match & Relight Candle"
		is_enabled = true
		if smoke_particles:
			smoke_particles.restart()
			smoke_particles.emitting = true
		if play_audio and audio_snuff:
			audio_snuff.play()

func _on_interacted(_player: Node) -> void:
	if not is_lit:
		relight_candle()
