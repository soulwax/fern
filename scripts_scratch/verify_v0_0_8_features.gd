extends SceneTree

# Headless verification script for v0.0.8 features:
# Das Weihwasserbecken, Das Breitbeil im Haublock & Die Haselfichte

const WraithScript = preload("res://Scripts/Monster/WraithAI.gd")

func _init() -> void:
	print("\n=== [V0.0.8 FEATURE VERIFICATION START] ===")
	
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main = main_scene.instantiate()
	root.add_child(main)

	var wraith: WraithAI = main.get_node_or_null("InvisibleWraith")
	assert(wraith != null, "InvisibleWraith must exist in Main.tscn")

	var player = main.get_node_or_null("Player")
	assert(player != null, "Player must exist in Main.tscn")

	# 1. Verify HolyWaterStoupStation in scene
	print("\n--- [Test 1] HolyWaterStoupStation ---")
	var stoup = main.get_node_or_null("HolyWaterStoupStation")
	assert(stoup != null, "HolyWaterStoupStation must exist in Main.tscn")
	print("HolyWaterStoupStation found at: ", stoup.global_position)
	assert(stoup.current_charges == 3, "Initial charges must be 3")
	assert(not stoup.is_blessed, "Initial state must not be blessed")

	# Test sprinkle interaction
	var sprinkled = stoup.sprinkle_water()
	assert(sprinkled, "Sprinkle interaction must succeed")
	assert(stoup.is_blessed, "Station must now be blessed")
	assert(stoup.current_charges == 2, "Charges must decrement to 2")
	assert(stoup.blessing_timer == 30.0, "Blessing timer must be 30.0s")
	print("PASS: Consecrated water sprinkled (charges: 2/3, blessing_timer: 30s)")

	# Position wraith within blessing radius (4.5m)
	stoup.wraith_ref = wraith
	wraith.position = stoup.position + Vector3(1.5, -0.8, 0.0)
	stoup._process(0.016)

	assert(wraith.consecrated_blind_timer > 0.0, "Wraith must receive consecrated blind timer")
	assert(wraith.current_state == WraithScript.State.REPELLED, "Wraith must be repelled by holy steam")
	print("PASS: Wraith scalded and blinded by consecrated steam (timer: %fs, state: REPELLED)" % wraith.consecrated_blind_timer)

	stoup.quench_blessing()
	assert(not stoup.is_blessed, "Quenching must reset blessed state")
	print("PASS: Quench blessing reset properly")

	# 2. Verify BroadaxeBlockStation in scene
	print("\n--- [Test 2] BroadaxeBlockStation ---")
	var axe_station = main.get_node_or_null("BroadaxeBlockStation")
	assert(axe_station != null, "BroadaxeBlockStation must exist in Main.tscn")
	print("BroadaxeBlockStation found at: ", axe_station.position)
	assert(axe_station.current_strikes == 3, "Initial strikes must be 3")

	# Position wraith within 4.8m on floor (Y < 2.0)
	axe_station.wraith_ref = wraith
	wraith.position = axe_station.position + Vector3(1.8, 0.1, 0.0)
	wraith.velocity = Vector3(1.0, 0, 0)

	var struck = axe_station.strike_axe()
	assert(struck, "Axe strike must succeed")
	assert(axe_station.current_strikes == 2, "Strikes must decrement to 2")
	print("PASS: Broadaxe struck into heartwood (strikes remaining: 2/3)")

	# Verify wraith grounding
	wraith._physics_process(0.016)
	assert(wraith.grounded_silhouette_timer > 0.0, "Wraith silhouette must be locked")
	assert(wraith.slow_multiplier < 1.0, "Wraith must be slowed by acoustic shockwave")
	print("PASS: Wraith grounded silhouette locked for %fs (slow mult: %f)" % [wraith.grounded_silhouette_timer, wraith.slow_multiplier])

	# 3. Verify ResonantSpruceStation in scene
	print("\n--- [Test 3] ResonantSpruceStation ---")
	var spruce_station = main.get_node_or_null("ResonantSpruceStation")
	assert(spruce_station != null, "ResonantSpruceStation must exist in Main.tscn")
	print("ResonantSpruceStation found at: ", spruce_station.position)

	# Place wraith within drone radius (<5.5m)
	spruce_station.wraith_ref = wraith
	wraith.position = spruce_station.position + Vector3(2.5, 0.1, 0.0)
	spruce_station._process(0.016)
	assert(spruce_station.is_droning, "Strings must start sympathetic drone under proximity")
	print("PASS: ResonantSpruce sympathetic proximity hum started (<5.5m)")

	# Move wraith far away (>6.2m)
	wraith.position = spruce_station.position + Vector3(10.0, 0.1, 0.0)
	spruce_station._process(0.016)
	assert(not spruce_station.is_droning, "Drone must cease when wraith retreats")
	print("PASS: Sympathetic drone stopped on wraith retreat")

	# Put wraith in HUNT and within scramble radius (8.0m)
	wraith.position = spruce_station.position + Vector3(3.0, 0.1, 0.0)
	wraith.set_state(WraithScript.State.HUNT)
	assert(wraith.current_state == WraithScript.State.HUNT, "Wraith must be in HUNT state")

	var plucked = spruce_station.pluck_soundboard()
	assert(plucked, "Soundboard pluck must succeed")
	assert(spruce_station.current_cooldown > 0.0, "Cooldown must be initiated")
	print("PASS: Soundboard plucked (cooldown: %fs)" % spruce_station.current_cooldown)

	# Verify pursuit tracking scrambled into PROWL
	assert(wraith.acoustic_scramble_timer > 0.0, "Acoustic scramble timer must be set")
	assert(wraith.current_state == WraithScript.State.PROWL, "Wraith HUNT state must be broken into PROWL")
	print("PASS: Wraith hunt tracking scrambled into PROWL (scramble timer: %fs)" % wraith.acoustic_scramble_timer)

	# 4. Verify all stations present in tree and active
	print("\n--- [Test 4] Verifying all v0.0.8 stations in Main scene tree ---")
	var holy_water_node = main.get_node_or_null("HolyWaterStoupStation")
	var broadaxe_node = main.get_node_or_null("BroadaxeBlockStation")
	var spruce_node = main.get_node_or_null("ResonantSpruceStation")
	assert(holy_water_node != null and broadaxe_node != null and spruce_node != null, "All 3 stations must exist")
	print("HolyWaterStoupStation: ", holy_water_node.name, " @ ", holy_water_node.position)
	print("BroadaxeBlockStation: ", broadaxe_node.name, " @ ", broadaxe_node.position)
	print("ResonantSpruceStation: ", spruce_node.name, " @ ", spruce_node.position)

	print("\n=== [ALL V0.0.8 VERIFICATION CHECKS PASSED PERFECTLY!] ===\n")
	main.queue_free()
	quit(0)
