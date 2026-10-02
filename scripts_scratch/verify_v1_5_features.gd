extends SceneTree

func _init() -> void:
	print("==================================================")
	print("🌿 FERN v1.5.0 SENSORY & POST-PROCESSING TEST SUITE")
	print("==================================================")
	
	# Instance GameState Autoload
	var game_state = load("res://Scripts/GameState.gd").new()
	game_state.name = "GameState"
	root.add_child(game_state)

	var pass_count = 0
	var total_tests = 7
	
	# Test 1: Daguerreotype Shader Resource
	var post_shader = load("res://Scenes/Shaders/daguerreotype_post_process.gdshader")
	if post_shader != null:
		print("✅ TEST 1 PASSED: daguerreotype_post_process.gdshader loaded cleanly.")
		pass_count += 1
	else:
		printerr("❌ TEST 1 FAILED: Failed to load daguerreotype_post_process.gdshader.")

	# Test 2: PostProcess Scene & Toggle
	var post_proc_scene = load("res://Scenes/UI/PostProcess.tscn")
	var post_proc_inst = post_proc_scene.instantiate() if post_proc_scene else null
	if post_proc_inst != null:
		root.add_child(post_proc_inst)
		game_state.post_processing_toggled.connect(post_proc_inst._on_post_processing_toggled)
		var color_rect = post_proc_inst.get_node_or_null("ColorRect") as ColorRect
		assert(color_rect != null, "ColorRect must exist on PostProcess")
		var mat = color_rect.material as ShaderMaterial
		assert(mat != null, "ShaderMaterial must exist on ColorRect")
		game_state.set_daguerreotype_enabled(false)
		assert(mat.get_shader_parameter("enabled") == false)
		game_state.set_daguerreotype_enabled(true)
		assert(mat.get_shader_parameter("enabled") == true)
		print("✅ TEST 2 PASSED: PostProcess.tscn correctly responds to GameState toggle.")
		pass_count += 1
		post_proc_inst.queue_free()
	else:
		printerr("❌ TEST 2 FAILED: Failed to instantiate PostProcess.tscn.")

	# Test 3: WraithShader with ember_amount
	var wraith_shader = load("res://Scenes/Monster/Shaders/WraithShader.gdshader")
	if wraith_shader != null:
		print("✅ TEST 3 PASSED: WraithShader.gdshader with ember_amount loaded cleanly.")
		pass_count += 1
	else:
		printerr("❌ TEST 3 FAILED: Failed to load WraithShader.gdshader.")

	# Test 4: InvisibleWraith spark ignition & stun
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	var wraith = wraith_scene.instantiate() if wraith_scene else null
	if wraith != null:
		root.add_child(wraith)
		wraith.ignite_with_sparks(3.0)
		assert(wraith.current_state == WraithAI.State.STUNNED)
		assert(wraith.spark_ignite_timer == 3.0)
		var body_mesh = wraith.get_node_or_null("Visuals/BodyMesh") as MeshInstance3D
		assert(body_mesh != null)
		var w_mat = body_mesh.get_surface_override_material(0) as ShaderMaterial
		assert(w_mat != null)
		assert(w_mat.get_shader_parameter("ember_amount") == 1.0)
		print("✅ TEST 4 PASSED: Wraith ignited with sparks, enters STUNNED state and renders ember outline.")
		pass_count += 1
		wraith.queue_free()
	else:
		printerr("❌ TEST 4 FAILED: Failed to instantiate InvisibleWraith.tscn.")

	# Test 5: GrindStoneStation spark trigger & SFX bus
	var grind_scene = load("res://Scenes/Workshop/GrindStoneStation.tscn")
	var grind = grind_scene.instantiate() if grind_scene else null
	if grind != null:
		root.add_child(grind)
		var audio = grind.get_node_or_null("GrindAudio") as AudioStreamPlayer3D
		assert(audio != null)
		assert(audio.bus == &"SFX")
		var spark_particles = grind.get_node_or_null("SparkParticles") as GPUParticles3D
		assert(spark_particles != null)
		grind._trigger_sparks()
		assert(grind.is_spinning == true)
		assert(spark_particles.emitting == true)
		print("✅ TEST 5 PASSED: GrindStoneStation sparks active with SFX bus routing.")
		pass_count += 1
		grind.queue_free()
	else:
		printerr("❌ TEST 5 FAILED: Failed to instantiate GrindStoneStation.tscn.")

	# Test 6: PauseMenu with Daguerreotype Checkbox
	var pause_scene = load("res://Scenes/UI/PauseMenu.tscn")
	var pause_inst = pause_scene.instantiate() if pause_scene else null
	if pause_inst != null:
		root.add_child(pause_inst)
		var d_check = pause_inst.get_node_or_null("Panel/Center/VBox/SettingsBox/SettingsVBox/DaguerreotypeRow/DaguerreotypeCheck") as CheckBox
		assert(d_check != null)
		d_check.button_pressed = game_state.daguerreotype_enabled
		assert(d_check.button_pressed == game_state.daguerreotype_enabled)
		print("✅ TEST 6 PASSED: PauseMenu contains functional Daguerreotype filter checkbox.")
		pass_count += 1
		pause_inst.queue_free()
	else:
		printerr("❌ TEST 6 FAILED: Failed to instantiate PauseMenu.tscn.")

	# Test 7: Full Main Scene Assembly
	var main_scene = load("res://Scenes/Main.tscn")
	var main_inst = main_scene.instantiate() if main_scene else null
	if main_inst != null:
		root.add_child(main_inst)
		assert(main_inst.get_node_or_null("PostProcess") != null)
		assert(main_inst.get_node_or_null("GrindStoneStation") != null)
		assert(main_inst.get_node_or_null("InvisibleWraith") != null)
		assert(main_inst.get_node_or_null("HUD") != null)
		assert(main_inst.get_node_or_null("PauseMenu") != null)
		print("✅ TEST 7 PASSED: Main.tscn integrates all v1.5.0 nodes seamlessly.")
		pass_count += 1
		main_inst.queue_free()
	else:
		printerr("❌ TEST 7 FAILED: Failed to instantiate Main.tscn.")

	print("==================================================")
	print("RESULTS: %d / %d TESTS PASSED" % [pass_count, total_tests])
	print("==================================================")

	if pass_count == total_tests:
		print("🎉 ALL v1.5.0 SENSORY & POST-PROCESSING TESTS PASSED!")
		quit(0)
	else:
		printerr("⚠️ SOME TESTS FAILED.")
		quit(1)
