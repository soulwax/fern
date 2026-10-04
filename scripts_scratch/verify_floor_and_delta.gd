extends SceneTree

func _init() -> void:
	print("--- Running Verification for Floor Height & Delta Fixes ---")
	
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	var workshop = main.get_node_or_null("Workshop")
	assert(workshop != null, "Workshop must exist in Main.tscn")
	print("Workshop transform origin: ", workshop.position)
	assert(abs(workshop.position.y - (-11.42)) < 0.1, "Workshop must be translated down by ~11.42m to align ground floor")
	assert(abs(workshop.position.x - (-1.17)) < 0.1, "Workshop must be centered in X")
	assert(abs(workshop.position.z - 7.21) < 0.1, "Workshop must be centered in Z")
	
	var player = main.get_node_or_null("Player")
	assert(player != null, "Player must exist in Main.tscn")
	print("Initial player global_pos: ", player.global_position)
	assert(player.global_position.y >= 0.0, "Player must spawn at or above floor level")
	
	# Test 1: Physics simulation with typical delta (0.0166s)
	print("\n[Test 1] Simulating 10 regular physics frames (delta = 0.0166s)...")
	for i in range(10):
		player._physics_process(0.0166)
	print("Player after 10 regular frames: pos=", player.global_position, " vel=", player.velocity)
	assert(player.global_position.y >= 0.0, "Player must not fall below floor (Y >= 0.0)")
	
	# Test 2: Physics simulation with extreme lag spike / frame stutter (delta = 0.5s and 1.0s)
	print("\n[Test 2] Simulating extreme lag spike deltas (0.5s and 1.0s)...")
	player._physics_process(0.5)
	print("Player after delta=0.5s: pos=", player.global_position, " vel=", player.velocity)
	assert(player.global_position.y >= 0.0, "Player must not fall through floor on 0.5s delta spike")
	
	player._physics_process(1.0)
	print("Player after delta=1.0s: pos=", player.global_position, " vel=", player.velocity)
	assert(player.global_position.y >= 0.0, "Player must not fall through floor on 1.0s delta spike")
	
	# Test 3: Safeguard test - simulate player forced below floor
	print("\n[Test 3] Testing abyss rescue safeguard when forced to Y = -2.0...")
	player.global_position.y = -2.0
	player.position.y = -2.0
	player._enforce_floor_safety()
	print("Player after floor safety rescue: pos=", player.global_position, " vel=", player.velocity)
	assert(player.global_position.y >= 0.0, "Player must be rescued back above floor")
	assert(player.velocity == Vector3.ZERO, "Velocity must be reset to zero on rescue")
	
	# Test 4: Verify v0.0.7 stations in Main scene
	print("\n[Test 4] Verifying v0.0.7 stations in Main scene...")
	var bell_rope = main.get_node_or_null("BellRopeStation")
	assert(bell_rope != null, "BellRopeStation must be present in Main.tscn")
	var linseed_lamp = main.get_node_or_null("LinseedLampStation")
	assert(linseed_lamp != null, "LinseedLampStation must be present in Main.tscn")
	var incense_censer = main.get_node_or_null("IncenseCenserStation")
	assert(incense_censer != null, "IncenseCenserStation must be present in Main.tscn")
	print("All v0.0.7 stations present and verified!")
	
	print("\n*** ALL TESTS PASSED: Floor height aligned and delta physics rock-solid! ***")
	main.queue_free()
	quit(0)
