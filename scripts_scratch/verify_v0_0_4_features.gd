extends SceneTree

func _init() -> void:
	print("--- Running FERN Milestone v0.0.4 Feature Verification ---")

	# 1. Verify KienspanTorchStation
	print("[1/4] Verifying KienspanTorchStation.tscn & wraith repulsion aura...")
	var torch_scene = load("res://Scenes/Workshop/KienspanTorchStation.tscn")
	assert(torch_scene != null, "KienspanTorchStation.tscn must load successfully")
	var torch = torch_scene.instantiate()
	assert(torch != null, "KienspanTorchStation must instantiate")
	root.add_child(torch)
	torch._ready()

	assert(torch.is_lit == false, "Torch must start unlit in sconce")
	assert(torch.burn_timer == 0.0, "Burn timer must start at 0")

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
	wraith.position = Vector3(0, 0, 2.0) # Within 4.2m repel radius

	# Ignite torch
	torch.ignite_torch(mock_player)
	assert(torch.is_lit == true, "Torch must be lit after ignition")
	assert(torch.is_held == true, "Torch must be held by player after ignition")
	assert(torch.burn_timer == torch.max_burn_duration, "Burn timer must match max_burn_duration")

	# Check proximity repulsion
	torch.wraith_ref = wraith
	torch._check_repel_wraith()
	assert(wraith.current_state == wraith.State.REPELLED, "Wraith must be repelled by Kienspan torch")

	# Fast forward burn timer to extinction
	torch._process(26.0)
	assert(torch.is_lit == false, "Torch must extinguish when burn timer reaches 0")
	assert(torch.cooldown_timer > 0.0, "Cooldown timer must be active after extinction")
	print("  -> Passed: KienspanTorchStation ignition, timer decay & wraith repulsion verified.")

	# 2. Verify WindowBreach with Drop-Latch
	print("[2/4] Verifying WindowBreachPoint.tscn shutter drop-latch mechanics...")
	var window_scene = load("res://Scenes/Workshop/WindowBreachPoint.tscn")
	assert(window_scene != null, "WindowBreachPoint.tscn must load successfully")
	var window = window_scene.instantiate()
	root.add_child(window)
	window._ready()

	assert(window.is_latched == true, "Window must start with drop-latch secured")
	assert(window.latch_health == 2, "Latch health must start at 2")
	var initial_planks = window.current_planks

	# Start rattle
	window.start_rattle(2.0)
	assert(window.is_rattling == true, "Window must be in rattling state")
	window.stop_rattle()
	assert(window.is_rattling == false, "Window rattle must stop cleanly")

	# First siege hit: absorbed by latch
	var breached_1 = window.breach_plank()
	assert(breached_1 == false, "First siege hit must be absorbed by drop-latch (no plank lost)")
	assert(window.latch_health == 1, "Latch health must decrement to 1")
	assert(window.current_planks == initial_planks, "Plank count must be unchanged")

	# Second siege hit: absorbed by latch, breaking the latch
	var breached_2 = window.breach_plank()
	assert(breached_2 == false, "Second siege hit must be absorbed by drop-latch")
	assert(window.latch_health == 0, "Latch health must reach 0")
	assert(window.is_latched == false, "Drop-latch must swing open after health depletes")
	assert(window.current_planks == initial_planks, "Plank count must still be unchanged")

	# Third siege hit: latch broken, plank breached!
	var breached_3 = window.breach_plank()
	assert(breached_3 == true, "Third siege hit without latch must breach a plank")
	assert(window.current_planks == initial_planks - 1, "Plank count must decrement after latch fails")

	# Re-secure latch
	window.secure_latch()
	assert(window.is_latched == true, "Latch must be re-secured")
	assert(window.latch_health == 2, "Latch health must be restored to 2")
	print("  -> Passed: WindowBreach drop-latch impact absorption & re-securing verified.")

	# 3. Verify ResinCauldronStation
	print("[3/4] Verifying ResinCauldronStation.tscn & anti-rafter pine vapor...")
	var cauldron_scene = load("res://Scenes/Workshop/ResinCauldronStation.tscn")
	assert(cauldron_scene != null, "ResinCauldronStation.tscn must load successfully")
	var cauldron = cauldron_scene.instantiate()
	root.add_child(cauldron)
	cauldron._ready()

	assert(cauldron.is_boiling == false, "Cauldron must start in idle simmer")
	assert(cauldron.boil_timer == 0.0, "Boil timer must start at 0")

	# Stoke cauldron
	cauldron.stoke()
	assert(cauldron.is_boiling == true, "Cauldron must be boiling after being stoked")
	assert(cauldron.boil_timer == cauldron.max_boil_duration, "Boil timer must match max_boil_duration")

	# Test rafter denial on wraith
	wraith.set_rafter_denial(cauldron.max_boil_duration)
	assert(wraith.rafter_denial_timer == cauldron.max_boil_duration, "Wraith rafter_denial_timer must be active")
	
	# Verify waypoint selection excludes rafters (Y > 2.0)
	for i in range(10):
		wraith._pick_next_waypoint()
		assert(wraith.current_target_point.y < 2.0, "Waypoint must not be on rafters during rafter denial")

	# Settle cauldron
	cauldron.settle()
	assert(cauldron.is_boiling == false, "Cauldron must settle into idle simmer")
	print("  -> Passed: ResinCauldronStation boiling, vapor timing & rafter denial verified.")

	# 4. Verify Main.tscn Scene Assembly
	print("[4/4] Verifying Main.tscn scene assembly with v0.0.4 stations...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_node = main_scene.instantiate()
	assert(main_node != null, "Main.tscn must instantiate")

	var torch_node = main_node.get_node_or_null("KienspanTorchStation")
	assert(torch_node != null, "Main.tscn must contain KienspanTorchStation")
	print("  -> KienspanTorchStation position: %s" % str(torch_node.position))

	var cauldron_node = main_node.get_node_or_null("ResinCauldronStation")
	assert(cauldron_node != null, "Main.tscn must contain ResinCauldronStation")
	print("  -> ResinCauldronStation position: %s" % str(cauldron_node.position))

	# Cleanup test nodes
	mock_player.queue_free()
	wraith.queue_free()
	torch.queue_free()
	window.queue_free()
	cauldron.queue_free()
	main_node.queue_free()

	print("=======================================================")
	print("🎉 ALL v0.0.4 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")
	quit(0)
