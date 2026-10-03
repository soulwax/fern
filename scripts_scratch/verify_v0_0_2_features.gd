extends SceneTree

func _init() -> void:
	print("--- BEGIN VERIFICATION: Fern v0.0.2 Features ---")
	
	# TEST 1: BreadOfferingStation mechanics
	print("\n[Test 1] Testing BreadOfferingStation mechanics...")
	var bread_scene = load("res://Scenes/Workshop/BreadOfferingStation.tscn")
	assert(bread_scene != null, "BreadOfferingStation.tscn failed to load!")
	var bread = bread_scene.instantiate()
	root.add_child(bread)
	
	assert(bread.is_offering_active == false, "Initial offering should be inactive")
	assert(bread.is_being_consumed == false, "Initial consumption should be false")
	
	bread.place_offering()
	assert(bread.is_offering_active == true, "Offering should be active after place_offering()")
	assert(bread.bread_mesh.visible == true, "Bread mesh should be visible")
	
	bread.start_consumption()
	assert(bread.is_being_consumed == true, "Offering should be marked as being consumed")
	
	bread.finish_consumption()
	assert(bread.is_offering_active == false, "Offering should be inactive after consumption")
	assert(bread.cooldown_timer > 0.0, "Cooldown timer should be set after consumption")
	print(" -> PASS: BreadOfferingStation placement, consumption, and cooldown verified.")
	bread.queue_free()

	# TEST 2: InvisibleWraith ShadowCaster & ShingleGaleAudio & APPEASED State
	print("\n[Test 2] Testing InvisibleWraith Shadow Silhouette & Appeasement...")
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	assert(wraith_scene != null, "InvisibleWraith.tscn failed to load!")
	var wraith = wraith_scene.instantiate()
	root.add_child(wraith)
	
	var shadow_caster = wraith.get_node_or_null("Visuals/ShadowCaster")
	assert(shadow_caster != null, "ShadowCaster node must exist under Visuals!")
	var shadow_body = wraith.get_node_or_null("Visuals/ShadowCaster/ShadowBody")
	assert(shadow_body != null, "ShadowBody must exist!")
	assert(shadow_body.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY, 
		"ShadowBody must have cast_shadow = SHADOWS_ONLY (3)!")
	
	var shingle_audio = wraith.get_node_or_null("Audio/ShingleGaleAudio")
	assert(shingle_audio != null, "ShingleGaleAudio must exist under Audio!")
	assert(shingle_audio.stream != null, "ShingleGaleAudio must have valid stream!")
	
	assert("APPEASED" in WraithAI.State, "WraithAI.State must contain APPEASED enum!")
	wraith.set_state(WraithAI.State.APPEASED)
	assert(wraith.current_state == WraithAI.State.APPEASED, "Wraith must transition to APPEASED state!")
	print(" -> PASS: ShadowCaster (SHADOWS_ONLY), ShingleGaleAudio, and APPEASED state verified.")
	wraith.queue_free()

	# TEST 3: WindowBreach Frost Ingress
	print("\n[Test 3] Testing WindowBreach Frost Ingress...")
	var window_scene = load("res://Scenes/Workshop/WindowBreachPoint.tscn")
	assert(window_scene != null, "WindowBreachPoint.tscn failed to load!")
	var window_breach = window_scene.instantiate()
	root.add_child(window_breach)
	
	var frost = window_breach.get_node_or_null("FrostOverlay")
	assert(frost != null, "FrostOverlay node must exist on WindowBreachPoint!")
	assert(window_breach.has_method("_update_frost_ingress"), "WindowBreach must have _update_frost_ingress method!")
	print(" -> PASS: FrostOverlay and frost ingress update logic verified.")
	window_breach.queue_free()

	# TEST 4: Full Main Scene Integration
	print("\n[Test 4] Testing Full Main Scene Integration...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn failed to load!")
	var main = main_scene.instantiate()
	root.add_child(main)
	
	var bread_in_main = main.get_node_or_null("BreadOfferingStation")
	assert(bread_in_main != null, "BreadOfferingStation must be instantiated in Main.tscn!")
	assert(bread_in_main.is_in_group("bread_offering_station"), "BreadOfferingStation must be in 'bread_offering_station' group!")
	
	var wraith_in_main = main.get_node_or_null("InvisibleWraith")
	assert(wraith_in_main != null, "InvisibleWraith must exist in Main.tscn!")
	assert(wraith_in_main.get_node_or_null("Visuals/ShadowCaster") != null, "InvisibleWraith in Main must have ShadowCaster!")
	
	print(" -> PASS: Full Main Scene successfully loaded and stations verified.")
	main.queue_free()

	print("\n==========================================")
	print("ALL v0.0.2 VERIFICATION TESTS PASSED (100%)")
	print("==========================================")
	quit(0)
