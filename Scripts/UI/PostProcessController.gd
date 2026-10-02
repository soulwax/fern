extends CanvasLayer
class_name PostProcessController

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	layer = 10
	if not color_rect:
		color_rect = get_node_or_null("ColorRect")
	var game_state = get_node_or_null("/root/GameState")
	if not game_state and is_inside_tree() and get_tree() and get_tree().root:
		game_state = get_tree().root.get_node_or_null("GameState")
	if game_state:
		if not game_state.post_processing_toggled.is_connected(_on_post_processing_toggled):
			game_state.post_processing_toggled.connect(_on_post_processing_toggled)
		_on_post_processing_toggled(game_state.daguerreotype_enabled)

func _on_post_processing_toggled(enabled: bool) -> void:
	if not color_rect:
		color_rect = get_node_or_null("ColorRect")
	if color_rect and color_rect.material is ShaderMaterial:
		color_rect.material.set_shader_parameter("enabled", enabled)
