extends "res://Scripts/Workshop/Interactable.gd"
class_name GrindStone

signal sparks_fired(active: bool)

@export var spark_cone_range: float = 7.0
@export var spark_duration: float = 2.0
@export var rotation_speed: float = 8.0

@onready var wheel_mesh: Node3D = $Wheel
@onready var spark_particles: GPUParticles3D = $SparkParticles
@onready var spark_hit_area: Area3D = $SparkHitArea
@onready var grind_audio: AudioStreamPlayer3D = $GrindAudio

var is_spinning: bool = false
var spin_timer: float = 0.0

func _ready() -> void:
	super._ready()
	prompt_message = "[E] Spin Grindstone (Spray Sparks)"
	if spark_particles:
		spark_particles.emitting = false

func _process(delta: float) -> void:
	if is_spinning:
		spin_timer -= delta
		if wheel_mesh:
			wheel_mesh.rotate_x(rotation_speed * delta)
		
		# Check for unseen entity in spark cone
		_check_spark_hits()
		
		if spin_timer <= 0.0:
			_stop_sparks()

func _on_interacted(player: Node) -> void:
	_trigger_sparks()

func _trigger_sparks() -> void:
	is_spinning = true
	spin_timer = spark_duration
	if spark_particles:
		spark_particles.emitting = true
	if grind_audio and not grind_audio.playing:
		grind_audio.play()
	sparks_fired.emit(true)

func _stop_sparks() -> void:
	is_spinning = false
	if spark_particles:
		spark_particles.emitting = false
	if grind_audio and grind_audio.playing:
		grind_audio.stop()
	sparks_fired.emit(false)

func _check_spark_hits() -> void:
	if not spark_hit_area:
		return
	var bodies = spark_hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("unseen_entity"):
			if body.has_method("ignite_with_sparks"):
				body.ignite_with_sparks(2.5)
