extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var moon_light: DirectionalLight3D = $Moonlight
@onready var church_bell_audio: AudioStreamPlayer = $Audio/ChurchBellAudio
@onready var day_birds_audio: AudioStreamPlayer = $Audio/DayBirdsAudio
@onready var dawn_sun_light: DirectionalLight3D = $DawnSunlight

func _ready() -> void:
	if dawn_sun_light:
		dawn_sun_light.visible = false
		dawn_sun_light.light_energy = 0.0

	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		game_state.ambient_bell_tolled.connect(_on_bell_tolled)
		game_state.game_won.connect(_on_victory_dawn)
		game_state.game_lost.connect(_on_defeat)

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
