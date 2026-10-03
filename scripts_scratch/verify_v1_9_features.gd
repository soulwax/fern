extends SceneTree

const MirrorStationClass = preload("res://Scripts/Workshop/MirrorStation.gd")
const WorkbenchPropGroupClass = preload("res://Scripts/Workshop/WorkbenchPropGroup.gd")

func _init() -> void:
	print("--- Running FERN Milestone v0.0.1 Feature Verification ---")

	# Test 1: MirrorStation node structure, SubViewport, and Layer 2 visibility
	print("[1/5] Verifying MirrorStation.tscn...")
	var mirror_scene = load("res://Scenes/Workshop/MirrorStation.tscn")
	assert(mirror_scene != null, "MirrorStation.tscn must load successfully")
	var mirror_instance = mirror_scene.instantiate()
	assert(mirror_instance != null, "MirrorStation.tscn must instantiate cleanly")

	var sub_viewport = mirror_instance.get_node_or_null("SubViewport")
	assert(sub_viewport != null, "SubViewport must exist in MirrorStation")
	var ref_camera = sub_viewport.get_node_or_null("ReflectionCamera")
	assert(ref_camera != null, "ReflectionCamera must exist under SubViewport")
	assert((ref_camera.cull_mask & 2) != 0, "ReflectionCamera must have Layer 2 enabled to see wraith mirror visuals")

	var wipe_audio = mirror_instance.get_node_or_null("WipeAudio")
	assert(wipe_audio != null, "WipeAudio must exist in MirrorStation")
	assert(wipe_audio is AudioStreamPlayer3D, "WipeAudio must be AudioStreamPlayer3D")
	assert(wipe_audio.bus == &"SFX", "WipeAudio must route to SFX bus")
	assert(wipe_audio.stream != null, "WipeAudio must have audio stream assigned")

	var mirror_wiped_called = [false]
	mirror_instance.mirror_wiped.connect(func(): mirror_wiped_called[0] = true)
	mirror_instance.wipe_mirror()
	assert(mirror_instance.is_wiped_clean == true, "wipe_mirror() must set is_wiped_clean to true")
	assert(mirror_wiped_called[0] == true, "wipe_mirror() must emit mirror_wiped signal")
	print("  -> Passed: MirrorStation reflection setup, wipe foley, and Layer 2 mask verified.")

	# Test 2: InvisibleWraith SpectralReflectionMesh and FloorCreakAudio
	print("[2/5] Verifying InvisibleWraith MirrorVisuals and FloorCreakAudio...")
	var wraith_scene = load("res://Scenes/Monster/InvisibleWraith.tscn")
	assert(wraith_scene != null, "InvisibleWraith.tscn must load successfully")
	var wraith_instance = wraith_scene.instantiate()
	assert(wraith_instance != null, "InvisibleWraith.tscn must instantiate cleanly")

	var mirror_visuals = wraith_instance.get_node_or_null("Visuals/MirrorVisuals")
	assert(mirror_visuals != null, "MirrorVisuals must exist under Visuals in InvisibleWraith")
	var mirror_body = mirror_visuals.get_node_or_null("MirrorBodyMesh")
	assert(mirror_body != null, "MirrorBodyMesh must exist under MirrorVisuals")
	assert(mirror_body.layers == 2, "MirrorBodyMesh must be assigned strictly to Visual Layer 2")

	var creak_audio = wraith_instance.get_node_or_null("Audio/FloorCreakAudio")
	assert(creak_audio != null, "FloorCreakAudio must exist under Audio in InvisibleWraith")
	assert(creak_audio is AudioStreamPlayer3D, "FloorCreakAudio must be AudioStreamPlayer3D")
	assert(creak_audio.bus == &"SFX", "FloorCreakAudio must route to SFX bus")
	assert(creak_audio.stream != null, "FloorCreakAudio must have audio stream assigned")

	var creaked_received = [false]
	var rafter_flag = [false]
	wraith_instance.floorboard_creaked.connect(func(pos, is_rafter):
		creaked_received[0] = true
		rafter_flag[0] = is_rafter
	)
	wraith_instance.position = Vector3(0.0, 3.5, 0.0) # In rafters
	wraith_instance.trigger_floor_creak()
	assert(creaked_received[0] == true, "trigger_floor_creak() must emit floorboard_creaked signal")
	assert(rafter_flag[0] == true, "altitude > 2.8m must flag is_rafter = true")
	print("  -> Passed: InvisibleWraith MirrorVisuals on Layer 2 and FloorCreak verified.")

	# Test 3: Player Camera3D Layer 2 culling
	print("[3/5] Verifying Player Camera3D culls Layer 2...")
	var player_scene = load("res://Scenes/Player/Player.tscn")
	assert(player_scene != null, "Player.tscn must load successfully")
	var player_instance = player_scene.instantiate()
	assert(player_instance != null, "Player.tscn must instantiate cleanly")
	var player_cam = player_instance.get_node_or_null("Head/Camera3D")
	assert(player_cam != null, "Player Camera3D must exist")
	assert((player_cam.cull_mask & 2) == 0, "Player Camera3D must NOT render Layer 2 (invisible to mortal eyes)")
	print("  -> Passed: Player camera correctly excludes Layer 2.")

	# Test 4: WorkbenchPropGroup tool vibration and rattle
	print("[4/5] Verifying WorkbenchPropGroup...")
	var props_scene = load("res://Scenes/Workshop/WorkbenchPropGroup.tscn")
	assert(props_scene != null, "WorkbenchPropGroup.tscn must load successfully")
	var props_instance = props_scene.instantiate()
	assert(props_instance != null, "WorkbenchPropGroup.tscn must instantiate cleanly")

	var rattle_audio = props_instance.get_node_or_null("RattleAudio")
	assert(rattle_audio != null, "RattleAudio must exist in WorkbenchPropGroup")
	assert(rattle_audio is AudioStreamPlayer3D, "RattleAudio must be AudioStreamPlayer3D")
	assert(rattle_audio.bus == &"SFX", "RattleAudio must route to SFX bus")
	assert(rattle_audio.stream != null, "RattleAudio must have audio stream assigned")

	var rattled_received = [false]
	props_instance.tools_rattled.connect(func(): rattled_received[0] = true)
	props_instance.trigger_rattle()
	assert(props_instance.is_vibrating == true, "trigger_rattle() must set is_vibrating to true")
	assert(rattled_received[0] == true, "trigger_rattle() must emit tools_rattled signal")
	print("  -> Passed: WorkbenchPropGroup vibration and rattle verified.")

	# Test 5: Main.tscn integration
	print("[5/5] Verifying Main.tscn integration...")
	var main_scene = load("res://Scenes/Main.tscn")
	assert(main_scene != null, "Main.tscn must load successfully")
	var main_instance = main_scene.instantiate()
	assert(main_instance != null, "Main.tscn must instantiate cleanly")

	var main_mirror = main_instance.get_node_or_null("MirrorStation")
	assert(main_mirror != null, "MirrorStation must exist in Main.tscn")
	assert(main_mirror is MirrorStationClass, "MirrorStation must be MirrorStation instance")

	var main_props = main_instance.get_node_or_null("WorkbenchProps")
	assert(main_props != null, "WorkbenchProps must exist in Main.tscn")
	assert(main_props is WorkbenchPropGroupClass, "WorkbenchProps must be WorkbenchPropGroup instance")
	print("  -> Passed: Main.tscn integration verified.")

	# Cleanup
	mirror_instance.free()
	wraith_instance.free()
	player_instance.free()
	props_instance.free()
	main_instance.free()

	print("=======================================================")
	print("🎉 ALL v0.0.1 FEATURE VERIFICATIONS PASSED SUCCESSFULLY!")
	print("=======================================================")
	quit(0)
