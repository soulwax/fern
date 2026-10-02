extends Node

signal hour_changed(current_hour: int, hour_name: String)
signal game_won()
signal game_lost()
signal ambient_bell_tolled()

@export var seconds_per_hour: float = 75.0
@export var current_hour: int = 0
@export var max_hours: int = 6

var elapsed_in_hour: float = 0.0
var is_game_active: bool = true

const HOUR_NAMES = [
	"00:00 (Die Geisterstunde)",
	"01:00 (Erste Nachtwache)",
	"02:00 (Das Raunen im Gebälk)",
	"03:00 (Die Totenstunde)",
	"04:00 (Kalter Morgennebel)",
	"05:00 (Der Dämmerung nahe)",
	"06:00 (Taganbruch & Frühglocke)"
]

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	current_hour = 0
	elapsed_in_hour = 0.0
	is_game_active = true
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

func trigger_victory() -> void:
	is_game_active = false
	game_won.emit()
	
	# Banish all unseen entities
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	for w in wraiths:
		if w.has_method("banish"):
			w.banish()

func trigger_defeat() -> void:
	if not is_game_active:
		return
	is_game_active = false
	game_lost.emit()

func _apply_difficulty_scaling() -> void:
	var wraiths = get_tree().get_nodes_in_group("unseen_entity")
	for w in wraiths:
		if w is WraithAI:
			# Each hour, increase speed and reduce time between hunts
			w.hunt_speed = 6.2 + (current_hour * 0.4)
			w.stalk_speed = 3.2 + (current_hour * 0.25)
			if current_hour >= 3:
				w.uv_recoil_threshold = max(0.9, 1.6 - (current_hour * 0.15))
