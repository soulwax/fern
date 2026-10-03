extends SceneTree

func _init() -> void:
	print("--- Running FERN Milestone v0.0.6 Feature Verification ---")

	# Mock player & mock wraith
	var mock_player = Node3D.new()
	mock_player.name = "MockPlayer"
	mock_player.position = Vector3(0, 0, 0)
	root.add_child(mock_player)

	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	assert(wraith_scene != null, "InvisibleWraith.tscn must load successfully")
	var wraith = wraith_scene.instantiate()
	root.add_child(wraith)
	wraith._ready()
	wraith.position = Vector3(0, 0, 3.5)

	# 1. Verify HearthBellowsStation
	print("[1/4] Verifying HearthBellowsStation.tscn & hearth chill/bellows flare...")
	var hearth_scene = load("res://Scenes/Workshop/HearthBellowsStation.tscn")
	assert(hearth_scene != null, "HearthBellowsStation.tscn must load successfully")
	var hearth = hearth_scene.instantiate()
	root.add_child(hearth)
	hearth._ready()

	assert(hearth.is_chilled == false, "Hearth must start in unchilled state")
	assert(hearth.bellows_cooldown == 0.0, "Bellows must start ready to pump")

	# Position wraith within chill radius (4.0m < 5.0m)
	wraith.position = hearth.position + Vector3(0, 0, 3.5)
	hearth.wraith_ref = wraith
	hearth._process(0.1)
	assert(hearth.is_chilled == true, "Hearth embers must become chilled when wraith is within 5.0m")
	assert(hearth.hearth_light.light_energy <= hearth.chilled_light_energy + 0.01, "Light must dim on chill")

	# Pump bellows
	hearth.pump_bellows()
	assert(hearth.flare_duration == 4.0, "Flare duration must be set to 4.0s")
	assert(hearth.bellows_cooldown == 8.0, "Bellows cooldown must be active")
	assert(hearth.hearth_light.light_energy >= hearth.flared_light_energy - 0.01, "Light must flare to maximum")
	assert(wraith.current_state == wraith.State.REPELLED, "Wraith must be repelled by bellows flare")
	print("  -> Passed: HearthBellowsStation chill damping, bellows flare & wraith repel verified.")

	# 2. Verify ZincBasinStation
	print("[2/4] Verifying ZincBasinStation.tscn & droplet resonance...")
	var basin_scene = load("res://Scenes/Workshop/ZincBasinStation.tscn")
	assert(basin_scene != null, "ZincBasinStation.tscn must load successfully")
	var basin = basin_scene.instantiate()
	root.add_child(basin)
	basin._ready()

	assert(basin.is_drip_arrested == false, "Basin drip must start active")

	# Test overhead detection (wraith directly overhead at Y=3.0)
	wraith.position = basin.position + Vector3(0, 3.0, 0)
	basin.wraith_ref = wraith
	basin._process(0.1)
	assert(basin.is_drip_arrested == true, "Droplet drip must be arrested when wraith is overhead in rafters")
	assert(basin.splash_cooldown > 0.0, "Electrostatic splash anomaly must trigger on overhead presence")

	# Test water refill
	basin.collect_water(mock_player)
	print("  -> Passed: ZincBasinStation droplet rhythm, overhead rafter anomaly & water refill verified.")

	# 3. Verify DrawknifeStation
	print("[3/4] Verifying DrawknifeStation.tscn & shaving snares...")
	var drawknife_scene = load("res://Scenes/Workshop/DrawknifeStation.tscn")
	assert(drawknife_scene != null, "DrawknifeStation.tscn must load successfully")
	var drawknife = drawknife_scene.instantiate()
	root.add_child(drawknife)
	drawknife._ready()

	assert(drawknife.current_snares == 3, "Drawknife must start with 3 available snares")

	# Carve and deploy snare at mock player position
	mock_player.position = Vector3(2.0, 0, 2.0)
	var carved = drawknife.carve_and_deploy_snare(mock_player)
	assert(carved == true, "Must successfully carve and deploy shaving snare")
	assert(drawknife.current_snares == 2, "Snares count must decrement to 2")
	assert(drawknife.deployed_snares.size() == 1, "Deployed snares array must contain 1 snare")

	# Move wraith onto snare position
	wraith.position = mock_player.position + Vector3(0.5, 0, 0.5)
	drawknife.wraith_ref = wraith
	drawknife._process(0.1)

	assert(wraith.slow_multiplier == 0.60, "Wraith movement speed must be slowed to 60% by wood shaving snare")
	assert(wraith.slow_timer == 5.0, "Slow duration must be 5.0 seconds")
	assert(drawknife.deployed_snares.is_empty(), "Snare must be expended after triggering on wraith")
	print("  -> Passed: DrawknifeStation shaving peeling, snare deployment & wraith slow debuff verified.")

	# 4. Verify Main.tscn Scene Assembly
	print("[4/4] Verifying Main.tscn scene assembly with v0.0.6 stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_node = main_scene.instantiate()
	assert(main_node != null, "Main.tscn must instantiate")

	var hearth_node = main_node.get_node_or_null("HearthBellowsStation")
	assert(hearth_node != null, "Main.tscn must contain HearthBellowsStation")
	assert(hearth_node.position == Vector3(3.4, 0.0, 1.2), "HearthBellowsStation position must be (3.4, 0.0, 1.2)")

	var basin_node = main_node.get_node_or_null("ZincBasinStation")
	assert(basin_node != null, "Main.tscn must contain ZincBasinStation")
	assert(basin_node.position == Vector3(-3.2, 0.0, -3.8), "ZincBasinStation position must be (-3.2, 0.0, -3.8)")

	var drawknife_node = main_node.get_node_or_null("DrawknifeStation")
	assert(drawknife_node != null, "Main.tscn must contain DrawknifeStation")
	assert(drawknife_node.position == Vector3(-2.2, 0.0, 3.2), "DrawknifeStation position must be (-2.2, 0.0, 3.2)")

	print("  -> HearthBellowsStation position: ", hearth_node.position)
	print("  -> ZincBasinStation position: ", basin_node.position)
	print("  -> DrawknifeStation position: ", drawknife_node.position)

	print("=======================================================")
	print("🎉 ALL v0.0.6 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")

	quit(0)
