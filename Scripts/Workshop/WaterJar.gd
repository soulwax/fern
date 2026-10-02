extends "res://Scripts/Workshop/Interactable.gd"
class_name WaterJar

signal bloom_replenished()

@onready var water_audio: AudioStreamPlayer3D = $WaterAudio
@onready var water_surface: MeshInstance3D = $WaterSurface

func _ready() -> void:
	super._ready()
	prompt_message = "[E] Dip Farnblume in Spring Water"

func _on_interacted(player: Node) -> void:
	if not player:
		return
		
	var farnblume = player.find_child("Farnblume", true, false)
	if farnblume and farnblume.has_method("replenish_in_water"):
		farnblume.replenish_in_water()
		if water_audio:
			water_audio.pitch_scale = randf_range(0.95, 1.05)
			water_audio.play()
		_animate_water_ripple()
		bloom_replenished.emit()

func _animate_water_ripple() -> void:
	if water_surface:
		var tween = create_tween()
		tween.tween_property(water_surface, "scale", Vector3(1.15, 1.0, 1.15), 0.25)
		tween.tween_property(water_surface, "scale", Vector3(1.0, 1.0, 1.0), 0.4)
