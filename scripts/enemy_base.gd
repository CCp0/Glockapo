extends Area2D
class_name EnemyBase

enum MovementPattern { STRAIGHT, SINE_DRIFT }

const SINE_AMPLITUDE := 40.0
const SINE_FREQUENCY := 1.5
const OFFSCREEN_MARGIN := 100.0

@export var speed: float = 140.0
@export var health: int = 2
@export var contact_damage: int = 1
@export var movement_pattern: MovementPattern = MovementPattern.STRAIGHT

var velocity: Vector2 = Vector2.ZERO

var _time_alive: float = 0.0
var _base_y: float = 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)
	# Art faces left at rest; mirror it to face whichever way it's flying.
	_sprite.flip_h = velocity.x > 0.0


func _physics_process(delta: float) -> void:
	_time_alive += delta
	position.x += velocity.x * delta

	if movement_pattern == MovementPattern.SINE_DRIFT:
		position.y = _base_y + sin(_time_alive * SINE_FREQUENCY) * SINE_AMPLITUDE
	else:
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
