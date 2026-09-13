extends Node2D
class_name FlyTransition

signal finished

const DURATION := 1.2
const LINE_SPEED := 900.0
const LINE_COUNT := 6
const SCREEN_WIDTH := 720.0
const SCREEN_HEIGHT := 960.0

var _timer: float = 0.0
var _finished: bool = false

@onready var lines_container: Node2D = $Lines


func _ready() -> void:
	for i in LINE_COUNT:
		var line := Polygon2D.new()
		var w: float = randf_range(80.0, 220.0)
		var h: float = 6.0
		line.polygon = PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
		line.color = Color(0.7, 1.0, 0.6, 0.7)
		line.position = Vector2(randf_range(0.0, SCREEN_WIDTH), randf_range(80.0, SCREEN_HEIGHT - 80.0))
		lines_container.add_child(line)


func _process(delta: float) -> void:
	for line: Polygon2D in lines_container.get_children():
		line.position.x -= LINE_SPEED * delta
		if line.position.x < -240.0:
			line.position.x = SCREEN_WIDTH + 40.0

	_timer += delta
	if _timer >= DURATION and not _finished:
		_finished = true
		finished.emit()
