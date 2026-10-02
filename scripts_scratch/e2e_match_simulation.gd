extends SceneTree

func _init() -> void:
	print("=================================================================")
	print("   FERN: FARNBLUME — END-TO-END MATCH SIMULATION SUITE")
	print("=================================================================")
	
	# Instance GameState Autoload
	var game_state = load("res://Scripts/GameState.gd").new()
	game_state.name = "GameState"
	root.add_child(game_state)
	
	# Set Walpurgisnacht Nightmare difficulty for full stress test
	game_state.set_difficulty(game_state.Difficulty.WALPURGISNACHT)
	print("[SIM] Selected Difficulty: %s" % game_state.get_difficulty_name())
	print("[SIM] Wilt Multiplier: %.2f | Wraith Speed Multiplier: %.2f" % [
		game_state.get_wilt_rate_multiplier(),
		game_state.get_wraith_speed_multiplier()
	])
	
	# Load Master Arena Scene
	var main_packed = load("res://Scenes/Main.tscn")
	assert(main_packed != null, "Main.tscn must load successfully")
	var main = main_packed.instantiate()
	root.add_child(main)
	print("[SIM] Arena Scene (Main.tscn) instantiated with Jolt Physics 3D & Forward+.")
	
	# Verify all stations and components
	var stations = {
		"Player": main.get_node_or_null("Player"),
		"InvisibleWraith": main.get_node_or_null("InvisibleWraith"),
		"GrindStoneStation": main.get_node_or_null("GrindStoneStation"),
		"AnvilStation": main.get_node_or_null("AnvilStation"),
		"DrudenfussThreshold": main.get_node_or_null("DrudenfussThreshold"),
		"WindowNorth": main.get_node_or_null("WindowBreachNorth"),
		"WindowEast": main.get_node_or_null("WindowBreachEast"),
		"WindowWest": main.get_node_or_null("WindowBreachWest"),
		"CandleWorkbench": main.get_node_or_null("CandleWorkbench"),
		"CandleGrindstone": main.get_node_or_null("CandleGrindstone"),
		"CandleAnvil": main.get_node_or_null("CandleAnvil"),
		"LadderLoft": main.get_node_or_null("LadderLoft"),
		"LoftDustMotes": main.get_node_or_null("LoftDustMotes"),
		"NightWindAudio": main.get_node_or_null("Audio/NightWindAudio"),
		"HUD": main.get_node_or_null("HUD"),
		"PauseMenu": main.get_node_or_null("PauseMenu")
	}
	
	for s_name in stations.keys():
		assert(stations[s_name] != null, "Station node missing: %s" % s_name)
		print("  -> Verified node: %s" % s_name)
		
	# Verify Farnblume on player
	var player = stations["Player"]
	var farnblume = player.find_child("Farnblume", true, false)
	assert(farnblume != null, "Farnblume item must exist on player")
	print("[SIM] Farnblume bioluminescent flower verified on Player hand socket.")
	
	# Simulate 6-hour survival night progression
	print("\n[SIM] Starting simulated night cycle from 00:00 to 06:00...")
	var sim_stats = {"bell_count": 0, "victory": false}
	game_state.ambient_bell_tolled.connect(func():
		sim_stats["bell_count"] += 1
		print("  🔔 Valley church bell tolled (Hour %d: %s)" % [game_state.current_hour, game_state.get_current_hour_name()])
	)
	
	game_state.game_won.connect(func():
		sim_stats["victory"] = true
		print("  🌅 DAWN BREAKS: game_won signal received!")
	)
	
	for h in range(1, 7):
		game_state.advance_hour()
		var wraith = stations["InvisibleWraith"]
		print("  [Hour %d] Wraith Hunt Speed: %.1f | Stalk Speed: %.1f" % [
			game_state.current_hour,
			wraith.hunt_speed,
			wraith.stalk_speed
		])
	
	assert(sim_stats["bell_count"] == 6, "Expected 6 hourly bell tolls")
	assert(sim_stats["victory"] == true, "Victory must be triggered at 06:00")
	var dawn_sun = main.get_node_or_null("DawnSunlight")
	assert(dawn_sun != null, "Dawn sunlight node must exist")
	
	print("\n=================================================================")
	print("   ✅ ALL END-TO-END MATCH SIMULATION TESTS PASSED (100%)")
	print("=================================================================")
	quit(0)
