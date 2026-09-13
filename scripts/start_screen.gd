extends Control

const ArenaScene := preload("res://scenes/arena.tscn")
const PULSE_SPEED := 3.0

@onready var start_prompt: Label = $StartPrompt

var _pulse_time: float = 0.0
var _starting: bool = false


func _ready() -> void:
	Music.play_title()


func _process(delta: float) -> void:
	_pulse_time += delta
	start_prompt.modulate.a = 0.5 + 0.5 * sin(_pulse_time * PULSE_SPEED)


func _input(event: InputEvent) -> void:
	if _starting:
		return

	var should_start: bool = (
		(event is InputEventMouseButton and event.pressed)
		or (event is InputEventScreenTouch and event.pressed)
		or (event is InputEventKey and event.pressed)
	)
	if should_start:
		_starting = true
		get_tree().change_scene_to_packed(ArenaScene)
