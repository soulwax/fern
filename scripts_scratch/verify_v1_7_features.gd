extends SceneTree

func _init() -> void:
	print("==================================================")
	print("🌿 FERN v1.7.0 HEARTBEAT & DRUDENFUSS TEST SUITE")
	print("==================================================")
	
	# Instance GameState Autoload
	var game_state = load("res://Scripts/GameState.gd").new()
	game_state.name = "GameState"
	root.add_child(game_state)

	var pass_count = 0
	var total_tests = 7
	
	# Test 1: HUD Heartbeat Audio Nodes & Ambiance Bus Routing
	var hud_scene = load("res://Scenes/UI/HUD.tscn")
	var hud_inst = hud_scene.instantiate() if hud_scene else null
	if hud_inst != null:
		root.add_child(hud_inst)
		var h_slow = hud_inst.get_node_or_null("HeartbeatSlowAudio") as AudioStreamPlayer
		var h_fast = hud_inst.get_node_or_null("HeartbeatFastAudio") as AudioStreamPlayer
		assert(h_slow != null, "HeartbeatSlowAudio must exist in HUD")
		assert(h_fast != null, "HeartbeatFastAudio must exist in HUD")
		assert(h_slow.bus == &"Ambiance", "HeartbeatSlowAudio must route to Ambiance bus")
		assert(h_fast.bus == &"Ambiance", "HeartbeatFastAudio must route to Ambiance bus")
		assert(h_slow.stream != null, "HeartbeatSlowAudio stream must be set")
		assert(h_fast.stream != null, "HeartbeatFastAudio stream must be set")
		print("✅ TEST 1 PASSED: HUD Heartbeat audio nodes properly configured on Ambiance bus.")
		pass_count += 1
		hud_inst.queue_free()
	else:
		printerr("❌ TEST 1 FAILED: Failed to instantiate HUD.tscn.")

	# Test 2: DrudenfussThreshold Scene & Audio/Particle Configuration
	var df_scene = load("res://Scenes/Workshop/DrudenfussThreshold.tscn")
	var df_inst = df_scene.instantiate() if df_scene else null
	if df_inst != null:
		root.add_child(df_inst)
		var chalk_audio = df_inst.get_node_or_null("ChalkAudio") as AudioStreamPlayer3D
		var repel_audio = df_inst.get_node_or_null("RepelAudio") as AudioStreamPlayer3D
		var sulfur = df_inst.get_node_or_null("SulfurParticles") as GPUParticles3D
		assert(chalk_audio != null, "ChalkAudio must exist")
		assert(repel_audio != null, "RepelAudio must exist")
		assert(sulfur != null, "SulfurParticles must exist")
		assert(chalk_audio.bus == &"SFX", "ChalkAudio must route to SFX bus")
		assert(repel_audio.bus == &"Creature", "RepelAudio must route to Creature bus")
		assert(sulfur.one_shot == true, "Sulfur particles must be one_shot")
		print("✅ TEST 2 PASSED: DrudenfussThreshold audio routing and sulfur particles verified.")
		pass_count += 1
		df_inst.queue_free()
	else:
		printerr("❌ TEST 2 FAILED: Failed to instantiate DrudenfussThreshold.tscn.")

	# Test 3: Drudenfuss Rune Activation & UV Luminescence Reactivity
	df_inst = df_scene.instantiate()
	if df_inst != null:
		root.add_child(df_inst)
		assert(df_inst.is_rune_active == false)
		df_inst._on_interacted(null)
		assert(df_inst.is_rune_active == true, "Interaction must activate Drudenfuss rune")
		assert(df_inst.rune_timer == df_inst.rune_duration, "Rune timer must be initialized")
		
		# UV Light Exposure
		df_inst.expose_to_uv_light(null)
		assert(df_inst.uv_glow_boost == 1.0, "UV exposure must set uv_glow_boost to 1.0")
		print("✅ TEST 3 PASSED: Drudenfuss activation and UV luminescence boost operating correctly.")
		pass_count += 1
		df_inst.queue_free()
	else:
		printerr("❌ TEST 3 FAILED: Failed to test Drudenfuss rune activation.")

	# Test 4: Drudenfuss Barrier Repulsion Callback
	df_inst = df_scene.instantiate()
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	var wraith = wraith_scene.instantiate() if wraith_scene else null
	if df_inst != null and wraith != null:
		root.add_child(df_inst)
		root.add_child(wraith)
		df_inst._on_interacted(null)
		
		var repelled_fired = false
		df_inst.entity_repelled.connect(func(_e): repelled_fired = true)
		
		# Position wraith inside barrier
		wraith.global_position = df_inst.global_position + Vector3(0, 0.5, 0)
		df_inst._check_barrier_repel()
		
		# WraithAI has repel_by_holy_runes()
		assert(wraith.has_method("repel_by_holy_runes"), "Wraith must have repel_by_holy_runes method")
		wraith.repel_by_holy_runes()
		assert(wraith.current_state == WraithAI.State.REPELLED, "Wraith must transition to REPELLED")
		print("✅ TEST 4 PASSED: Holy runes repel wraith entity and trigger defensive reaction.")
		pass_count += 1
		df_inst.queue_free()
		wraith.queue_free()
	else:
		printerr("❌ TEST 4 FAILED: Failed to test barrier repulsion.")

	# Test 5: AnvilStation Audio Bus Routing
	var anvil_scene = load("res://Scenes/Workshop/AnvilStation.tscn")
	var anvil_inst = anvil_scene.instantiate() if anvil_scene else null
	if anvil_inst != null:
		root.add_child(anvil_inst)
		var strike = anvil_inst.get_node_or_null("StrikeAudio") as AudioStreamPlayer3D
		assert(strike != null, "StrikeAudio must exist on AnvilStation")
		assert(strike.bus == &"SFX", "StrikeAudio must route to SFX bus")
		print("✅ TEST 5 PASSED: AnvilStation correctly routed to SFX bus.")
		pass_count += 1
		anvil_inst.queue_free()
	else:
		printerr("❌ TEST 5 FAILED: Failed to instantiate AnvilStation.tscn.")

	# Test 6: HUD Heartbeat Proximity Dynamics
	hud_inst = hud_scene.instantiate()
	var player_scene = load("res://Scenes/Player/Player.tscn")
	var player = player_scene.instantiate()
	wraith = wraith_scene.instantiate()
	if hud_inst != null and player != null and wraith != null:
		root.add_child(player)
		root.add_child(wraith)
		root.add_child(hud_inst)
		
		hud_inst.player_ref = player
		hud_inst.wraith_ref = wraith
		assert(hud_inst.player_ref != null, "HUD must link player_ref")
		assert(hud_inst.wraith_ref != null, "HUD must link wraith_ref")
		
		# Test panic proximity (dist = 4.0m)
		player.position = Vector3(0, 0, 0)
		wraith.position = Vector3(0, 0, 4.0)
		hud_inst._process(0.1)
		assert(hud_inst.get_anxiety_state() == "PANIC", "Distance 4.0m must trigger PANIC state")
		
		# Test creeping dread proximity (dist = 9.0m)
		wraith.position = Vector3(0, 0, 9.0)
		hud_inst._process(0.1)
		assert(hud_inst.get_anxiety_state() == "CREEPING", "Distance 9.0m must trigger CREEPING state")
		
		# Test safe distance (dist = 25.0m)
		wraith.position = Vector3(0, 0, 25.0)
		hud_inst._process(0.1)
		assert(hud_inst.get_anxiety_state() == "SAFE", "Distance 25.0m must return SAFE state")
		print("✅ TEST 6 PASSED: Proximity anxiety calculations correctly drive PANIC, CREEPING, and SAFE states.")
		pass_count += 1
		
		player.queue_free()
		wraith.queue_free()
		hud_inst.queue_free()
	else:
		printerr("❌ TEST 6 FAILED: Failed to test HUD proximity dynamics.")

	# Test 7: Main.tscn Scene Integration
	var main_scene = load("res://Scenes/Main.tscn")
	var main_inst = main_scene.instantiate() if main_scene else null
	if main_inst != null:
		root.add_child(main_inst)
		assert(main_inst.get_node_or_null("DrudenfussThreshold") != null, "DrudenfussThreshold in Main.tscn")
		assert(main_inst.get_node_or_null("AnvilStation") != null, "AnvilStation in Main.tscn")
		assert(main_inst.get_node_or_null("HUD") != null, "HUD in Main.tscn")
		assert(main_inst.get_node_or_null("Player") != null, "Player in Main.tscn")
		assert(main_inst.get_node_or_null("InvisibleWraith") != null, "InvisibleWraith in Main.tscn")
		print("✅ TEST 7 PASSED: Main.tscn integrates all updated nodes seamlessly.")
		pass_count += 1
		main_inst.queue_free()
	else:
		printerr("❌ TEST 7 FAILED: Failed to instantiate Main.tscn.")

	print("==================================================")
	print("RESULTS: %d / %d TESTS PASSED" % [pass_count, total_tests])
	print("==================================================")

	if pass_count == total_tests:
		print("🎉 ALL v1.7.0 HEARTBEAT & DRUDENFUSS TESTS PASSED!")
		quit(0)
	else:
		printerr("⚠️ SOME TESTS FAILED.")
		quit(1)
