extends "res://Scripts/Workshop/Interactable.gd"
class_name AnvilStation

signal anvil_struck()

@export var stun_radius: float = 14.0
@export var cooldown_seconds: float = 20.0

@onready var strike_audio: AudioStreamPlayer3D = $StrikeAudio
@onready var shockwave_particles: GPUParticles3D = $ShockwaveParticles

var cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	prompt_message = "[E] Strike Iron Anvil (Repel Unseen)"

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			prompt_message = "[E] Strike Iron Anvil (Repel Unseen)"
			is_enabled = true
		else:
			prompt_message = "Anvil Cooling (%.0fs)" % ceil(cooldown_timer)

func _on_interacted(player: Node) -> void:
	cooldown_timer = cooldown_seconds
	is_enabled = false
	prompt_message = "Anvil Cooling (%.0fs)" % ceil(cooldown_timer)
	
	if strike_audio:
		strike_audio.play()
	if shockwave_particles:
		shockwave_particles.restart()
		shockwave_particles.emitting = true
		
	_repel_entities_in_radius()
	anvil_struck.emit()

func _repel_entities_in_radius() -> void:
	var entities = get_tree().get_nodes_in_group("unseen_entity")
	for e in entities:
		if e is Node3D:
			var dist = global_position.distance_to(e.global_position)
			if dist <= stun_radius:
				if e.has_method("ignite_with_sparks"):
					e.ignite_with_sparks(3.0)
				elif e.has_method("repel_by_holy_runes"):
					e.repel_by_holy_runes()
