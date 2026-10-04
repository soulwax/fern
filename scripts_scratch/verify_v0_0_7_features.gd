extends SceneTree

func _init() -> void:
	print("--- Running FERN Milestone v0.0.7 Feature Verification ---")

	# Mock player & mock wraith
	var mock_player = CharacterBody3D.new()
	mock_player.name = "MockPlayer"
	mock_player.set_script(load("res://Scripts/Player/PlayerController.gd"))
	mock_player.position = Vector3(0, 0.2, 0.5)
	mock_player.set("stamina", 50.0)
	mock_player.set("max_stamina", 100.0)
	root.add_child(mock_player)

	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	assert(wraith_scene != null, "InvisibleWraith.tscn must load successfully")
	var wraith = wraith_scene.instantiate()
	root.add_child(wraith)
	wraith._ready()
	wraith.position = Vector3(0, 3.2, -1.5)

	# 1. Verify BellRopeStation
	print("[1/4] Verifying BellRopeStation.tscn & rafter shockwave...")
	var rope_scene = load("res://Scenes/Workshop/BellRopeStation.tscn")
	assert(rope_scene != null, "BellRopeStation.tscn must load successfully")
	var rope = rope_scene.instantiate()
	root.add_child(rope)
	rope._ready()

	assert(rope.current_cooldown == 0.0, "Bell rope must start ready to pull")
	assert(rope.is_enabled == true, "Bell rope must be enabled")

	# Position wraith in rafters above threshold (Y=3.2 > 2.2)
	wraith.position = rope.position + Vector3(0, 0.2, 0)
	rope.wraith_ref = wraith
	var pulled = rope.pull_rope()
	assert(pulled == true, "Pull rope must succeed")
	assert(rope.current_cooldown == rope.cooldown_duration, "Cooldown must be active")
	assert(rope.is_enabled == false, "Rope must be disabled during resonance")
	assert(wraith.current_state == wraith.State.STUNNED, "Overhead wraith must be stunned by belfry shockwave")
	assert(wraith.velocity.y <= -4.0, "Overhead wraith must be forced downward out of rafters")
	print("  -> Passed: BellRopeStation interaction, belfry chime & rafter stun/descent verified.")

	# 2. Verify LinseedLampStation
	print("[2/4] Verifying LinseedLampStation.tscn & sanctuary illumination...")
	var lamp_scene = load("res://Scenes/Workshop/LinseedLampStation.tscn")
	assert(lamp_scene != null, "LinseedLampStation.tscn must load successfully")
	var lamp = lamp_scene.instantiate()
	root.add_child(lamp)
	lamp._ready()

	assert(lamp.current_uses == 3, "Linseed lamp must start with 3 uses")
	assert(lamp.is_burning == false, "Lamp must start extinguished")

	# Ignite lamp
	lamp.ignite_lamp(mock_player)
	assert(lamp.is_burning == true, "Lamp must be burning")
	assert(lamp.current_uses == 2, "Uses must decrement to 2")
	assert(lamp.burn_timer == lamp.burn_duration, "Burn timer must match duration")
	assert(lamp.lamp_light.light_energy >= lamp.active_light_energy - 0.01, "Light energy must be boosted")

	# Test stamina regen inside sanctuary
	lamp.player_ref = mock_player
	var init_stamina = mock_player.get("stamina")
	lamp._process(0.5)
	assert(mock_player.get("stamina") > init_stamina, "Player stamina must recover inside lamp sanctuary cone")

	# Test wraith hunting deterrence inside sanctuary
	wraith.position = lamp.position + Vector3(1.0, 0, 1.0)
	wraith.set_state(wraith.State.HUNT)
	lamp.wraith_ref = wraith
	lamp._process(0.1)
	assert(wraith.current_state != wraith.State.HUNT, "Wraith in HUNT state must be deterred from sanctuary cone")
	print("  -> Passed: LinseedLampStation ignition, stamina sanctuary & wraith deterrence verified.")

	# 3. Verify IncenseCenserStation
	print("[3/4] Verifying IncenseCenserStation.tscn & mist purification...")
	var censer_scene = load("res://Scenes/Workshop/IncenseCenserStation.tscn")
	assert(censer_scene != null, "IncenseCenserStation.tscn must load successfully")
	var censer = censer_scene.instantiate()
	root.add_child(censer)
	censer._ready()

	assert(censer.current_charges == 2, "Incense censer must start with 2 charges")
	assert(censer.is_active == false, "Censer must start unlit")

	# Light censer
	var lit = censer.light_censer()
	assert(lit == true, "Lighting censer must succeed")
	assert(censer.is_active == true, "Censer must be active")
	assert(censer.current_charges == 1, "Charges must decrement to 1")
	assert(censer.coal_light.light_energy > 1.0, "Coal light must glow bright")
	assert(censer.smoke_particles.emitting == true, "Smoke particles must emit")

	# Test wraith purification reveal
	wraith.position = censer.position + Vector3(1.5, 0, 1.5)
	censer.wraith_ref = wraith
	censer._process(0.1)
	assert(wraith.uv_exposure_timer > 0.0, "Incense smoke must reveal wraith within purification radius")
	print("  -> Passed: IncenseCenserStation stoking, smoke emission & wraith smoke reveal verified.")

	# 4. Verify Main.tscn Scene Assembly
	print("[4/4] Verifying Main.tscn scene assembly with v0.0.7 stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_node = main_scene.instantiate()
	assert(main_node != null, "Main.tscn must instantiate")

	var bell_node = main_node.get_node_or_null("BellRopeStation")
	assert(bell_node != null, "Main.tscn must contain BellRopeStation")
	assert(bell_node.position == Vector3(-1.8, 3.2, -1.5), "BellRopeStation position must match (-1.8, 3.2, -1.5)")

	var lamp_node = main_node.get_node_or_null("LinseedLampStation")
	assert(lamp_node != null, "Main.tscn must contain LinseedLampStation")
	assert(lamp_node.position == Vector3(0.0, 2.6, 0.5), "LinseedLampStation position must match (0.0, 2.6, 0.5)")

	var censer_node = main_node.get_node_or_null("IncenseCenserStation")
	assert(censer_node != null, "Main.tscn must contain IncenseCenserStation")
	assert(censer_node.position == Vector3(2.8, 2.2, -0.5), "IncenseCenserStation position must match (2.8, 2.2, -0.5)")

	print("  -> BellRopeStation position: ", bell_node.position)
	print("  -> LinseedLampStation position: ", lamp_node.position)
	print("  -> IncenseCenserStation position: ", censer_node.position)

	print("=======================================================")
	print("🎉 ALL v0.0.7 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")

	quit(0)
