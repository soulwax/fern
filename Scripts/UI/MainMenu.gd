extends Control

@onready var start_btn: Button = $Center/VBox/StartBtn
@onready var difficulty_btn: Button = $Center/VBox/DifficultyBox/DifficultyBtn
@onready var difficulty_desc: Label = $Center/VBox/DifficultyBox/DifficultyDesc
@onready var guide_btn: Button = $Center/VBox/GuideBtn
@onready var quit_btn: Button = $Center/VBox/QuitBtn
@onready var folklore_guide: FolkloreGuide = $FolkloreGuideModal

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if start_btn:
		start_btn.grab_focus()
	_update_difficulty_ui()

func _get_game_state() -> Node:
	if is_inside_tree() and get_tree().root:
		return get_tree().root.get_node_or_null("GameState")
	return null

func _update_difficulty_ui() -> void:
	var game_state = _get_game_state()
	if game_state and difficulty_btn and difficulty_desc:
		difficulty_btn.text = "Modus: %s" % game_state.get_difficulty_name()
		difficulty_desc.text = game_state.get_difficulty_description()

func _on_difficulty_pressed() -> void:
	var game_state = _get_game_state()
	if game_state:
		var current = int(game_state.current_difficulty)
		var next_diff = (current + 1) % 3
		game_state.set_difficulty(next_diff as GameState.Difficulty)
		_update_difficulty_ui()

func _on_start_pressed() -> void:
	# Transition to Main game scene
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_guide_pressed() -> void:
	if folklore_guide:
		folklore_guide.open_guide()

func _on_quit_pressed() -> void:
	get_tree().quit()
