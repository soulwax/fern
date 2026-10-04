extends SceneTree

func _init() -> void:
	print("--- BEGIN VERIFICATION: Fern v0.0.3 Features ---")

	# TEST 1: TotenbrettStation mechanics
	print("\n[Test 1] Testing TotenbrettStation mechanics...")
	var totenbrett_scene = load("res://Scenes/Workshop/TotenbrettStation.tscn")
	assert(totenbrett_scene != null, "TotenbrettStation.tscn failed to load!")
	var totenbrett = totenbrett_scene.instantiate()
	root.add_child(totenbrett)

	assert(totenbrett.is_consecrated == false, "Initial totenbrett must be unconsecrated")
	totenbrett.consecrate_totenbrett()
	assert(totenbrett.is_consecrated == true, "Totenbrett must be consecrated after consecrate_totenbrett()")
	assert(totenbrett.rune_light.visible == true, "RuneLight must be visible when consecrated")

	# Test proximity repel on mock wraith
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	var wraith = wraith_scene.instantiate()
	root.add_child(wraith)
	wraith.add_to_group("unseen_entity")
	wraith.position = totenbrett.position + Vector3(1.0, 0.0, 0.0)
	totenbrett._check_for_approaching_wraith([wraith])
	assert(wraith.current_state == WraithAI.State.REPELLED, "Wraith must be repelled by Totenbrett!")

	totenbrett.discharge_ward()
	assert(totenbrett.is_consecrated == false, "Totenbrett must be unconsecrated after discharge_ward()")
	print(" -> PASS: Totenbrett consecration, rune glow, and wraith repel verified.")
	totenbrett.queue_free()
	wraith.queue_free()

	# TEST 2: TalismanBenchStation mechanics
	print("\n[Test 2] Testing TalismanBenchStation & Rowan Amulet...")
	var talisman_scene = load("res://Scenes/Workshop/TalismanBenchStation.tscn")
	assert(talisman_scene != null, "TalismanBenchStation.tscn failed to load!")
	var talisman_bench = talisman_scene.instantiate()
	root.add_child(talisman_bench)

	assert(talisman_bench.is_crafted == false, "Initial talisman must be uncrafted")
	talisman_bench.craft_talisman()
	assert(talisman_bench.is_crafted == true, "Talisman must be crafted after craft_talisman()")
	assert(talisman_bench.amulet_mesh.visible == true, "Amulet mesh must be visible after crafting")
	
	var game_state = root.get_node_or_null("/root/GameState")
	if game_state:
		assert(game_state.has_rowan_talisman == true, "GameState.has_rowan_talisman must be true!")
	print(" -> PASS: TalismanBenchStation crafting and GameState flag verified.")
	talisman_bench.queue_free()

	# TEST 3: GlassCarillonProp mechanics
	print("\n[Test 3] Testing GlassCarillonProp rafter bells...")
	var carillon_scene = load("res://Scenes/Workshop/GlassCarillonProp.tscn")
	assert(carillon_scene != null, "GlassCarillonProp.tscn failed to load!")
	var carillon = carillon_scene.instantiate()
	root.add_child(carillon)

	carillon.trigger_chime()
	assert(carillon.is_swaying == true, "Carillon bells must sway after trigger_chime()")
	assert(carillon.chime_audio != null and carillon.chime_audio.stream != null, "Chime audio stream must be configured!")
	print(" -> PASS: GlassCarillonProp resonance, stream, and bell swaying verified.")
	carillon.queue_free()

	# TEST 4: Full Main Scene Integration
	print("\n[Test 4] Testing Full Main Scene Integration with v0.0.3 stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn failed to load!")
	var main = main_scene.instantiate()
	root.add_child(main)

	assert(main.get_node_or_null("TotenbrettStation") != null, "TotenbrettStation must exist in Main.tscn!")
	assert(main.get_node_or_null("TalismanBenchStation") != null, "TalismanBenchStation must exist in Main.tscn!")
	assert(main.get_node_or_null("GlassCarillonProp") != null, "GlassCarillonProp must exist in Main.tscn!")

	print(" -> PASS: Full Main Scene loaded with all v0.0.3 stations successfully.")
	main.queue_free()

	print("\n==========================================")
	print("ALL v0.0.3 VERIFICATION TESTS PASSED (100%)")
	print("==========================================")
	quit(0)
