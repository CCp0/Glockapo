extends Area2D
class_name EnemyBase

enum MovementPattern { STRAIGHT, SINE_DRIFT, DIVE }
enum SpawnLocation { AERIAL, GROUND }

const SINE_AMPLITUDE := 40.0
const SINE_FREQUENCY := 1.5
const OFFSCREEN_MARGIN := 100.0

# How close (horizontally) to the dive target before it's felt at full
# strength, and how far above the player the target point can land.
const DIVE_WINDOW := 200.0
const DIVE_ABOVE_MIN := 20.0
const DIVE_ABOVE_MAX := 80.0

# Rock drop chance per kill rises with wave.
const ROCK_DROP_BASE_CHANCE := 0.5
const ROCK_DROP_WAVE_INCREMENT := 0.05

const RockPickupScene := preload("res://scenes/rock_pickup.tscn")

@export var speed: float = 160.0
@export var health: int = 2
@export var contact_damage: int = 1
@export var movement_pattern: MovementPattern = MovementPattern.STRAIGHT
## GROUND enemies are kept at ground level by the spawner and always use
## the STRAIGHT pattern regardless of the above.
@export var spawn_location: SpawnLocation = SpawnLocation.AERIAL

var velocity: Vector2 = Vector2.ZERO

var _time_alive: float = 0.0
var _base_y: float = 0.0
var _dive_target: Vector2
var _dying: bool = false

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
	if _dying:
		return
	health -= amount
	if health <= 0:
		_dying = true
		# take_damage is called from the bullet's area_entered signal, which
		# fires mid physics-query-flush; adding/freeing physics nodes has to
		# wait until that's done.
		call_deferred("_die")


func _die() -> void:
	GameState.birds_downed_this_wave += 1
	var drop_chance: float = clampf(ROCK_DROP_BASE_CHANCE + ROCK_DROP_WAVE_INCREMENT * (GameState.wave - 1), 0.0, 1.0)
	if randf() < drop_chance:
		var rock: Node2D = RockPickupScene.instantiate()
		rock.global_position = global_position
		get_parent().add_child(rock)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_contact_damage"):
		body.take_contact_damage(contact_damage)
