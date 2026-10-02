extends "res://Scripts/Workshop/Interactable.gd"
class_name DrudenfussThreshold

signal rune_activated(active: bool)

@export var rune_duration: float = 35.0

@onready var chalk_visual: Node3D = $ChalkVisual
@onready var barrier_area: Area3D = $BarrierArea
@onready var chalk_audio: AudioStreamPlayer3D = $ChalkAudio

var is_rune_active: bool = false
var rune_timer: float = 0.0

func _ready() -> void:
	super._ready()
	prompt_message = "[E] Chalk Protective Drudenfuss Rune"
	_set_rune_active(false)

func _process(delta: float) -> void:
	if is_rune_active:
		rune_timer -= delta
		if rune_timer <= 0.0:
			_set_rune_active(false)
		else:
			_check_barrier_repel()

func _on_interacted(player: Node) -> void:
	if not is_rune_active:
		_set_rune_active(true)
		if chalk_audio:
			chalk_audio.play()

func _set_rune_active(active: bool) -> void:
	is_rune_active = active
	if is_rune_active:
		rune_timer = rune_duration
		prompt_message = "Drudenfuss Active (Warding Threshold)"
		is_enabled = false
	else:
		prompt_message = "[E] Chalk Protective Drudenfuss Rune"
		is_enabled = true
		
	if chalk_visual:
		chalk_visual.visible = active
	rune_activated.emit(active)

func _check_barrier_repel() -> void:
	if not barrier_area:
		return
	var bodies = barrier_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("unseen_entity"):
			if body.has_method("repel_by_holy_runes"):
				body.repel_by_holy_runes()
