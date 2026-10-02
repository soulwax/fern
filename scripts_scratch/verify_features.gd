extends SceneTree

func _init() -> void:
	print("--- VERIFYING FEATURES: Candles & Ladder in Main.tscn ---")
	var main_packed = load("res://Scenes/Main.tscn")
	if not main_packed:
		printerr("FAILED to load Main.tscn!")
		quit(1)
		return
	
	var main = main_packed.instantiate()
	root.add_child(main)
	print("Main.tscn instantiated successfully.")
	
	# Verify Candles
	var candles = [
		main.get_node_or_null("CandleWorkbench"),
		main.get_node_or_null("CandleGrindstone"),
		main.get_node_or_null("CandleAnvil")
	]
	
	for i in range(candles.size()):
		var c = candles[i]
		if not c:
			printerr("Candle %d missing!" % i)
			quit(1)
			return
		print("Candle %d found: is_lit=%s" % [i, c.is_lit])
	
	# Test candle snuffing
	var c0 = candles[0]
	c0.snuff_candle()
	print("Candle 0 snuffed: is_lit=%s, prompt=%s" % [c0.is_lit, c0.get_interaction_prompt()])
	assert(not c0.is_lit, "Candle should be unlit")
	assert(c0.get_interaction_prompt().contains("Relight"), "Prompt should say Relight")
	
	# Test candle relighting
	c0.relight_candle()
	print("Candle 0 relit: is_lit=%s" % c0.is_lit)
	assert(c0.is_lit, "Candle should be lit again")
	
	# Verify Ladder
	var ladder = main.get_node_or_null("LadderLoft")
	if not ladder:
		printerr("LadderLoft missing!")
		quit(1)
		return
	print("LadderLoft found: prompt=%s" % ladder.get_interaction_prompt())
	
	var b_mount = ladder.get_node_or_null("BottomMount")
	var t_mount = ladder.get_node_or_null("TopMount")
	assert(b_mount != null, "BottomMount should exist")
	assert(t_mount != null, "TopMount should exist")
	print("Ladder mounts: bottom=%s, top=%s" % [b_mount.position, t_mount.position])
	
	print("ALL CANDLE & LADDER TESTS PASSED!")
	quit(0)
