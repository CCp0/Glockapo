extends Node

var move_vector: Vector2 = Vector2.ZERO

var _touch_move_vector: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	var keyboard_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Keyboard wins when active so desktop testing isn't fighting a leftover touch value.
	move_vector = keyboard_vector if keyboard_vector != Vector2.ZERO else _touch_move_vector


func set_touch_move_vector(vector: Vector2) -> void:
	_touch_move_vector = vector
