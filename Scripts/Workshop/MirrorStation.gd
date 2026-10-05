extends Area3D
class_name MirrorStation

signal mirror_wiped()

@export var is_wiped_clean: bool = false

@onready var mirror_mesh: MeshInstance3D = $MirrorQuad
@onready var wipe_audio: AudioStreamPlayer3D = $WipeAudio
@onready var sub_viewport: SubViewport = $SubViewport
@onready var reflection_cam: Camera3D = $SubViewport/ReflectionCamera

const MIRROR_UPDATE_RANGE := 6.0
const MIRROR_LOOK_DOT := 0.25
const MIRROR_REFRESH_FRAMES := 3
const HIDDEN_FROM_MIRROR_LAYER := 524288

var mirror_mat: StandardMaterial3D = null
var _frames_until_refresh: int = 0
var _player: Node3D = null

func _ready() -> void:
	_ensure_components()
	_configure_reflection()
	_hide_player_and_particles_from_mirror()
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

func _configure_reflection() -> void:
	if sub_viewport:
		sub_viewport.size = Vector2i(256, 256)
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	if reflection_cam:
		reflection_cam.far = 12.0
		reflection_cam.cull_mask = 524287

func _hide_player_and_particles_from_mirror() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	for node in tree.root.find_children("*", "GPUParticles3D", true, false):
		if node is VisualInstance3D:
			node.layers = HIDDEN_FROM_MIRROR_LAYER
	for player in tree.get_nodes_in_group("player"):
		for mesh in player.find_children("*", "GeometryInstance3D", true, false):
			mesh.layers = HIDDEN_FROM_MIRROR_LAYER

func _process(_delta: float) -> void:
	if not reflection_cam or not sub_viewport:
		_ensure_components()
	if not reflection_cam or not sub_viewport:
		return
	if _mirror_should_update():
		reflection_cam.global_transform = global_transform
		if _frames_until_refresh <= 0:
			sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
			_frames_until_refresh = MIRROR_REFRESH_FRAMES
		else:
			_frames_until_refresh -= 1
	else:
		_frames_until_refresh = 0
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _mirror_should_update() -> bool:
	var player := _get_player()
	if player == null:
		return false
	var cam := player.get_node_or_null("Head/Camera3D") as Camera3D
	var origin := cam.global_position if cam else player.global_position
	var to_mirror := global_position - origin
	if to_mirror.length() > MIRROR_UPDATE_RANGE:
		return false
	if cam == null or to_mirror.length_squared() < 0.0001:
		return true
	var forward := -cam.global_basis.z
	return forward.dot(to_mirror.normalized()) > MIRROR_LOOK_DOT

func _get_player() -> Node3D:
	if is_instance_valid(_player):
		return _player
	if not is_inside_tree():
		return null
	var players := get_tree().get_nodes_in_group("player")
	_player = players[0] as Node3D if players.size() > 0 else null
	return _player

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
