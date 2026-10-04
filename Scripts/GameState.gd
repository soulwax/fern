extends Node

signal hour_changed(current_hour: int, hour_name: String)
signal game_won()
signal game_lost()
signal ambient_bell_tolled()
signal post_processing_toggled(enabled: bool)
signal talisman_crafted()

enum Difficulty {
	MIDSUMMER,     # Standard 6-hour night
	WALPURGISNACHT, # Nightmare: +25% speed, 1.5x wilt
	STILLE_NACHT   # Story: 0.75x speed, 0.5x wilt
}

@export var current_difficulty: Difficulty = Difficulty.MIDSUMMER
@export var seconds_per_hour: float = 75.0
@export var current_hour: int = 0
@export var max_hours: int = 6

var elapsed_in_hour: float = 0.0
var is_game_active: bool = true
var daguerreotype_enabled: bool = true
var has_rowan_talisman: bool = false

func set_daguerreotype_enabled(enabled: bool) -> void:
	daguerreotype_enabled = enabled
	post_processing_toggled.emit(daguerreotype_enabled)


const HOUR_NAMES = [
	"00:00 (Die Geisterstunde)",
	"01:00 (Erste Nachtwache)",
	"02:00 (Das Raunen im Gebälk)",
	"03:00 (Die Totenstunde)",
	"04:00 (Kalter Morgennebel)",
	"05:00 (Der Dämmerung nahe)",
	"06:00 (Taganbruch & Frühglocke)"
]

func set_difficulty(diff: Difficulty) -> void:
	current_difficulty = diff

func get_difficulty_name() -> String:
	match current_difficulty:
		Difficulty.WALPURGISNACHT:
			return "Walpurgisnacht (Nightmare)"
		Difficulty.STILLE_NACHT:
			return "Stille Nacht (Story)"
		_:
			return "Midsummer Eve (Standard)"

func get_difficulty_description() -> String:
	match current_difficulty:
		Difficulty.WALPURGISNACHT:
			return "Nightmare terror: +25% wraith speed, 1.5x flower wilt, wider candle snuffing."
		Difficulty.STILLE_NACHT:
			return "Atmospheric mode: -25% wraith speed, 0.5x flower wilt, relaxed exploration."
		_:
			return "Standard Gothic horror: 6-hour survival night, balanced flower decay & aggression."

var open_window_breaches: int = 0

signal window_breached_count_changed(count: int)

func notify_window_breached() -> void:
	open_window_breaches = min(3, open_window_breaches + 1)
	window_breached_count_changed.emit(open_window_breaches)

func notify_window_repaired() -> void:
	open_window_breaches = max(0, open_window_breaches - 1)
	window_breached_count_changed.emit(open_window_breaches)

func get_breach_wilt_penalty() -> float:
	return 1.0 + (open_window_breaches * 0.20)

func get_wilt_rate_multiplier() -> float:
	var base_mult = 1.0
	match current_difficulty:
		Difficulty.WALPURGISNACHT:
			base_mult = 1.5
		Difficulty.STILLE_NACHT:
			base_mult = 0.5
		_:
			base_mult = 1.0
	return base_mult * get_breach_wilt_penalty()

func get_wraith_speed_multiplier() -> float:
	match current_difficulty:
		Difficulty.WALPURGISNACHT:
			return 1.25
		Difficulty.STILLE_NACHT:
			return 0.75
		_:
			return 1.0

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	current_hour = 0
	elapsed_in_hour = 0.0
	is_game_active = true
	open_window_breaches = 0
	has_rowan_talisman = false
	hour_changed.emit(current_hour, get_current_hour_name())


func _process(delta: float) -> void:
	if not is_game_active:
		return
		
	elapsed_in_hour += delta
	if elapsed_in_hour >= seconds_per_hour:
		elapsed_in_hour = 0.0
		advance_hour()

func advance_hour() -> void:
	if current_hour < max_hours:
		current_hour += 1
		ambient_bell_tolled.emit()
		hour_changed.emit(current_hour, get_current_hour_name())
		
		# Scale wraith aggression
		_apply_difficulty_scaling()
		
		if current_hour >= max_hours:
			trigger_victory()

func get_current_hour_name() -> String:
	if current_hour < HOUR_NAMES.size():
		return HOUR_NAMES[current_hour]
	return "06:00 (Taganbruch)"

func get_hour_progress() -> float:
	return clamp(elapsed_in_hour / seconds_per_hour, 0.0, 1.0)

func _get_active_tree() -> SceneTree:
	if is_inside_tree():
		return get_tree()
	return Engine.get_main_loop() as SceneTree

func trigger_victory() -> void:
	is_game_active = false
	game_won.emit()
	
	# Banish all unseen entities
	var tree = _get_active_tree()
	if tree:
		var wraiths = tree.get_nodes_in_group("unseen_entity")
		for w in wraiths:
			if w.has_method("banish"):
				w.banish()

func trigger_defeat() -> void:
	if not is_game_active:
		return
	is_game_active = false
	game_lost.emit()

func _apply_difficulty_scaling() -> void:
	var mult = get_wraith_speed_multiplier()
	var tree = _get_active_tree()
	if tree:
		var wraiths = tree.get_nodes_in_group("unseen_entity")
		for w in wraiths:
			if w is WraithAI:
				# Each hour, increase speed and reduce time between hunts
				w.hunt_speed = (6.2 + (current_hour * 0.4)) * mult
				w.stalk_speed = (3.2 + (current_hour * 0.25)) * mult
				if current_hour >= 3:
					w.uv_recoil_threshold = max(0.9, 1.6 - (current_hour * 0.15))
