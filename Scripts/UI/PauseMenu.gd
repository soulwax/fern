extends CanvasLayer
class_name PauseMenu

signal resumed()

@onready var panel: Panel = $Panel
@onready var volume_slider: HSlider = $Panel/Center/VBox/SettingsBox/SettingsVBox/VolumeRow/VolumeSlider
@onready var sensitivity_slider: HSlider = $Panel/Center/VBox/SettingsBox/SettingsVBox/SensRow/SensSlider
@onready var volume_val_label: Label = $Panel/Center/VBox/SettingsBox/SettingsVBox/VolumeRow/ValLabel
@onready var sens_val_label: Label = $Panel/Center/VBox/SettingsBox/SettingsVBox/SensRow/ValLabel

var is_paused: bool = false
var player_ref: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_find_player()
	
	if volume_slider:
		var current_bus_db = AudioServer.get_bus_volume_db(0)
		var linear = db_to_linear(current_bus_db)
		volume_slider.value = linear
		volume_slider.value_changed.connect(_on_volume_changed)
		_on_volume_changed(linear)
		
	if sensitivity_slider:
		sensitivity_slider.value = 1.0 # 1.0x baseline
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_on_sensitivity_changed(1.0)

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Check if game is not over/won
		var game_state = get_node_or_null("/root/GameState")
		if game_state and not game_state.is_game_active:
			return
		toggle_pause()

func toggle_pause() -> void:
	set_paused(not is_paused)

func set_paused(paused: bool) -> void:
	is_paused = paused
	visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		resumed.emit()

func _on_volume_changed(val: float) -> void:
	var db = linear_to_db(max(val, 0.0001))
	AudioServer.set_bus_volume_db(0, db)
	if volume_val_label:
		volume_val_label.text = "%d%%" % int(val * 100)

func _on_sensitivity_changed(val: float) -> void:
	if not player_ref:
		_find_player()
	if player_ref and "mouse_sensitivity" in player_ref:
		player_ref.mouse_sensitivity = 0.0022 * val
	if sens_val_label:
		sens_val_label.text = "%.1fx" % val

func _on_resume_pressed() -> void:
	set_paused(false)

func _on_restart_pressed() -> void:
	set_paused(false)
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	set_paused(false)
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
