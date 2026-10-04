class_name LinseedLampStation
extends Interactable

## Consecrated Linseed Oil Sanctuary Lamp (Die Leinöl-Kuppellampe)
## Suspended brass and mica dome lamp fueled by cold-pressed flaxseed oil.
## Adjusting the wick wheel ([E], wick_turn.wav) burns clean, radiant amber light
## for 30.0 seconds in a 5.0m circular radius.
## Inside the sanctuary cone, player stamina recovers 2x faster, and Der Alp
## is barred from executing direct lethal leap attacks.

signal lamp_ignited(duration: float)
signal lamp_expired()

@export var max_uses: int = 3
@export var current_uses: int = 3
@export var burn_duration: float = 30.0
@export var sanctuary_radius: float = 5.0
@export var active_light_energy: float = 3.2
@export var dormant_light_energy: float = 0.4

@onready var lamp_mesh: MeshInstance3D = $LampMesh
@onready var mica_mesh: MeshInstance3D = $MicaMesh
@onready var chain_mesh: MeshInstance3D = $ChainMesh
@onready var lamp_light: OmniLight3D = $LampLight
@onready var wick_audio: AudioStreamPlayer3D = $WickAudio

var is_burning: bool = false
var burn_timer: float = 0.0
var player_ref: Node3D = null
var wraith_ref: Node3D = null

func _ensure_nodes() -> void:
	if not lamp_mesh:
		lamp_mesh = get_node_or_null("LampMesh")
	if not mica_mesh:
		mica_mesh = get_node_or_null("MicaMesh")
	if not chain_mesh:
		chain_mesh = get_node_or_null("ChainMesh")
	if not lamp_light:
		lamp_light = get_node_or_null("LampLight")
	if not wick_audio:
		wick_audio = get_node_or_null("WickAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	_update_prompt()
	_set_light(dormant_light_energy)

func _update_prompt() -> void:
	if is_burning:
		prompt_message = "Sanctuary Lamp Burning (%ds)" % int(ceil(burn_timer))
		is_enabled = false
	elif current_uses > 0:
		prompt_message = "[E] Trim & Light Linseed Lamp (%d uses left)" % current_uses
		is_enabled = true
	else:
		prompt_message = "Linseed Oil Depleted"
		is_enabled = false

func _find_actors() -> void:
	if not is_inside_tree():
		return
	if not player_ref:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0]
	if not wraith_ref:
		var wraiths = get_tree().get_nodes_in_group("unseen_entity")
		if wraiths.size() > 0:
			wraith_ref = wraiths[0]

func _process(delta: float) -> void:
	_ensure_nodes()
	if not is_burning:
		return

	burn_timer -= delta
	if burn_timer <= 0.0:
		is_burning = false
		burn_timer = 0.0
		_set_light(dormant_light_energy)
		_update_prompt()
		lamp_expired.emit()
		return

	# Maintain sanctuary aura
	_find_actors()
	var my_pos = global_position if is_inside_tree() else position

	# Boost player stamina inside circle
	if player_ref and is_instance_valid(player_ref):
		var p_pos = player_ref.global_position if player_ref.is_inside_tree() else player_ref.position
		var dist_p = (my_pos - p_pos).length()
		if dist_p <= sanctuary_radius:
			if "stamina" in player_ref and "max_stamina" in player_ref:
				var max_s = player_ref.get("max_stamina")
				var cur_s = player_ref.get("stamina")
				if cur_s < max_s:
					player_ref.set("stamina", min(max_s, cur_s + delta * 25.0))

	# Ward wraith from attacking inside sanctuary
	if wraith_ref and is_instance_valid(wraith_ref):
		var w_pos = wraith_ref.global_position if wraith_ref.is_inside_tree() else wraith_ref.position
		var dist_w = (my_pos - w_pos).length()
		if dist_w <= sanctuary_radius:
			if wraith_ref.get("current_state") == wraith_ref.State.HUNT:
				# Deter wraith back to stalk/prowl
				wraith_ref.set_state(wraith_ref.State.STALK)

func _set_light(energy: float) -> void:
	if lamp_light:
		lamp_light.light_energy = energy

func _on_interacted(player: Node) -> void:
	ignite_lamp(player)

func ignite_lamp(_player: Node = null) -> bool:
	if is_burning or current_uses <= 0:
		return false

	_ensure_nodes()
	current_uses -= 1
	is_burning = true
	burn_timer = burn_duration

	if wick_audio and is_inside_tree():
		wick_audio.play()

	_set_light(active_light_energy)
	_update_prompt()
	lamp_ignited.emit(burn_duration)
	return true
