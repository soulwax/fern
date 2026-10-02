extends "res://Scripts/Workshop/Interactable.gd"

signal climb_started(player: Node, climbing_up: bool)
signal climb_finished(player: Node, climbing_up: bool)

@export var climb_duration: float = 1.2

@onready var bottom_mount: Marker3D = $BottomMount
@onready var top_mount: Marker3D = $TopMount
@onready var audio_creak: AudioStreamPlayer3D = $AudioCreak

var _is_busy: bool = false

func _ready() -> void:
	super._ready()
	prompt_message = "[E] Climb Rafters"

func get_interaction_prompt() -> String:
	if not is_inside_tree():
		return prompt_message
	var tree = get_tree()
	if tree and is_instance_valid(top_mount) and is_instance_valid(bottom_mount):
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			var p = players[0]
			var d_bottom = p.global_position.distance_to(bottom_mount.global_position)
			var d_top = p.global_position.distance_to(top_mount.global_position)
			if d_top < d_bottom:
				return "[E] Climb Down from Rafters"
	return prompt_message

func _on_interacted(player: Node) -> void:
	if _is_busy or not (player is CharacterBody3D):
		return
	if not top_mount or not bottom_mount:
		return
	
	var d_bottom = player.global_position.distance_to(bottom_mount.global_position)
	var d_top = player.global_position.distance_to(top_mount.global_position)
	var climbing_up = d_bottom <= d_top
	
	var end_pos = top_mount.global_position if climbing_up else bottom_mount.global_position
	
	_perform_climb(player as CharacterBody3D, end_pos, climbing_up)

func _perform_climb(player: CharacterBody3D, end_pos: Vector3, climbing_up: bool) -> void:
	_is_busy = true
	is_enabled = false
	if player.has_method("set_movement_frozen"):
		player.set_movement_frozen(true)
	
	if audio_creak:
		audio_creak.play()
	
	climb_started.emit(player, climbing_up)
	
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "global_position", end_pos, climb_duration)
	tween.finished.connect(func():
		if is_instance_valid(player) and player.has_method("set_movement_frozen"):
			player.set_movement_frozen(false)
		_is_busy = false
		is_enabled = true
		climb_finished.emit(player, climbing_up)
	)
