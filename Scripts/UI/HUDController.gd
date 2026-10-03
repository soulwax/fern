extends CanvasLayer
class_name HUDController

@onready var reticle: CenterContainer = $Reticle
@onready var reticle_dot: ColorRect = $Reticle/Dot
@onready var prompt_label: Label = $PromptContainer/PromptLabel
@onready var hour_label: Label = $TopBar/HourLabel
@onready var hour_bar: ProgressBar = $TopBar/HourBar
@onready var bloom_bar: ProgressBar = $BottomLeft/BloomContainer/BloomBar
@onready var bloom_state_label: Label = $BottomLeft/BloomContainer/BloomStateLabel
@onready var vignette_rect: ColorRect = $VignetteRect
@onready var game_over_panel: Panel = $GameOverPanel
@onready var victory_panel: Panel = $VictoryPanel
@onready var heartbeat_slow_audio: AudioStreamPlayer = $HeartbeatSlowAudio
@onready var heartbeat_fast_audio: AudioStreamPlayer = $HeartbeatFastAudio

@onready var screech_audio: AudioStreamPlayer = $ScreechAudio
@onready var claw_strike_rect: ColorRect = $ClawStrikeRect
@onready var stats_label: Label = $GameOverPanel/Center/VBox/StatsLabel

var player_ref: Node = null
var wraith_ref: Node = null
var _is_dying: bool = false

func _ensure_nodes() -> void:
	if not heartbeat_slow_audio:
		heartbeat_slow_audio = get_node_or_null("HeartbeatSlowAudio")
	if not heartbeat_fast_audio:
		heartbeat_fast_audio = get_node_or_null("HeartbeatFastAudio")
	if not vignette_rect:
		vignette_rect = get_node_or_null("VignetteRect")

func _ready() -> void:
	_ensure_nodes()
	if game_over_panel:
		game_over_panel.visible = false
	if victory_panel:
		victory_panel.visible = false
	if prompt_label:
		prompt_label.text = ""
		
	# Hook to GameState if available
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		game_state.hour_changed.connect(_on_hour_changed)
		game_state.game_won.connect(_on_game_won)
		game_state.game_lost.connect(_on_game_lost)
		hour_label.text = game_state.get_current_hour_name()

	_find_player_and_wraith()

func _find_player_and_wraith() -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]
		player_ref.prompt_changed.connect(_on_prompt_changed)
		
		var farnblume = player_ref.find_child("Farnblume", true, false)
		if farnblume and farnblume.has_signal("bloom_energy_changed"):
			farnblume.bloom_energy_changed.connect(_on_bloom_energy_changed)
			farnblume.cupped_state_changed.connect(_on_cupped_state_changed)
			
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	if wraiths.size() > 0:
		wraith_ref = wraiths[0]
		if wraith_ref.has_signal("player_caught"):
			wraith_ref.player_caught.connect(_on_player_caught)

func _process(delta: float) -> void:
	_ensure_nodes()
	var game_state = get_node_or_null("/root/GameState")
	if game_state and hour_bar:
		var total_progress = (float(game_state.current_hour) + game_state.get_hour_progress()) / float(game_state.max_hours)
		hour_bar.value = total_progress * 100.0

	# Calculate fear vignette and heartbeat based on proximity to unseen entity
	if player_ref and wraith_ref and not _is_dying:
		var dist = get_proximity_distance()
		var slow_thresh = 12.0
		var fast_thresh = 6.0
		if game_state and game_state.current_difficulty == game_state.Difficulty.WALPURGISNACHT:
			slow_thresh = 15.0
			fast_thresh = 8.0
			
		if dist <= fast_thresh:
			# Frantic panic pulse
			var panic_factor = clamp(1.0 - (dist / fast_thresh), 0.0, 1.0)
			if vignette_rect:
				vignette_rect.color.a = lerp(vignette_rect.color.a, 0.35 + panic_factor * 0.45, delta * 4.0)
			if heartbeat_fast_audio and heartbeat_fast_audio.is_inside_tree():
				if not heartbeat_fast_audio.playing:
					heartbeat_fast_audio.play()
				heartbeat_fast_audio.volume_db = lerp(heartbeat_fast_audio.volume_db, -6.0 + (panic_factor * 4.0), delta * 4.0)
			if heartbeat_slow_audio and heartbeat_slow_audio.is_inside_tree() and heartbeat_slow_audio.playing:
				heartbeat_slow_audio.volume_db = lerp(heartbeat_slow_audio.volume_db, -80.0, delta * 6.0)
				if heartbeat_slow_audio.volume_db <= -70.0:
					heartbeat_slow_audio.stop()
		elif dist <= slow_thresh:
			# Creeping dread slow heartbeat
			var slow_factor = clamp(1.0 - ((dist - fast_thresh) / (slow_thresh - fast_thresh)), 0.0, 1.0)
			if vignette_rect:
				vignette_rect.color.a = lerp(vignette_rect.color.a, slow_factor * 0.30, delta * 3.0)
			if heartbeat_slow_audio and heartbeat_slow_audio.is_inside_tree():
				if not heartbeat_slow_audio.playing:
					heartbeat_slow_audio.play()
				heartbeat_slow_audio.volume_db = lerp(heartbeat_slow_audio.volume_db, -24.0 + (slow_factor * 12.0), delta * 3.0)
			if heartbeat_fast_audio and heartbeat_fast_audio.is_inside_tree() and heartbeat_fast_audio.playing:
				heartbeat_fast_audio.volume_db = lerp(heartbeat_fast_audio.volume_db, -80.0, delta * 6.0)
				if heartbeat_fast_audio.volume_db <= -70.0:
					heartbeat_fast_audio.stop()
		else:
			# Safe distance
			if vignette_rect:
				vignette_rect.color.a = lerp(vignette_rect.color.a, 0.0, delta * 3.0)
			if heartbeat_slow_audio and heartbeat_slow_audio.is_inside_tree() and heartbeat_slow_audio.playing:
				heartbeat_slow_audio.volume_db = lerp(heartbeat_slow_audio.volume_db, -80.0, delta * 5.0)
				if heartbeat_slow_audio.volume_db <= -70.0:
					heartbeat_slow_audio.stop()
			if heartbeat_fast_audio and heartbeat_fast_audio.is_inside_tree() and heartbeat_fast_audio.playing:
				heartbeat_fast_audio.volume_db = lerp(heartbeat_fast_audio.volume_db, -80.0, delta * 5.0)
				if heartbeat_fast_audio.volume_db <= -70.0:
					heartbeat_fast_audio.stop()

func get_proximity_distance() -> float:
	if player_ref and wraith_ref and is_instance_valid(player_ref) and is_instance_valid(wraith_ref):
		if player_ref is Node3D and wraith_ref is Node3D:
			if player_ref.is_inside_tree() and wraith_ref.is_inside_tree():
				return player_ref.global_position.distance_to(wraith_ref.global_position)
			return player_ref.position.distance_to(wraith_ref.position)
	return 999.0

func get_anxiety_state() -> String:
	var dist = get_proximity_distance()
	var game_state = get_node_or_null("/root/GameState")
	var slow_thresh = 12.0
	var fast_thresh = 6.0
	if game_state and game_state.current_difficulty == game_state.Difficulty.WALPURGISNACHT:
		slow_thresh = 15.0
		fast_thresh = 8.0
	if dist <= fast_thresh:
		return "PANIC"
	elif dist <= slow_thresh:
		return "CREEPING"
	return "SAFE"


func _on_prompt_changed(text: String) -> void:
	if prompt_label:
		prompt_label.text = text
	if reticle_dot:
		reticle_dot.color = Color(0.4, 0.8, 1.0) if text != "" else Color(1, 1, 1, 0.7)

func _on_hour_changed(_hour: int, hour_name: String) -> void:
	if hour_label:
		hour_label.text = hour_name

func _on_bloom_energy_changed(curr: float, max_val: float) -> void:
	if bloom_bar:
		bloom_bar.value = (curr / max_val) * 100.0

func _on_cupped_state_changed(is_cupped: bool) -> void:
	if bloom_state_label:
		bloom_state_label.text = "[R] Hände schützend gekrümmt" if is_cupped else "Farnblume leuchtet [R: Schützen]"

func _get_game_state() -> Node:
	if is_inside_tree() and get_tree().root:
		return get_tree().root.get_node_or_null("GameState")
	return null

func _on_player_caught() -> void:
	if _is_dying:
		return
	_is_dying = true
	
	if heartbeat_slow_audio and heartbeat_slow_audio.playing:
		heartbeat_slow_audio.stop()
	if heartbeat_fast_audio and heartbeat_fast_audio.playing:
		heartbeat_fast_audio.stop()
	
	if player_ref and player_ref.has_method("set_movement_frozen"):
		player_ref.set_movement_frozen(true)
	
	# Turn to face the horrifying antlered wraith
	if player_ref and wraith_ref:
		var target_pos = Vector3(wraith_ref.global_position.x, player_ref.global_position.y, wraith_ref.global_position.z)
		player_ref.look_at(target_pos)
		
	if screech_audio:
		screech_audio.play()
		
	# Violent red claw strike flash
	if not claw_strike_rect:
		claw_strike_rect = get_node_or_null("ClawStrikeRect")
		
	if claw_strike_rect:
		claw_strike_rect.color.a = 0.95
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(claw_strike_rect, "color:a", 1.0, 0.6)
		tween.finished.connect(func():
			var game_state = _get_game_state()
			if game_state:
				game_state.trigger_defeat()
		)
	else:
		var game_state = _get_game_state()
		if game_state:
			game_state.trigger_defeat()

func _on_game_lost() -> void:
	if not game_over_panel:
		game_over_panel = get_node_or_null("GameOverPanel")
	if not stats_label:
		stats_label = get_node_or_null("GameOverPanel/Center/VBox/StatsLabel")
		
	var game_state = _get_game_state()
	if stats_label and game_state:
		stats_label.text = "Überlebt bis: %s  |  Schwierigkeit: %s" % [game_state.get_current_hour_name(), game_state.get_difficulty_name()]
		
	if game_over_panel:
		game_over_panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_game_won() -> void:
	if victory_panel:
		victory_panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
