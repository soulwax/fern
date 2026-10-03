extends SceneTree

func _init() -> void:
	print("==================================================")
	print("🌿 FERN v1.6.0 WORKSHOP SIEGE & WINDOW TEST SUITE")
	print("==================================================")
	
	# Instance GameState Autoload
	var game_state = load("res://Scripts/GameState.gd").new()
	game_state.name = "GameState"
	root.add_child(game_state)

	var pass_count = 0
	var total_tests = 7
	
	# Test 1: WindowBreachPoint Scene & Audio Bus Routing
	var wb_scene = load("res://Scenes/Workshop/WindowBreachPoint.tscn")
	var wb_inst = wb_scene.instantiate() if wb_scene else null
	if wb_inst != null:
		root.add_child(wb_inst)
		var hammer = wb_inst.get_node_or_null("HammerAudio") as AudioStreamPlayer3D
		var rattle = wb_inst.get_node_or_null("RattleAudio") as AudioStreamPlayer3D
		var draft = wb_inst.get_node_or_null("DraftAudio") as AudioStreamPlayer3D
		assert(hammer != null, "HammerAudio must exist")
		assert(rattle != null, "RattleAudio must exist")
		assert(draft != null, "DraftAudio must exist")
		assert(hammer.bus == &"SFX", "HammerAudio must route to SFX bus")
		assert(rattle.bus == &"SFX", "RattleAudio must route to SFX bus")
		assert(draft.bus == &"Ambiance", "DraftAudio must route to Ambiance bus")
		assert(wb_inst.current_planks == 2, "Default planks should be 2")
		print("✅ TEST 1 PASSED: WindowBreachPoint scene has correct audio nodes & bus routing.")
		pass_count += 1
		wb_inst.queue_free()
	else:
		printerr("❌ TEST 1 FAILED: Failed to instantiate WindowBreachPoint.tscn.")

	# Test 2: Window Rattle Animation & Timer
	wb_inst = wb_scene.instantiate()
	if wb_inst != null:
		root.add_child(wb_inst)
		wb_inst.start_rattle(3.0)
		assert(wb_inst.is_rattling == true, "start_rattle should set is_rattling")
		assert(wb_inst.rattle_timer == 3.0, "rattle_timer should be 3.0")
		wb_inst.stop_rattle()
		assert(wb_inst.is_rattling == false, "stop_rattle should clear is_rattling")
		print("✅ TEST 2 PASSED: start_rattle and stop_rattle operate accurately.")
		pass_count += 1
		wb_inst.queue_free()
	else:
		printerr("❌ TEST 2 FAILED: Failed to test window rattle.")

	# Test 3: Plank Breach Mechanic
	wb_inst = wb_scene.instantiate()
	if wb_inst != null:
		root.add_child(wb_inst)
		assert(wb_inst.current_planks == 2)
		var breached_1 = wb_inst.breach_plank()
		assert(breached_1 == true, "First breach should succeed")
		assert(wb_inst.current_planks == 1, "Planks should decrement to 1")
		var breached_2 = wb_inst.breach_plank()
		assert(breached_2 == true, "Second breach should succeed")
		assert(wb_inst.current_planks == 0, "Planks should decrement to 0")
		var breached_3 = wb_inst.breach_plank()
		assert(breached_3 == false, "Breach when 0 planks should return false")
		print("✅ TEST 3 PASSED: breach_plank accurately reduces fortifications.")
		pass_count += 1
		wb_inst.queue_free()
	else:
		printerr("❌ TEST 3 FAILED: Failed to test breach mechanics.")

	# Test 4: Player Repair Sequence
	wb_inst = wb_scene.instantiate()
	if wb_inst != null:
		root.add_child(wb_inst)
		wb_inst.current_planks = 0
		wb_inst._update_visuals()
		wb_inst._update_draft()
		assert(wb_inst.is_fully_fortified() == false)
		
		# Repair 1
		wb_inst._on_interacted(null)
		assert(wb_inst.current_planks == 1)
		# Repair 2
		wb_inst._on_interacted(null)
		assert(wb_inst.current_planks == 2)
		# Repair 3
		wb_inst._on_interacted(null)
		assert(wb_inst.current_planks == 3)
		assert(wb_inst.is_fully_fortified() == true)
		print("✅ TEST 4 PASSED: Player interaction repairs planks up to maximum 3.")
		pass_count += 1
		wb_inst.queue_free()
	else:
		printerr("❌ TEST 4 FAILED: Failed to test repair sequence.")

	# Test 5: GameState Wilt Penalty Calculation
	game_state.open_window_breaches = 0
	assert(game_state.get_breach_wilt_penalty() == 1.0, "Initial penalty must be 1.0")
	game_state.notify_window_breached()
	assert(game_state.open_window_breaches == 1)
	assert(is_equal_approx(game_state.get_breach_wilt_penalty(), 1.20), "1 breach = 1.20x penalty")
	game_state.notify_window_breached()
	assert(game_state.open_window_breaches == 2)
	assert(is_equal_approx(game_state.get_breach_wilt_penalty(), 1.40), "2 breaches = 1.40x penalty")
	game_state.notify_window_repaired()
	assert(game_state.open_window_breaches == 1)
	assert(is_equal_approx(game_state.get_breach_wilt_penalty(), 1.20))
	game_state.notify_window_repaired()
	assert(game_state.open_window_breaches == 0)
	assert(is_equal_approx(game_state.get_breach_wilt_penalty(), 1.0))
	print("✅ TEST 5 PASSED: GameState wilt rate scales with open breaches (+20% each).")
	pass_count += 1

	# Test 6: WraithAI Siege State & UV Light Repulsion
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	var wraith = wraith_scene.instantiate() if wraith_scene else null
	var siege_window = wb_scene.instantiate()
	if wraith != null and siege_window != null:
		root.add_child(siege_window)
		root.add_child(wraith)
		wraith.target_window = siege_window
		wraith.set_state(WraithAI.State.SIEGE)
		assert(wraith.current_state == WraithAI.State.SIEGE, "Wraith should enter State.SIEGE")
		assert(siege_window.is_rattling == true, "Target window should be rattling during siege")
		
		# Shine UV light at wraith
		wraith.expose_to_uv_light(wraith)
		assert(wraith.current_state == WraithAI.State.REPELLED, "UV exposure during siege must repel wraith")
		assert(siege_window.is_rattling == false, "Window rattling must halt when wraith is repelled")
		print("✅ TEST 6 PASSED: WraithAI enters SIEGE, rattles window, and is repelled by UV light.")
		pass_count += 1
		wraith.queue_free()
		siege_window.queue_free()
	else:
		printerr("❌ TEST 6 FAILED: Failed to test WraithAI siege mechanics.")

	# Test 7: Main.tscn Scene Assembly with Perimeter Windows
	var main_scene = load("res://Scenes/Main.tscn")
	var main_inst = main_scene.instantiate() if main_scene else null
	if main_inst != null:
		root.add_child(main_inst)
		var north = main_inst.get_node_or_null("WindowBreachNorth")
		var east = main_inst.get_node_or_null("WindowBreachEast")
		var west = main_inst.get_node_or_null("WindowBreachWest")
		assert(north != null, "WindowBreachNorth must exist in Main.tscn")
		assert(east != null, "WindowBreachEast must exist in Main.tscn")
		assert(west != null, "WindowBreachWest must exist in Main.tscn")
		assert(north.is_in_group("window_breach"), "North window must be in window_breach group")
		assert(east.is_in_group("window_breach"), "East window must be in window_breach group")
		assert(west.is_in_group("window_breach"), "West window must be in window_breach group")
		print("✅ TEST 7 PASSED: Main.tscn has all 3 perimeter windows configured in group.")
		pass_count += 1
		main_inst.queue_free()
	else:
		printerr("❌ TEST 7 FAILED: Failed to instantiate Main.tscn.")

	print("==================================================")
	print("RESULTS: %d / %d TESTS PASSED" % [pass_count, total_tests])
	print("==================================================")

	if pass_count == total_tests:
		print("🎉 ALL v1.6.0 WORKSHOP SIEGE & WINDOW TESTS PASSED!")
		quit(0)
	else:
		printerr("⚠️ SOME TESTS FAILED.")
		quit(1)
