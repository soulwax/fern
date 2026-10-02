extends CanvasLayer
class_name FolkloreGuide

signal closed()

@onready var close_btn: Button = $Panel/Center/VBox/CloseBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func open_guide() -> void:
	visible = true

func close_guide() -> void:
	visible = false
	closed.emit()

func _on_close_pressed() -> void:
	close_guide()
