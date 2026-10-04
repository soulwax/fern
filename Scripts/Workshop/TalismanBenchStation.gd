class_name TalismanBenchStation
extends Interactable

## Woodcarver's Talisman Bench (Das Schnitzmesser & Ebereschen-Amulett)
## Traditional carpenter's gouging bench with rowan wood branches and red cord.
## In Black Forest folklore, mountain ash / rowan wood (Eberesche) was carved
## into amulets to guard against sleep paralysis and forest wraiths.
## Equipping the amulet wards fear (reduces anxiety trigger radius by 25%)
## and grants woodcarver stamina (+12% sprint speed and reduced fatigue).

signal talisman_crafted()

@onready var knife_mesh: MeshInstance3D = $KnifeMesh
@onready var branch_mesh: MeshInstance3D = $BranchMesh
@onready var amulet_mesh: MeshInstance3D = $AmuletMesh
@onready var carve_audio: AudioStreamPlayer3D = $CarveAudio

var is_crafted: bool = false

func _ensure_nodes() -> void:
	if not knife_mesh:
		knife_mesh = get_node_or_null("KnifeMesh")
	if not branch_mesh:
		branch_mesh = get_node_or_null("BranchMesh")
	if not amulet_mesh:
		amulet_mesh = get_node_or_null("AmuletMesh")
	if not carve_audio:
		carve_audio = get_node_or_null("CarveAudio")

func _ready() -> void:
	super._ready()
	_ensure_nodes()
	add_to_group("talisman_bench_station")
	_update_visuals()

func _process(_delta: float) -> void:
	_ensure_nodes()
	if is_crafted:
		prompt_message = "Rowan Amulet Equipped (Spirit & Fear Warded)"
		is_enabled = false
		return
		
	prompt_message = "[E] Carve Rowan Wood Amulet (Ebereschen-Amulett)"
	is_enabled = true

func _on_interacted(_player: Node) -> void:
	if not is_crafted:
		craft_talisman()

func craft_talisman() -> void:
	_ensure_nodes()
	is_crafted = true
	
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		game_state.has_rowan_talisman = true
		
	if carve_audio:
		carve_audio.pitch_scale = randf_range(0.98, 1.02)
		carve_audio.play()
		
	talisman_crafted.emit()
	_update_visuals()

func _update_visuals() -> void:
	if amulet_mesh:
		amulet_mesh.visible = is_crafted
	if branch_mesh:
		branch_mesh.visible = not is_crafted
