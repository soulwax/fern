extends "res://Scripts/Workshop/Interactable.gd"
class_name DrudenfussThreshold

signal rune_activated(active: bool)
signal entity_repelled(entity: Node)

@export var rune_duration: float = 35.0

@onready var chalk_visual: Node3D = $ChalkVisual
@onready var barrier_area: Area3D = $BarrierArea
@onready var chalk_audio: AudioStreamPlayer3D = $ChalkAudio
@onready var repel_audio: AudioStreamPlayer3D = $RepelAudio
@onready var sulfur_particles: GPUParticles3D = $SulfurParticles
@onready var rune_ring: MeshInstance3D = $ChalkVisual/RuneRing

var is_rune_active: bool = false
var rune_timer: float = 0.0
var uv_glow_boost: float = 0.0

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	prompt_message = "[E] Chalk Protective Drudenfuss Rune"
	_set_rune_active(false)

func _ensure_nodes() -> void:
	if not chalk_visual:
		chalk_visual = get_node_or_null("ChalkVisual")
	if not barrier_area:
		barrier_area = get_node_or_null("BarrierArea")
	if not chalk_audio:
		chalk_audio = get_node_or_null("ChalkAudio")
	if not repel_audio:
		repel_audio = get_node_or_null("RepelAudio")
	if not sulfur_particles:
		sulfur_particles = get_node_or_null("SulfurParticles")
	if not rune_ring and chalk_visual:
		rune_ring = chalk_visual.get_node_or_null("RuneRing")

func _process(delta: float) -> void:
	if is_rune_active:
		rune_timer -= delta
		if rune_timer <= 0.0:
			_set_rune_active(false)
		else:
			_check_barrier_repel()
			
	# Smoothly decay UV glow boost
	if uv_glow_boost > 0.0:
		uv_glow_boost = max(0.0, uv_glow_boost - delta * 2.5)
		_update_rune_emission()

func _on_interacted(player: Node) -> void:
	_ensure_nodes()
	if not is_rune_active:
		_set_rune_active(true)
		if chalk_audio:
			chalk_audio.pitch_scale = randf_range(0.95, 1.05)
			chalk_audio.play()

func _set_rune_active(active: bool) -> void:
	_ensure_nodes()
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
	_update_rune_emission()
	rune_activated.emit(active)

func expose_to_uv_light(_source: Node = null) -> void:
	_ensure_nodes()
	if is_rune_active:
		uv_glow_boost = 1.0
		_update_rune_emission()

func _update_rune_emission() -> void:
	if rune_ring and rune_ring.mesh and rune_ring.mesh.material is StandardMaterial3D:
		var mat = rune_ring.mesh.material as StandardMaterial3D
		var base_energy = 1.5 if is_rune_active else 0.0
		mat.emission_energy_multiplier = base_energy + (uv_glow_boost * 3.5)

func _check_barrier_repel() -> void:
	_ensure_nodes()
	if not barrier_area:
		return
	var bodies = barrier_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("unseen_entity"):
			if body.has_method("repel_by_holy_runes"):
				body.repel_by_holy_runes()
				if sulfur_particles:
					sulfur_particles.restart()
					sulfur_particles.emitting = true
				if repel_audio and not repel_audio.playing:
					repel_audio.pitch_scale = randf_range(0.92, 1.08)
					repel_audio.play()
				entity_repelled.emit(body)
