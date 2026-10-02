extends "res://Scripts/Workshop/Interactable.gd"
class_name WindowBreach

signal fortified(status: bool)

@export var max_planks: int = 3
@export var current_planks: int = 0

@onready var plank_visual_1: Node3D = $Planks/Plank1
@onready var plank_visual_2: Node3D = $Planks/Plank2
@onready var plank_visual_3: Node3D = $Planks/Plank3
@onready var hammer_audio: AudioStreamPlayer3D = $HammerAudio

func _ready() -> void:
	super._ready()
	_update_visuals()

func _update_visuals() -> void:
	if plank_visual_1:
		plank_visual_1.visible = (current_planks >= 1)
	if plank_visual_2:
		plank_visual_2.visible = (current_planks >= 2)
	if plank_visual_3:
		plank_visual_3.visible = (current_planks >= 3)
		
	if current_planks < max_planks:
		prompt_message = "[E] Nail Timber Plank (%d/%d)" % [current_planks, max_planks]
		is_enabled = true
	else:
		prompt_message = "Window Fully Barricaded"
		is_enabled = false

func _on_interacted(player: Node) -> void:
	if current_planks < max_planks:
		current_planks += 1
		if hammer_audio:
			hammer_audio.pitch_scale = randf_range(0.9, 1.1)
			hammer_audio.play()
		_update_visuals()
		fortified.emit(current_planks >= max_planks)
