extends Area2D

const SPEED := 900.0
const LIFETIME := 1.5

var direction: Vector2 = Vector2.RIGHT

var _time_alive := 0.0


func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

	_time_alive += delta
	if _time_alive >= LIFETIME:
		queue_free()
