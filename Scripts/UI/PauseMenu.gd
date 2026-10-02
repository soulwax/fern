extends CanvasLayer
class_name PauseMenu

signal resumed()

@onready var panel: Panel = $Panel
@onready var fullscreen_check: CheckBox = $Panel/Center/VBox/SettingsBox/SettingsVBox/FullscreenRow/FullscreenCheck
@onready var daguerreotype_check: CheckBox = $Panel/Center/VBox/SettingsBox/SettingsVBox/DaguerreotypeRow/DaguerreotypeCheck
@onready var volume_slider: HSlider = $Panel/Center/VBox/SettingsBox/SettingsVBox/VolumeRow/VolumeSlider
@onready var volume_val_label: Label = $Panel/Center/VBox/SettingsBox/SettingsVBox/VolumeRow/ValLabel
@onready var sfx_slider: HSlider = $Panel/Center/VBox/SettingsBox/SettingsVBox/SfxRow/SfxSlider
@onready var sfx_val_label: Label = $Panel/Center/VBox/SettingsBox/SettingsVBox/SfxRow/ValLabel
@onready var ambiance_slider: HSlider = $Panel/Center/VBox/SettingsBox/SettingsVBox/AmbianceRow/AmbianceSlider
@onready var ambiance_val_label: Label = $Panel/Center/VBox/SettingsBox/SettingsVBox/AmbianceRow/ValLabel
@onready var sensitivity_slider: HSlider = $Panel/Center/VBox/SettingsBox/SettingsVBox/SensRow/SensSlider
@onready var sens_val_label: Label = $Panel/Center/VBox/SettingsBox/SettingsVBox/SensRow/ValLabel

var is_paused: bool = false
var player_ref: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_find_player()
	
	# Fullscreen state
	if fullscreen_check:
		var mode = DisplayServer.window_get_mode()
		fullscreen_check.button_pressed = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)

	# Daguerreotype Post-Processing
	if daguerreotype_check:
		var game_state = get_node_or_null("/root/GameState")
		if game_state:
			daguerreotype_check.button_pressed = game_state.daguerreotype_enabled
		daguerreotype_check.toggled.connect(_on_daguerreotype_toggled)

	
	# Master Bus
	if volume_slider:
		var master_idx = AudioServer.get_bus_index("Master")
		var current_db = AudioServer.get_bus_volume_db(master_idx) if master_idx >= 0 else 0.0
		var linear = db_to_linear(current_db)
		volume_slider.value = linear
		volume_slider.value_changed.connect(_on_volume_changed)
		_on_volume_changed(linear)
		
	# SFX Bus
	if sfx_slider:
		var sfx_idx = AudioServer.get_bus_index("SFX")
		var current_db = AudioServer.get_bus_volume_db(sfx_idx) if sfx_idx >= 0 else 0.0
		var linear = db_to_linear(current_db)
		sfx_slider.value = linear
		sfx_slider.value_changed.connect(_on_sfx_changed)
		_on_sfx_changed(linear)

	# Ambiance Bus
	if ambiance_slider:
		var amb_idx = AudioServer.get_bus_index("Ambiance")
		var current_db = AudioServer.get_bus_volume_db(amb_idx) if amb_idx >= 0 else 0.0
		var linear = db_to_linear(current_db)
		ambiance_slider.value = linear
		ambiance_slider.value_changed.connect(_on_ambiance_changed)
		_on_ambiance_changed(linear)
		
	# Sensitivity
	if sensitivity_slider:
		sensitivity_slider.value = 1.0 # 1.0x baseline
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_on_sensitivity_changed(1.0)

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			toggle_fullscreen()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("ui_cancel"):
		var game_state = get_node_or_null("/root/GameState")
		if game_state and not game_state.is_game_active:
			return
		toggle_pause()

func toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	var is_fs = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	set_fullscreen(not is_fs)

func set_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if fullscreen_check:
		fullscreen_check.button_pressed = enabled

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	set_fullscreen(toggled_on)

func _on_daguerreotype_toggled(toggled_on: bool) -> void:
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		game_state.set_daguerreotype_enabled(toggled_on)

func toggle_pause() -> void:
	set_paused(not is_paused)

func set_paused(paused: bool) -> void:
	is_paused = paused
	visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if fullscreen_check:
			var mode = DisplayServer.window_get_mode()
			fullscreen_check.button_pressed = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		resumed.emit()

func _on_volume_changed(val: float) -> void:
	var idx = AudioServer.get_bus_index("Master")
	if idx >= 0:
		var db = linear_to_db(max(val, 0.0001))
		AudioServer.set_bus_volume_db(idx, db)
	if volume_val_label:
		volume_val_label.text = "%d%%" % int(val * 100)

func _on_sfx_changed(val: float) -> void:
	var idx = AudioServer.get_bus_index("SFX")
	if idx >= 0:
		var db = linear_to_db(max(val, 0.0001))
		AudioServer.set_bus_volume_db(idx, db)
	if sfx_val_label:
		sfx_val_label.text = "%d%%" % int(val * 100)

func _on_ambiance_changed(val: float) -> void:
	var idx = AudioServer.get_bus_index("Ambiance")
	if idx >= 0:
		var db = linear_to_db(max(val, 0.0001))
		AudioServer.set_bus_volume_db(idx, db)
	if ambiance_val_label:
		ambiance_val_label.text = "%d%%" % int(val * 100)

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
