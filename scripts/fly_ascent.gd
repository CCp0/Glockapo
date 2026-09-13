extends Node2D
class_name FlyAscent

signal reached_top
signal fell_to_arena

# Camera dead-zone: never let the kakapo appear above screen-center while
# rising (the camera scrolls to keep pace), but give it room to sink
# toward the bottom of the frame while falling before the camera follows
# — so the player can see it coming and react.
const CENTER_Y := 480.0
const BOTTOM_SLACK := 380.0

@onready var flying_kakapo: FlyingKakapo = $FlyingKakapo
@onready var camera: Camera2D = $Camera2D

var _goal_reached: bool = false


func _ready() -> void:
	camera.position.y = flying_kakapo.position.y
	camera.make_current()
	flying_kakapo.reached_goal_height.connect(_on_goal_height_reached)
	flying_kakapo.fell_to_arena.connect(func() -> void: fell_to_arena.emit())


func _process(_delta: float) -> void:
	if _goal_reached:
		# Camera's frozen — once the kakapo's own climb carries it to the
		# top of that fixed view, the sequence is done.
		if flying_kakapo.position.y - camera.position.y <= -CENTER_Y:
			flying_kakapo.mark_reached_top()
			reached_top.emit()
		return

	var offset: float = flying_kakapo.position.y - camera.position.y
	if offset < 0.0:
		camera.position.y = flying_kakapo.position.y
	elif offset > BOTTOM_SLACK:
		camera.position.y = flying_kakapo.position.y - BOTTOM_SLACK


func _on_goal_height_reached() -> void:
	_goal_reached = true
