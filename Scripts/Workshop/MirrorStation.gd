extends Area3D
class_name MirrorStation

signal mirror_wiped()

@export var is_wiped_clean: bool = false

@onready var mirror_mesh: MeshInstance3D = $MirrorQuad
@onready var wipe_audio: AudioStreamPlayer3D = $WipeAudio
@onready var sub_viewport: SubViewport = $SubViewport
@onready var reflection_cam: Camera3D = $SubViewport/ReflectionCamera

var mirror_mat: StandardMaterial3D = null

func _ready() -> void:
	_ensure_components()
	_update_mirror_clarity()

func _ensure_components() -> void:
	if not mirror_mesh:
		mirror_mesh = get_node_or_null("MirrorQuad")
	if not wipe_audio:
		wipe_audio = get_node_or_null("WipeAudio")
	if not sub_viewport:
		sub_viewport = get_node_or_null("SubViewport")
	if not reflection_cam and sub_viewport:
		reflection_cam = sub_viewport.get_node_or_null("ReflectionCamera")
		
	if mirror_mesh:
		var mat = mirror_mesh.get_surface_override_material(0)
		if mat is StandardMaterial3D:
			mirror_mat = mat
		elif sub_viewport:
			mirror_mat = StandardMaterial3D.new()
			mirror_mat.albedo_texture = sub_viewport.get_texture()
			mirror_mesh.set_surface_override_material(0, mirror_mat)

func _process(_delta: float) -> void:
	# Keep reflection camera aligned with mirror normal in global space
	if reflection_cam:
		reflection_cam.global_transform = global_transform

func _update_mirror_clarity() -> void:
	if not mirror_mat and mirror_mesh:
		_ensure_components()
	if mirror_mat:
		if is_wiped_clean:
			mirror_mat.albedo_color = Color(0.92, 0.96, 1.0, 1.0)
			mirror_mat.roughness = 0.04
			mirror_mat.metallic = 0.95
		else:
			mirror_mat.albedo_color = Color(0.55, 0.60, 0.65, 0.85)
			mirror_mat.roughness = 0.38
			mirror_mat.metallic = 0.70

func get_interaction_prompt() -> String:
	if not is_wiped_clean:
		return "[E] Wipe soot from Silvered Mirror"
	return "Silvered Mirror of Truth (Clear)"

func interact(_player: Node3D) -> void:
	if not is_wiped_clean:
		wipe_mirror()

func wipe_mirror() -> void:
	_ensure_components()
	is_wiped_clean = true
	_update_mirror_clarity()
	
	if wipe_audio and is_inside_tree():
		wipe_audio.pitch_scale = randf_range(0.95, 1.05)
		wipe_audio.play()
		
	mirror_wiped.emit()
