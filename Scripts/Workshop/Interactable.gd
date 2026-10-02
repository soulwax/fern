extends Node3D
class_name Interactable

signal interacted(player: Node)

@export var prompt_message: String = "[E] Interact"
@export var is_enabled: bool = true

func _ready() -> void:
	add_to_group("interactable")

func get_interaction_prompt() -> String:
	return prompt_message

func interact(player: Node) -> void:
	if not is_enabled:
		return
	interacted.emit(player)
	_on_interacted(player)

func _on_interacted(_player: Node) -> void:
	# Override in subclass
	pass
