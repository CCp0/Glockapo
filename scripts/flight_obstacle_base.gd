extends Area2D
class_name FlightObstacleBase

enum MovementPattern { STRAIGHT_FALL, DIVE_AT_PLAYER }

const MAX_DISTANCE_FROM_PLAYER := 700.0
# How much vertical fall the whole swoop curve plays out over.
const ARC_DISTANCE := 420.0

@export var fall_speed: float = 220.0
@export var contact_damage: int = 1
@export var movement_pattern: MovementPattern = MovementPattern.STRAIGHT_FALL

var _spawn_y: float = 0.0
var _base_x: float = 0.0
var _dive_target_x: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_spawn_y = position.y
	_base_x = position.x
	_dive_target_x = InputBridge.player.global_position.x if InputBridge.player else position.x


func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta

	if movement_pattern == MovementPattern.DIVE_AT_PLAYER:
		# A fixed arc from the spawn point toward wherever the player was
		# at spawn, playing out over a set fall distance — not re-tracked
		# against the player's current (constantly moving, in flight)
		# position, which was producing jittery, erratic curving.
		var progress: float = clampf((position.y - _spawn_y) / ARC_DISTANCE, 0.0, 1.0)
		var eased: float = progress * progress * (3.0 - 2.0 * progress)
		position.x = lerpf(_base_x, _dive_target_x, eased)

	# Camera scrolls now, so "off screen" is relative to the player rather
	# than a fixed world height.
	if InputBridge.player and position.y - InputBridge.player.global_position.y > MAX_DISTANCE_FROM_PLAYER:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_contact_damage"):
		area.take_contact_damage(contact_damage)
		queue_free()
