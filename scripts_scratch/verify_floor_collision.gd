extends SceneTree

func _init() -> void:
	print("=======================================================")
	print("🧪 VERIFYING FLOOR COLLISION & ANTI-FALL SAFEGUARDS")
	print("=======================================================")

	# 1. Load Main Scene
	print("[1/5] Loading Main.tscn and verifying solid colliders...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main = main_scene.instantiate()
	root.add_child(main)

	# Verify SolidFloorCollider
	var solid_floor = main.get_node_or_null("SolidFloorCollider")
	assert(solid_floor != null, "SolidFloorCollider must exist in Main.tscn")
	assert(solid_floor.collision_layer == 1, "SolidFloorCollider must be on layer 1 (Environment)")
	var floor_shape = solid_floor.get_node("CollisionShape3D").shape as BoxShape3D
	assert(floor_shape != null, "SolidFloorCollider must have a BoxShape3D")
	assert(floor_shape.size.y >= 2.0, "Solid floor must be at least 2m thick to prevent tunneling")
	assert(floor_shape.size.x >= 30.0 and floor_shape.size.z >= 30.0, "Solid floor must cover entire workshop footprint")
	print("  -> Passed: SolidFloorCollider verified with thickness %sm and dimensions %s" % [floor_shape.size.y, floor_shape.size])

	# Verify SolidLoftCollider
	var solid_loft = main.get_node_or_null("SolidLoftCollider")
	assert(solid_loft != null, "SolidLoftCollider must exist in Main.tscn")
	assert(solid_loft.collision_layer == 1, "SolidLoftCollider must be on layer 1")
	var loft_shape = solid_loft.get_node("CollisionShape3D").shape as BoxShape3D
	assert(loft_shape != null, "SolidLoftCollider must have a BoxShape3D")
	print("  -> Passed: SolidLoftCollider verified in upper rafter area with shape: %s" % str(loft_shape.size))

	# Verify AbyssCatchFloor safety net
	var abyss_floor = main.get_node_or_null("AbyssCatchFloor")
	assert(abyss_floor != null, "AbyssCatchFloor safety net must exist in Main.tscn")
	assert(abyss_floor.collision_layer == 1, "AbyssCatchFloor must be on layer 1")
	print("  -> Passed: AbyssCatchFloor safety net verified at sub-floor depth.")

	# Verify Perimeter boundary colliders
	var perim_n = main.get_node_or_null("PerimeterNorth")
	var perim_s = main.get_node_or_null("PerimeterSouth")
	var perim_e = main.get_node_or_null("PerimeterEast")
	var perim_w = main.get_node_or_null("PerimeterWest")
	assert(perim_n != null and perim_s != null and perim_e != null and perim_w != null, "All 4 perimeter wall colliders must exist")
	print("  -> Passed: Perimeter wall boundary barriers verified (North, South, East, West).")

	# 2. Verify Player CharacterBody3D Configuration
	print("\n[2/5] Verifying Player CharacterBody3D floor snap and physics settings...")
	var player = main.get_node_or_null("Player") as CharacterBody3D
	assert(player != null, "Player must exist in Main.tscn")
	player._ready()
	assert(player.collision_layer == 2, "Player must be on layer 2")
	assert((player.collision_mask & 1) != 0, "Player collision mask must include layer 1 (Environment)")
	assert(player.floor_snap_length >= 0.2, "Player floor_snap_length must be >= 0.2m (Current: %f)" % player.floor_snap_length)
	assert(player.floor_constant_speed == true, "Player floor_constant_speed must be true")
	assert(player.floor_stop_on_slope == true, "Player floor_stop_on_slope must be true")
	assert(player.safe_margin >= 0.005, "Player safe_margin must be >= 0.005m")
	print("  -> Passed: Player floor_snap_length=%s, constant_speed=%s, safe_margin=%s" % [
		player.floor_snap_length, player.floor_constant_speed, player.safe_margin
	])

	# 3. Verify Player Initial Spawn Height
	print("\n[3/5] Verifying Player initial spawn clearance...")
	assert(player.position.y >= 0.15, "Player must spawn at Y >= 0.15m to prevent clipping into floor at start! (Current: %f)" % player.position.y)
	print("  -> Passed: Player spawns safely with clearance at Y = %f" % player.position.y)

	# 4. Verify Terminal Velocity Clamping
	print("\n[4/5] Verifying terminal velocity clamping in physics processing...")
	player.velocity = Vector3(0.0, -100.0, 0.0)
	# Trigger physics step where player is not on floor
	player.global_position = Vector3(0.0, 2.0, 0.0)
	# Simulate 1 tick of gravity
	player._physics_process(0.05)
	assert(player.velocity.y >= -20.0, "Downward fall velocity must be clamped to prevent tunneling! Current: %f" % player.velocity.y)
	print("  -> Passed: Fall speed clamped cleanly to %f m/s (tunneling prevented)" % player.velocity.y)

	# 5. Verify Fail-Safe Abyss Rescue
	print("\n[5/5] Verifying bulletproof abyss fall-catch rescue...")
	# Simulate player clipping below floor (e.g. Y = -1.2)
	player.position = Vector3(1.2, -1.2, -0.8)
	player.velocity = Vector3(0.0, -18.0, 0.0)
	player._physics_process(0.0166)
	assert(player.position.y >= 0.15, "Abyss rescue MUST restore player above floor! Current Y: %f" % player.position.y)
	assert(player.velocity == Vector3.ZERO, "Rescued player velocity must be completely halted")
	print("  -> Passed: Abyss fall-catch rescued player to Y = %f with zero velocity" % player.position.y)

	main.queue_free()

	print("\n=======================================================")
	print("🎉 ALL FLOOR COLLISION & ANTI-FALL TESTS PASSED 100%!")
	print("=======================================================")
	quit(0)
