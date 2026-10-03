extends Node3D

signal lightning_flashed()

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var moon_light: DirectionalLight3D = $Moonlight
@onready var church_bell_audio: AudioStreamPlayer = $Audio/ChurchBellAudio
@onready var day_birds_audio: AudioStreamPlayer = $Audio/DayBirdsAudio
@onready var dawn_sun_light: DirectionalLight3D = $DawnSunlight
@onready var lightning_light: DirectionalLight3D = $LightningLight
@onready var thunder_audio: AudioStreamPlayer = $Audio/ThunderAudio

var lightning_timer: float = 30.0
var is_flashing: bool = false

func _ready() -> void:
	_ensure_nodes()
	if dawn_sun_light:
		dawn_sun_light.visible = false
		dawn_sun_light.light_energy = 0.0
	if lightning_light:
		lightning_light.light_energy = 0.0

	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		game_state.ambient_bell_tolled.connect(_on_bell_tolled)
		game_state.game_won.connect(_on_victory_dawn)
		game_state.game_lost.connect(_on_defeat)

func _ensure_nodes() -> void:
	if not world_environment:
		world_environment = get_node_or_null("WorldEnvironment")
	if not moon_light:
		moon_light = get_node_or_null("Moonlight")
	if not church_bell_audio:
		church_bell_audio = get_node_or_null("Audio/ChurchBellAudio")
	if not day_birds_audio:
		day_birds_audio = get_node_or_null("Audio/DayBirdsAudio")
	if not dawn_sun_light:
		dawn_sun_light = get_node_or_null("DawnSunlight")
	if not lightning_light:
		lightning_light = get_node_or_null("LightningLight")
	if not thunder_audio:
		thunder_audio = get_node_or_null("Audio/ThunderAudio")

func _process(delta: float) -> void:
	_ensure_nodes()
	var game_state = get_node_or_null("/root/GameState")
	if game_state and game_state.is_game_active:
		lightning_timer -= delta
		if lightning_timer <= 0.0:
			trigger_lightning()
			var min_wait = 25.0 if game_state.current_difficulty == game_state.Difficulty.WALPURGISNACHT else 38.0
			var max_wait = 45.0 if game_state.current_difficulty == game_state.Difficulty.WALPURGISNACHT else 60.0
			lightning_timer = randf_range(min_wait, max_wait)

func trigger_lightning() -> void:
	_ensure_nodes()
	if not lightning_light:
		return
	is_flashing = true
	lightning_flashed.emit()
	
	# Twin peak natural lightning flash
	var tween = create_tween()
	tween.tween_property(lightning_light, "light_energy", 4.5, 0.05)
	tween.tween_property(lightning_light, "light_energy", 0.6, 0.06)
	tween.tween_property(lightning_light, "light_energy", 3.8, 0.08)
	tween.tween_property(lightning_light, "light_energy", 0.0, 0.35)
	tween.tween_callback(func(): is_flashing = false)
	
	# Distant thunder rumble
	if thunder_audio and is_inside_tree():
		var timer = get_tree().create_timer(0.45)
		timer.timeout.connect(func():
			if thunder_audio and is_inside_tree():
				thunder_audio.pitch_scale = randf_range(0.92, 1.08)
				thunder_audio.play()
		)

func _on_bell_tolled() -> void:
	if church_bell_audio:
		church_bell_audio.pitch_scale = randf_range(0.96, 1.04)
		church_bell_audio.play()

func _on_victory_dawn() -> void:
	# Flood room with warm morning light
	if dawn_sun_light:
		dawn_sun_light.visible = true
		var tween = create_tween()
		tween.tween_property(dawn_sun_light, "light_energy", 3.2, 4.0)
		
	# Play morning birds singing from Assets/Audio/Ambiance
	if day_birds_audio:
		day_birds_audio.play()

func _on_defeat() -> void:
	# Dim lighting to absolute black
	var tween = create_tween()
	if moon_light:
		tween.tween_property(moon_light, "light_energy", 0.0, 1.5)
