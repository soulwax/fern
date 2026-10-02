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
		_time_passed += delta * 12.0
		var flicker = sin(_time_passed) * 0.5 + sin(_time_passed * 2.3) * 0.3 + randf_range(-0.1, 0.1)
		light.light_energy = maxf(0.2, base_energy + flicker * flicker_intensity)

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
