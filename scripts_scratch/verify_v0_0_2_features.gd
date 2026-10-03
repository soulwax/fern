extends SceneTree

const StanduhrClockClass = preload("res://Scripts/Workshop/StanduhrClock.gd")
const HorseshoeWardClass = preload("res://Scripts/Workshop/HorseshoeWard.gd")
const FloorMistEcosystemClass = preload("res://Scripts/Workshop/FloorMistEcosystem.gd")

func _init() -> void:
	print("--- Running FERN Milestone v0.0.2 Feature Verification ---")

	# Test 1: StanduhrClock structure and dread dilation logic
	print("[1/4] Verifying StanduhrClock.tscn and temporal dread dilation...")
	var clock_scene = load("res://Scenes/Workshop/StanduhrClock.tscn")
	assert(clock_scene != null, "StanduhrClock.tscn must load successfully")
	var clock_instance = clock_scene.instantiate()
	assert(clock_instance != null, "StanduhrClock.tscn must instantiate cleanly")

	var tick_audio = clock_instance.get_node_or_null("TickAudio")
	assert(tick_audio != null, "TickAudio must exist in StanduhrClock")
	assert(tick_audio.bus == &"SFX", "TickAudio must route to SFX bus")
	assert(tick_audio.stream != null, "TickAudio must have valid AudioStream")

	var chime_audio = clock_instance.get_node_or_null("ChimeAudio")
	assert(chime_audio != null, "ChimeAudio must exist in StanduhrClock")
	assert(chime_audio.bus == &"SFX", "ChimeAudio must route to SFX bus")

	var pendulum = clock_instance.get_node_or_null("PendulumAnchor/Pendulum")
	assert(pendulum != null, "Pendulum must exist in StanduhrClock")

	# Simulate fake wraith for dilation tests
	var dummy_wraith = CharacterBody3D.new()
	dummy_wraith.name = "InvisibleWraith"
	clock_instance.wraith_node = dummy_wraith
	clock_instance.position = Vector3(5.8, 0, 0.5)

	# Far test (>5.5m): pitch ~1.0
	dummy_wraith.position = Vector3(0, 0, 0) # dist ~ 5.82m
	clock_instance._process(0.1)
	assert(not clock_instance.is_frozen, "Clock must not be frozen when wraith is far")

	# Critical proximity (<2.5m): frozen in silence
	dummy_wraith.position = Vector3(5.0, 0, 0.5) # dist ~ 0.8m
	clock_instance._process(0.1)
	assert(clock_instance.is_frozen, "Clock must freeze when wraith is within critical range (<2.5m)")

	# Recede: unfreeze
	dummy_wraith.position = Vector3(0, 0, 0)
	clock_instance._process(0.1)
	assert(not clock_instance.is_frozen, "Clock must unfreeze when wraith retreats")

	clock_instance.chime()
	print("  -> Passed: StanduhrClock temporal dilation & audio verified.")

	# Test 2: HorseshoeWard deflection and consecration
	print("[2/4] Verifying HorseshoeWard.tscn threshold protection...")
	var shoe_scene = load("res://Scenes/Workshop/HorseshoeWard.tscn")
	assert(shoe_scene != null, "HorseshoeWard.tscn must load successfully")
	var shoe_instance = shoe_scene.instantiate()
	assert(shoe_instance != null, "HorseshoeWard.tscn must instantiate cleanly")

	assert(shoe_instance.is_ward_active == true, "Horseshoe ward must be active by default")
	var shoe_audio = shoe_instance.get_node_or_null("WardAudio")
	assert(shoe_audio != null, "WardAudio must exist in HorseshoeWard")
	assert(shoe_audio.bus == &"SFX", "WardAudio must route to SFX bus")

	# Test deflection
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	var wraith_instance = wraith_scene.instantiate()
	assert(wraith_instance.has_method("repel_by_horseshoe"), "InvisibleWraith must support repel_by_horseshoe")

	shoe_instance.trigger_deflection(wraith_instance)
	assert(shoe_instance.is_ward_active == false, "Ward must deactivate after triggering deflection")
	assert(wraith_instance.current_state == wraith_instance.State.REPELLED, "Wraith must be put in REPELLED state by horseshoe ward")

	# Test re-consecration
	shoe_instance.consecrate()
	assert(shoe_instance.is_ward_active == true, "Ward must reactivate after consecration")
	print("  -> Passed: HorseshoeWard deflection & re-consecration verified.")

	# Test 3: FloorMistEcosystem and vapor wake tracking
	print("[3/4] Verifying FloorMistEcosystem.tscn low-lying mist & vapor wakes...")
	var mist_scene = load("res://Scenes/Workshop/FloorMistEcosystem.tscn")
	assert(mist_scene != null, "FloorMistEcosystem.tscn must load successfully")
	var mist_instance = mist_scene.instantiate()
	assert(mist_instance != null, "FloorMistEcosystem.tscn must instantiate cleanly")

	var ambient_mist = mist_instance.get_node_or_null("AmbientMist")
	assert(ambient_mist != null, "AmbientMist must exist in FloorMistEcosystem")
	var displaced_wake = mist_instance.get_node_or_null("DisplacedWake")
	assert(displaced_wake != null, "DisplacedWake must exist in FloorMistEcosystem")

	# Test wake triggers on floor movement
	mist_instance.wraith_node = wraith_instance
	wraith_instance.position = Vector3(0, 0.1, 0)
	wraith_instance.velocity = Vector3(2.5, 0, 0)
	mist_instance._update_wraith_wake()
	assert(displaced_wake.emitting == true, "DisplacedWake must emit when wraith is moving on floor")

	# Test wake stops on rafter movement
	wraith_instance.position = Vector3(0, 3.5, 0) # Elevated in rafters
	mist_instance._update_wraith_wake()
	assert(displaced_wake.emitting == false, "DisplacedWake must stop when wraith is in rafters")
	print("  -> Passed: FloorMistEcosystem & wraith vapor wake verified.")

	# Test 4: Main.tscn integration
	print("[4/4] Verifying Main.tscn integration of all new stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_instance = main_scene.instantiate()
	assert(main_instance != null, "Main.tscn must instantiate cleanly")

	var main_clock = main_instance.get_node_or_null("StanduhrClock")
	assert(main_clock != null, "Main.tscn must contain StanduhrClock")
	var main_shoe = main_instance.get_node_or_null("HorseshoeWard")
	assert(main_shoe != null, "Main.tscn must contain HorseshoeWard")
	var main_mist = main_instance.get_node_or_null("FloorMistEcosystem")
	assert(main_mist != null, "Main.tscn must contain FloorMistEcosystem")

	print("  -> StanduhrClock position: ", main_clock.position)
	print("  -> HorseshoeWard position: ", main_shoe.position)
	print("  -> FloorMistEcosystem position: ", main_mist.position)

	# Clean up
	dummy_wraith.free()
	clock_instance.free()
	shoe_instance.free()
	wraith_instance.free()
	mist_instance.free()
	main_instance.free()

	print("=======================================================")
	print("🎉 ALL v0.0.2 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")
	quit(0)
