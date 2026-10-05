extends SceneTree

func _init() -> void:
	print("--- Running FERN Milestone v1.8.0 Feature Verification ---")

	# Test 1: LightningLight and ThunderAudio in Main.tscn
	print("[1/4] Verifying Lightning & Thunder in Main.tscn...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_instance = main_scene.instantiate()
	assert(main_instance != null, "Main.tscn must instantiate cleanly")

	var lightning_light = main_instance.get_node_or_null("LightningLight")
	assert(lightning_light != null, "LightningLight must exist in Main.tscn")
	assert(lightning_light is DirectionalLight3D, "LightningLight must be DirectionalLight3D")
	assert(lightning_light.shadow_enabled == false, "LightningLight flash must not cast shadows")

	var thunder_audio = main_instance.get_node_or_null("Audio/ThunderAudio")
	assert(thunder_audio != null, "ThunderAudio must exist under Audio/ in Main.tscn")
	assert(thunder_audio is AudioStreamPlayer, "ThunderAudio must be AudioStreamPlayer")
	assert(thunder_audio.bus == &"Ambiance", "ThunderAudio must route to Ambiance bus")
	assert(thunder_audio.stream != null, "ThunderAudio must have audio stream assigned")
	print("  -> Passed: LightningLight and ThunderAudio properly configured.")

	# Test 2: ColdBreathParticles and ColdBreathAudio in Player.tscn
	print("[2/4] Verifying Cold Breath system in Player.tscn...")
	var player_scene = load("res://Scenes/Player/Player.tscn")
	assert(player_scene != null, "Player.tscn must load successfully")
	var player_instance = player_scene.instantiate()
	assert(player_instance != null, "Player.tscn must instantiate cleanly")

	var breath_particles = player_instance.get_node_or_null("Head/Camera3D/ColdBreathParticles")
	assert(breath_particles != null, "ColdBreathParticles must exist under Head/Camera3D/")
	assert(breath_particles is GPUParticles3D, "ColdBreathParticles must be GPUParticles3D")

	var breath_audio = player_instance.get_node_or_null("Head/Camera3D/ColdBreathAudio")
	assert(breath_audio != null, "ColdBreathAudio must exist under Head/Camera3D/")
	assert(breath_audio is AudioStreamPlayer3D, "ColdBreathAudio must be AudioStreamPlayer3D")
	assert(breath_audio.bus == &"SFX", "ColdBreathAudio must route to SFX bus")
	assert(breath_audio.stream != null, "ColdBreathAudio must have audio stream assigned")

	var breath_emitted = [false]
	player_instance.cold_breath_emitted.connect(func(): breath_emitted[0] = true)
	player_instance.trigger_cold_breath()
	assert(breath_emitted[0] == true, "trigger_cold_breath() must emit cold_breath_emitted signal")
	print("  -> Passed: Cold Breath particles, audio, and triggering verified.")

	# Test 3: HangingChainProp audio buses and clinking trigger
	print("[3/4] Verifying HangingChainProp and SFX bus routing...")
	var chain_scene = load("res://Scenes/Workshop/HangingChainProp.tscn")
	assert(chain_scene != null, "HangingChainProp.tscn must load successfully")
	var chain_instance = chain_scene.instantiate()
	assert(chain_instance != null, "HangingChainProp.tscn must instantiate cleanly")

	var creak_audio = chain_instance.get_node_or_null("CreakAudio")
	assert(creak_audio != null, "CreakAudio must exist in HangingChainProp")
	assert(creak_audio.bus == &"SFX", "CreakAudio must route to SFX bus")

	var clink_audio = chain_instance.get_node_or_null("ChainClinkAudio")
	assert(clink_audio != null, "ChainClinkAudio must exist in HangingChainProp")
	assert(clink_audio is AudioStreamPlayer3D, "ChainClinkAudio must be AudioStreamPlayer3D")
	assert(clink_audio.bus == &"SFX", "ChainClinkAudio must route to SFX bus")
	assert(clink_audio.stream != null, "ChainClinkAudio must have audio stream assigned")

	var swung_signal_received = [false]
	chain_instance.chain_swung.connect(func(_impulse): swung_signal_received[0] = true)
	chain_instance.trigger_swing(Vector3(1.0, 0.0, 0.0))
	assert(chain_instance.is_swinging == true, "trigger_swing() must start swinging")
	assert(swung_signal_received[0] == true, "trigger_swing() must emit chain_swung signal")
	print("  -> Passed: HangingChainProp audio routing and swing trigger verified.")

	# Test 4: Main scene chain instances verification
	print("[4/4] Verifying Main scene chain instances...")
	var chain1 = main_instance.get_node_or_null("HangingChain1")
	var chain2 = main_instance.get_node_or_null("HangingChain2")
	assert(chain1 != null, "HangingChain1 must exist in Main.tscn")
	assert(chain2 != null, "HangingChain2 must exist in Main.tscn")
	assert(chain1 is HangingProp, "HangingChain1 must be HangingProp")
	assert(chain2 is HangingProp, "HangingChain2 must be HangingProp")
	print("  -> Passed: Main scene instances verified.")

	# Cleanup
	main_instance.free()
	player_instance.free()
	chain_instance.free()

	print("=======================================================")
	print("🎉 ALL v1.8.0 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")
	quit(0)
