extends Node2D
class_name NestCutscene

signal finished

const DURATION := 1.5
const SHAKE_MAGNITUDE := 6.0
const SHAKE_SPEED := 30.0

var _timer: float = 0.0
var _finished: bool = false
var _kakapo_base_position: Vector2

@onready var kakapo_sprite: Sprite2D = $KakapoSprite
@onready var nest: Node2D = $Nest


func _ready() -> void:
	_kakapo_base_position = kakapo_sprite.position


func _process(delta: float) -> void:
	_timer += delta
	kakapo_sprite.position = _kakapo_base_position + Vector2(sin(_timer * SHAKE_SPEED) * SHAKE_MAGNITUDE, 0.0)
	nest.scale = Vector2.ONE * clampf(1.0 - _timer / DURATION, 0.0, 1.0)

	if _timer >= DURATION and not _finished:
		_finished = true
		finished.emit()
