extends Control

const BASE_RADIUS := 60.0
const KNOB_RADIUS := 28.0
const MAX_KNOB_OFFSET := 50.0

var _touch_index: int = -1
var _knob_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	visible = OS.has_feature("mobile")


func _draw() -> void:
	draw_circle(Vector2.ZERO, BASE_RADIUS, Color(1, 1, 1, 0.25))
	draw_circle(_knob_offset, KNOB_RADIUS, Color(1, 1, 1, 0.5))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_knob_offset = Vector2.ZERO
			InputBridge.set_touch_move_vector(Vector2.ZERO)
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)


func _update_knob(local_position: Vector2) -> void:
	var offset: Vector2 = local_position - size / 2.0
	_knob_offset = offset.limit_length(MAX_KNOB_OFFSET)
	InputBridge.set_touch_move_vector(_knob_offset / MAX_KNOB_OFFSET)
	queue_redraw()
