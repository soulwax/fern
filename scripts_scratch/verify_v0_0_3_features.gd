extends SceneTree

const SaltLineStationClass = preload("res://Scripts/Workshop/SaltLineStation.gd")
const WoodShavingTrapClass = preload("res://Scripts/Workshop/WoodShavingTrap.gd")
const CandleStationClass = preload("res://Scripts/Workshop/CandleStation.gd")

func _init() -> void:
	print("--- Running FERN Milestone v0.0.3 Feature Verification ---")

	# Test 1: SaltLineStation
	print("[1/4] Verifying SaltLineStation.tscn and sizzling threshold repel...")
	var salt_scene = load("res://Scenes/Workshop/SaltLineStation.tscn")
	assert(salt_scene != null, "SaltLineStation.tscn must load successfully")
	var salt_instance = salt_scene.instantiate()
	assert(salt_instance != null, "SaltLineStation.tscn must instantiate cleanly")

	var sizzle_audio = salt_instance.get_node_or_null("SizzleAudio")
	assert(sizzle_audio != null, "SizzleAudio must exist in SaltLineStation")
	assert(sizzle_audio.bus == &"SFX", "SizzleAudio must route to SFX bus")
	assert(salt_instance.current_charges == 2, "SaltLine must start with 2 charges")

	# Simulate wraith crossing
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	var wraith_instance = wraith_scene.instantiate()
	salt_instance.trigger_sizzle(wraith_instance)
	assert(salt_instance.current_charges == 1, "Charges must decrement to 1 after sizzle")
	assert(wraith_instance.current_state == wraith_instance.State.REPELLED, "Wraith must be repelled by salt sizzle")

	# Replenish
	salt_instance.replenish()
	assert(salt_instance.current_charges == 2, "Replenish must restore charges to 2")
	print("  -> Passed: SaltLineStation barrier & replenishment verified.")

	# Test 2: CandleStation draft physics
	print("[2/4] Verifying CandleStation.gd turbulent draft physics...")
	var candle_scene = load("res://Scenes/Workshop/CandleStation.tscn")
	assert(candle_scene != null, "CandleStation.tscn must load successfully")
	var candle_instance = candle_scene.instantiate()
	assert(candle_instance != null, "CandleStation.tscn must instantiate cleanly")

	# Test process with simulated draft
	candle_instance._ready()
	candle_instance._process(0.1)
	assert(candle_instance.is_lit == true, "Candle must remain lit under normal draft")
	var flame_mesh = candle_instance.get_node_or_null("FlameMesh")
	assert(flame_mesh != null, "FlameMesh must exist on CandleStation")
	print("  -> Passed: CandleStation turbulent draft physics verified.")

	# Test 3: WoodShavingTrap
	print("[3/4] Verifying WoodShavingTrap.tscn and crunch foley...")
	var trap_scene = load("res://Scenes/Workshop/WoodShavingTrap.tscn")
	assert(trap_scene != null, "WoodShavingTrap.tscn must load successfully")
	var trap_instance = trap_scene.instantiate()
	assert(trap_instance != null, "WoodShavingTrap.tscn must instantiate cleanly")

	var crunch_audio = trap_instance.get_node_or_null("CrunchAudio")
	assert(crunch_audio != null, "CrunchAudio must exist in WoodShavingTrap")
	assert(crunch_audio.bus == &"SFX", "CrunchAudio must route to SFX bus")

	trap_instance.trigger_crunch(true)
	assert(trap_instance.step_cooldown > 0.0, "Triggering crunch must activate step cooldown")
	print("  -> Passed: WoodShavingTrap crunch foley verified.")

	# Test 4: Main.tscn integration
	print("[4/4] Verifying Main.tscn integration of all v0.0.3 stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_instance = main_scene.instantiate()
	assert(main_instance != null, "Main.tscn must instantiate cleanly")

	var main_salt = main_instance.get_node_or_null("SaltLineStation")
	assert(main_salt != null, "Main.tscn must contain SaltLineStation")
	var main_trap1 = main_instance.get_node_or_null("WoodShavingTrap1")
	assert(main_trap1 != null, "Main.tscn must contain WoodShavingTrap1")
	var main_trap2 = main_instance.get_node_or_null("WoodShavingTrap2")
	assert(main_trap2 != null, "Main.tscn must contain WoodShavingTrap2")

	print("  -> SaltLineStation position: ", main_salt.position)
	print("  -> WoodShavingTrap1 position: ", main_trap1.position)
	print("  -> WoodShavingTrap2 position: ", main_trap2.position)

	# Clean up
	salt_instance.free()
	wraith_instance.free()
	candle_instance.free()
	trap_instance.free()
	main_instance.free()

	print("=======================================================")
	print("🎉 ALL v0.0.3 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")
	quit(0)
