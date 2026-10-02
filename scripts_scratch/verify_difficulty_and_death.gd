extends SceneTree

func _init() -> void:
	print("--- VERIFYING DIFFICULTY & DEATH SEQUENCE ---")
	
	# 1. Test GameState
	var game_state = load("res://Scripts/GameState.gd").new()
	game_state.name = "GameState"
	root.add_child(game_state)
	
	assert(game_state.get_wilt_rate_multiplier() == 1.0, "Default wilt multiplier should be 1.0")
	assert(game_state.get_wraith_speed_multiplier() == 1.0, "Default speed multiplier should be 1.0")
	
	game_state.set_difficulty(game_state.Difficulty.WALPURGISNACHT)
	assert(game_state.get_wilt_rate_multiplier() == 1.5, "Walpurgisnacht wilt should be 1.5")
	assert(game_state.get_wraith_speed_multiplier() == 1.25, "Walpurgisnacht speed should be 1.25")
	print("Walpurgisnacht multipliers verified: wilt=1.5, speed=1.25")
	
	game_state.set_difficulty(game_state.Difficulty.STILLE_NACHT)
	assert(game_state.get_wilt_rate_multiplier() == 0.5, "Stille Nacht wilt should be 0.5")
	assert(game_state.get_wraith_speed_multiplier() == 0.75, "Stille Nacht speed should be 0.75")
	print("Stille Nacht multipliers verified: wilt=0.5, speed=0.75")
	
	# 2. Test MainMenu.tscn instancing
	var menu_scene = load("res://Scenes/UI/MainMenu.tscn")
	assert(menu_scene != null, "MainMenu.tscn should load")
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	
	var diff_btn = menu.get_node_or_null("Center/VBox/DifficultyBox/DifficultyBtn") as Button
	assert(diff_btn != null, "DifficultyBtn should exist")
	print("MainMenu.tscn instantiated. Difficulty button text: %s" % diff_btn.text)
	
	# Test cycling
	menu._on_difficulty_pressed()
	print("Cycled difficulty button text: %s" % diff_btn.text)
	
	# 3. Test HUD.tscn death sequence
	var hud_scene = load("res://Scenes/UI/HUD.tscn")
	assert(hud_scene != null, "HUD.tscn should load")
	var hud = hud_scene.instantiate()
	root.add_child(hud)
	
	var over_panel = hud.get_node_or_null("GameOverPanel")
	var stats = hud.get_node_or_null("GameOverPanel/Center/VBox/StatsLabel") as Label
	assert(over_panel != null, "GameOverPanel should exist")
	assert(stats != null, "StatsLabel should exist")
	
	# Trigger death sequence
	hud._on_player_caught()
	assert(hud._is_dying == true, "HUD should enter dying state")
	hud._on_game_lost()
	assert(over_panel.visible == true, "GameOverPanel should be visible")
	print("GameOverPanel stats: %s" % stats.text)
	
	print("ALL DIFFICULTY & DEATH JUMPSCARE TESTS PASSED!")
	quit(0)
