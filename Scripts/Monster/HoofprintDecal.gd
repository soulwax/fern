extends Decal

@export var lifetime: float = 12.0
@export var fade_duration: float = 3.0

var elapsed: float = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= (lifetime - fade_duration):
		var remaining = lifetime - elapsed
		var alpha = clamp(remaining / fade_duration, 0.0, 1.0)
		modulate.a = alpha
		
	if elapsed >= lifetime:
		queue_free()
