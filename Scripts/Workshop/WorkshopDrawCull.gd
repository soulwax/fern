class_name WorkshopDrawCull
extends RefCounted

const _LARGE_SIDE := 0.8
const _TINY_SIDE := 0.35
const _MIN_BATCH := 8
const _TINY_VISIBILITY_END := 8.0
const _TINY_VISIBILITY_MARGIN := 1.5

static func apply(workshop: Node) -> void:
	if workshop == null:
		return
	var players := workshop.find_children("*", "AnimationPlayer", true, false)
	var meshes := workshop.find_children("*", "MeshInstance3D", true, false)
	var batches: Dictionary = {}

	for node in meshes:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null or _should_skip(mesh_instance, workshop):
			continue
		var side := _longest_side(mesh_instance)
		if side > _LARGE_SIDE:
			continue
		if side < _TINY_SIDE:
			var key := _batch_key(mesh_instance)
			if key.is_empty():
				_apply_tiny(mesh_instance)
				continue
			var group: Array = batches.get(key, [])
			group.append(mesh_instance)
			batches[key] = group
		else:
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	for key in batches.keys():
		var group: Array = batches[key]
		if group.size() >= _MIN_BATCH:
			_build_multimesh(workshop, group)
		else:
			for item in group:
				_apply_tiny(item as MeshInstance3D)

	for node in players:
		if is_instance_valid(node):
			node.queue_free()

static func _should_skip(mesh_instance: MeshInstance3D, workshop: Node) -> bool:
	if mesh_instance.mesh == null:
		return true
	if mesh_instance.get_script() != null:
		return true
	if mesh_instance.get_groups().size() > 0:
		return true
	var parent := mesh_instance.get_parent()
	while parent != null and parent != workshop:
		if parent is CollisionObject3D:
			return true
		parent = parent.get_parent()
	return false

static func _longest_side(mesh_instance: MeshInstance3D) -> float:
	var world_aabb := mesh_instance.global_transform * mesh_instance.get_aabb()
	var size := world_aabb.size
	return maxf(size.x, maxf(size.y, size.z))

static func _batch_key(mesh_instance: MeshInstance3D) -> String:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return ""
	var parts: PackedStringArray = PackedStringArray()
	parts.append(str(mesh.get_instance_id()))
	for surface in mesh.get_surface_count():
		var material := mesh_instance.get_active_material(surface)
		parts.append(str(material.get_instance_id()) if material else "0")
	return "|".join(parts)

static func _apply_tiny(mesh_instance: MeshInstance3D) -> void:
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.visibility_range_end = _TINY_VISIBILITY_END
	mesh_instance.visibility_range_end_margin = _TINY_VISIBILITY_MARGIN
	mesh_instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED

static func _build_multimesh(workshop: Node, group: Array) -> void:
	var first := group[0] as MeshInstance3D
	if first == null or first.mesh == null:
		return
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = _mesh_with_materials(first)
	multi.instance_count = group.size()

	var instance := MultiMeshInstance3D.new()
	instance.name = "Batched_%s" % first.name
	instance.multimesh = multi
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	workshop.add_child(instance)

	var to_local := instance.global_transform.affine_inverse()
	for index in group.size():
		var source := group[index] as MeshInstance3D
		if source == null:
			continue
		multi.set_instance_transform(index, to_local * source.global_transform)
		source.queue_free()

static func _mesh_with_materials(source: MeshInstance3D) -> Mesh:
	var mesh := source.mesh
	if mesh == null:
		return null
	var needs_copy := false
	for surface in mesh.get_surface_count():
		var active := source.get_active_material(surface)
		if active and active != mesh.surface_get_material(surface):
			needs_copy = true
			break
	if not needs_copy:
		return mesh
	var copied := mesh.duplicate() as Mesh
	if copied == null:
		return mesh
	for surface in copied.get_surface_count():
		var active := source.get_active_material(surface)
		if active:
			copied.surface_set_material(surface, active)
	return copied
