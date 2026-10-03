extends SceneTree

func _init() -> void:
	print("--- Running FERN Milestone v0.0.5 Feature Verification ---")

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

	# 1. Verify CuckooClockStation
	print("[1/4] Verifying CuckooClockStation.tscn & escapement proximity jamming...")
	var clock_scene = load("res://Scenes/Workshop/CuckooClockStation.tscn")
	assert(clock_scene != null, "CuckooClockStation.tscn must load successfully")
	var clock = clock_scene.instantiate()
	root.add_child(clock)
	clock._ready()

	assert(clock.is_jammed == false, "Clock must start in unjammed state")
	
	# Test normal cuckoo call
	clock.trigger_cuckoo()
	assert(clock.bird_door.rotation_degrees.y == 90.0, "Bird door must open on cuckoo call")

	# Test proximity jamming by wraith
	clock.wraith_ref = wraith
	clock._check_wraith_proximity()
	assert(clock.is_jammed == true, "Clock escapement must jam when wraith creeps within 6.0m")

	# Rewind mechanism
	clock.rewind_mechanism()
	assert(clock.is_jammed == false, "Clock must be unjammed after rewind")
	print("  -> Passed: CuckooClockStation calls, proximity jamming & rewind verified.")

	# 2. Verify ChiselStation
	print("[2/4] Verifying ChiselStation.tscn & cold-iron parry defense...")
	var chisel_scene = load("res://Scenes/Workshop/ChiselStation.tscn")
	assert(chisel_scene != null, "ChiselStation.tscn must load successfully")
	var chisel = chisel_scene.instantiate()
	root.add_child(chisel)
	chisel._ready()

	assert(chisel.is_sharp == true, "Chisel must start sharp")
	assert(chisel.is_equipped == false, "Chisel must start unequipped")

	# Equip chisel
	chisel.equip_chisel(mock_player)
	assert(chisel.is_equipped == true, "Chisel must be equipped")

	# Parry wraith
	chisel.parry_attack(wraith)
	assert(chisel.is_sharp == false, "Chisel must become dulled after supernatural parry")
	assert(wraith.current_state == wraith.State.REPELLED, "Wraith must be repelled by cold-iron chisel")

	# Resharpen
	chisel.resharpen()
	assert(chisel.is_sharp == true, "Chisel must be sharp after resharpening")
	print("  -> Passed: ChiselStation equip, cold-iron parry & resharpening verified.")

	# 3. Verify HerbBundleStation
	print("[3/4] Verifying HerbBundleStation.tscn & scent masking...")
	var herb_scene = load("res://Scenes/Workshop/HerbBundleStation.tscn")
	assert(herb_scene != null, "HerbBundleStation.tscn must load successfully")
	var herb = herb_scene.instantiate()
	root.add_child(herb)
	herb._ready()

	assert(herb.current_charges == 2, "Herb bundle must start with 2 charges")
	
	# Crush herb
	herb.crush_herb()
	assert(herb.current_charges == 1, "Charges must decrement to 1")
	assert(herb.stealth_active_timer == herb.stealth_duration, "Stealth timer must be active")
	
	# Verify wraith scent mask
	wraith.set_scent_masked(20.0)
	assert(wraith.scent_mask_timer == 20.0, "Wraith scent mask timer must match stealth duration")
	
	# Stalking must be aborted when scent is masked
	wraith.set_state(wraith.State.STALK)
	wraith._process_stalk(0.1)
	assert(wraith.current_state == wraith.State.PROWL, "Wraith must abort stalk and return to prowl when scent is masked")
	print("  -> Passed: HerbBundleStation crushing, charges & wraith scent masking verified.")

	# 4. Verify Main.tscn Scene Assembly
	print("[4/4] Verifying Main.tscn scene assembly with v0.0.5 stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_node = main_scene.instantiate()
	assert(main_node != null, "Main.tscn must instantiate")

	var clock_node = main_node.get_node_or_null("CuckooClockStation")
	assert(clock_node != null, "Main.tscn must contain CuckooClockStation")
	print("  -> CuckooClockStation position: %s" % str(clock_node.position))

	var chisel_node = main_node.get_node_or_null("ChiselStation")
	assert(chisel_node != null, "Main.tscn must contain ChiselStation")
	print("  -> ChiselStation position: %s" % str(chisel_node.position))

	var herb_node = main_node.get_node_or_null("HerbBundleStation")
	assert(herb_node != null, "Main.tscn must contain HerbBundleStation")
	print("  -> HerbBundleStation position: %s" % str(herb_node.position))

	# Cleanup test nodes
	mock_player.queue_free()
	wraith.queue_free()
	clock.queue_free()
	chisel.queue_free()
	herb.queue_free()
	main_node.queue_free()

	print("=======================================================")
	print("🎉 ALL v0.0.5 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")
	quit(0)
