@tool
extends SceneTree

func _init():
	var scene_path = "res://Assets/LeartesStudios/CarpentersWorkshop/Art/Scenes/Carpenter's_Workshop.scn"
	var packed_scene = load(scene_path)
	var inst = packed_scene.instantiate()
	root.add_child(inst)
	
	print("--- SEARCHING KEY NODES & BOUNDS ---")
	var grindstones = []
	var doors = []
	var windows = []
	var anvils = []
	var workbenches = []
	
	var aabb = AABB()
	var first = true
	
	var stack = [inst]
	while stack.size() > 0:
		var curr = stack.pop_back()
		var n_name = curr.name.to_lower()
		if "grindstone" in n_name:
			grindstones.append({"name": curr.name, "pos": curr.global_position})
		elif "door" in n_name:
			doors.append({"name": curr.name, "pos": curr.global_position})
		elif "window" in n_name:
			windows.append({"name": curr.name, "pos": curr.global_position})
		elif "workbench" in n_name:
			workbenches.append({"name": curr.name, "pos": curr.global_position})
		elif "anvil" in n_name:
			anvils.append({"name": curr.name, "pos": curr.global_position})
			
		if curr is VisualInstance3D:
			var box = curr.get_aabb()
			if box.size != Vector3.ZERO:
				var gbox = curr.global_transform * box
				if first:
					aabb = gbox
					first = false
				else:
					aabb = aabb.merge(gbox)
		
		for c in curr.get_children():
			stack.push_back(c)
			
	print("World Bounds: pos=", aabb.position, " size=", aabb.size)
	print("Grindstones found: ", grindstones)
	print("Workbenches found (first 5): ", workbenches.slice(0, 5))
	print("Doors found (first 5): ", doors.slice(0, 5))
	print("Windows count: ", windows.size())
	
	inst.queue_free()
	quit(0)
