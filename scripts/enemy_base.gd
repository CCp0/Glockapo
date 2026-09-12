extends Area2D
class_name EnemyBase

enum MovementPattern { STRAIGHT, SINE_DRIFT, DIVE }

const SINE_AMPLITUDE := 40.0
const SINE_FREQUENCY := 1.5
const OFFSCREEN_MARGIN := 100.0

# How close (horizontally) to the dive target before it's felt at full
# strength, and how far above the player the target point can land.
const DIVE_WINDOW := 200.0
const DIVE_ABOVE_MIN := 20.0
const DIVE_ABOVE_MAX := 80.0

@export var speed: float = 160.0
@export var health: int = 2
@export var contact_damage: int = 1
@export var movement_pattern: MovementPattern = MovementPattern.STRAIGHT

var velocity: Vector2 = Vector2.ZERO

var _time_alive: float = 0.0
var _base_y: float = 0.0
var _dive_target: Vector2

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)
	# Art faces left at rest; mirror it to face whichever way it's flying.
	_sprite.flip_h = velocity.x > 0.0

	# Captured once at spawn (not continuously tracked), so the dive swoops toward roughly where the player was rather than homing in on them.
	if InputBridge.player:
		var player_pos: Vector2 = InputBridge.player.global_position
		_dive_target = Vector2(player_pos.x, player_pos.y - randf_range(DIVE_ABOVE_MIN, DIVE_ABOVE_MAX))
	else:
		_dive_target = position


func _physics_process(delta: float) -> void:
	_time_alive += delta
	position.x += velocity.x * delta

	match movement_pattern:
		MovementPattern.SINE_DRIFT:
			position.y = _base_y + sin(_time_alive * SINE_FREQUENCY) * SINE_AMPLITUDE
		MovementPattern.DIVE:
			var closeness: float = clampf(1.0 - absf(position.x - _dive_target.x) / DIVE_WINDOW, 0.0, 1.0)
			var eased: float = closeness * closeness * (3.0 - 2.0 * closeness)
			position.y = lerpf(_base_y, _dive_target.y, eased)
		_:
			position.y += velocity.y * delta

	if position.x < -OFFSCREEN_MARGIN or position.x > get_viewport_rect().size.x + OFFSCREEN_MARGIN:
		queue_free()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_die()


func _die() -> void:
	GameState.birds_downed_this_wave += 1
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_contact_damage"):
		body.take_contact_damage(contact_damage)
