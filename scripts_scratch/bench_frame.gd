extends SceneTree

var _frames: int = 0
var _fps_sum: float = 0.0
var _draw_sum: float = 0.0
var _process_sum: float = 0.0
var _samples: int = 0

func _init() -> void:
	change_scene_to_file("res://Scenes/Main.tscn")

func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 30:
		var root := get_root()
		var main := root.get_node_or_null("Main")
		var workshop := main.get_node_or_null("Workshop") if main else null
		var meshes := 0
		var batches := 0
		if workshop:
			meshes = workshop.find_children("*", "MeshInstance3D", true, false).size()
			batches = workshop.find_children("*", "MultiMeshInstance3D", true, false).size()
		print("BENCH_MESHES ", meshes)
		print("BENCH_BATCHES ", batches)
	if _frames >= 300 and _frames <= 420:
		_samples += 1
		_fps_sum += Engine.get_frames_per_second()
		_draw_sum += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		_process_sum += Performance.get_monitor(Performance.TIME_PROCESS)
	if _frames == 421 and _samples > 0:
		print("BENCH_FPS ", _fps_sum / _samples)
		print("BENCH_DRAWS ", _draw_sum / _samples)
		print("BENCH_PROCESS ", _process_sum / _samples)
		quit(0)
	return false
