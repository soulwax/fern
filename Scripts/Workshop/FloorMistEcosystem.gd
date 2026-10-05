class_name FloorMistEcosystem
extends Node3D

## Valley Night Mist Ingress (Der Talnebel)
## Simulates cold low-lying mountain fog creeping through floor gaps and window breaches.
## When the invisible wraith stalks across the workshop floorboards, its movement
## displaces the mist, generating visible swirling vapor wakes that expose its path.

@onready var ambient_mist: GPUParticles3D = $AmbientMist
@onready var displaced_wake: GPUParticles3D = $DisplacedWake

var wraith_node: CharacterBody3D = null

func _ensure_nodes() -> void:
	if not ambient_mist:
		ambient_mist = get_node_or_null("AmbientMist")
	if not displaced_wake:
		displaced_wake = get_node_or_null("DisplacedWake")

func _ready() -> void:
	_ensure_nodes()
	if ambient_mist:
		ambient_mist.emitting = true
	if displaced_wake:
		displaced_wake.emitting = false

func _process(_delta: float) -> void:
	_ensure_nodes()
	_update_window_draft_density()
	_update_wraith_wake()

func _update_window_draft_density() -> void:
	_ensure_nodes()
	if not ambient_mist:
		return
	var windows := _window_breaches()
	var open_breaches: int = 0
	for w in windows:
		if "current_planks" in w and w.current_planks <= 0:
			open_breaches += 1

	# Base density 0.5, scales up to 1.0 with open breaches
	var target_ratio: float = clampf(0.5 + (open_breaches * 0.18), 0.5, 1.0)
	ambient_mist.amount_ratio = target_ratio

func _update_wraith_wake() -> void:
	_ensure_nodes()
	if not displaced_wake:
		return

	if not wraith_node or not is_instance_valid(wraith_node):
		wraith_node = _primary_wraith() as CharacterBody3D
		if not wraith_node:
			displaced_wake.emitting = false
			return

	var wraith_pos = wraith_node.global_position if wraith_node.is_inside_tree() else wraith_node.position
	var is_on_floor: bool = wraith_pos.y < 2.5
	var is_moving: bool = wraith_node.velocity.length() > 0.4

	if is_on_floor and is_moving:
		if displaced_wake.is_inside_tree():
			displaced_wake.global_position = Vector3(wraith_pos.x, 0.08, wraith_pos.z)
		else:
			displaced_wake.position = Vector3(wraith_pos.x, 0.08, wraith_pos.z)
		displaced_wake.emitting = true
	else:
		displaced_wake.emitting = false

func _window_breaches() -> Array:
	var game_state := get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("get_window_breaches"):
		return game_state.get_window_breaches()
	return get_tree().get_nodes_in_group("window_breach") if is_inside_tree() else []

func _primary_wraith() -> Node:
	var game_state := get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("get_primary_wraith"):
		return game_state.get_primary_wraith()
	if is_inside_tree():
		return get_tree().root.find_child("InvisibleWraith", true, false)
	return null
