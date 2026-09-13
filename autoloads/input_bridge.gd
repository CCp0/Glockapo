extends Node

var move_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var fire_held: bool = false
var reload_pressed: bool = false

# Flight-mode gun triggers (fixed-angle guns fired by key rather than
# free-aimed) — reuse the move_left/move_right/move_up bindings (A/D/W)
# rather than adding new input actions.
var fly_fire_left: bool = false
var fly_fire_right: bool = false
var fly_fire_up: bool = false

var player: Node2D = null

var _touch_move_vector: Vector2 = Vector2.ZERO
var _touch_aim_vector: Vector2 = Vector2.ZERO
var _touch_fire_held: bool = false
var _touch_fly_fire_left: bool = false
var _touch_fly_fire_right: bool = false
var _touch_fly_fire_up: bool = false


func _ready() -> void:
	# Input tracking must never freeze — the flight sequence pauses the
	# rest of the tree but still needs live move/aim/fire state.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	var keyboard_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Keyboard wins when active so desktop testing isn't fighting a leftover touch value.
	move_vector = keyboard_vector if keyboard_vector != Vector2.ZERO else _touch_move_vector

	if _touch_aim_vector != Vector2.ZERO:
		aim_vector = _touch_aim_vector
	elif player:
		aim_vector = (player.get_global_mouse_position() - player.global_position).normalized()

	fire_held = Input.is_action_pressed("fire") or _touch_fire_held
	reload_pressed = Input.is_action_just_pressed("reload")

	fly_fire_left = Input.is_action_pressed("move_left") or _touch_fly_fire_left
	fly_fire_right = Input.is_action_pressed("move_right") or _touch_fly_fire_right
	fly_fire_up = Input.is_action_pressed("move_up") or _touch_fly_fire_up


func set_touch_move_vector(vector: Vector2) -> void:
	_touch_move_vector = vector


func set_touch_aim_vector(vector: Vector2) -> void:
	_touch_aim_vector = vector


func set_touch_fire_held(value: bool) -> void:
	_touch_fire_held = value


func set_touch_fly_fire_left(value: bool) -> void:
	_touch_fly_fire_left = value


func set_touch_fly_fire_right(value: bool) -> void:
	_touch_fly_fire_right = value


func set_touch_fly_fire_up(value: bool) -> void:
	_touch_fly_fire_up = value
