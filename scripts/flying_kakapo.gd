extends Area2D
class_name FlyingKakapo

## Emitted once when the nest height is reached — the camera stops
## following at that point (fly_ascent.gd), but this node keeps flying so
## the player can finish the last push up to the visual top of the screen.
signal reached_goal_height
## Emitted on any failed attempt (out of rocks, or sank too far) — always
## the same "drop back into the arena" outcome either way.
signal fell_to_arena

const GRAVITY := 240.0

# Guns are fixed at 45°, so every shot is inherently "diagonal" — firing
# both at once cancels their lateral halves and adds their vertical
# halves, giving pure-up movement (cost 2 rocks) for free; firing just one
# gives half that lift plus a lateral push (cost 1 rock), matching the
# original "shoot down = up, shoot down-and-to-a-side = diagonal" design
# without needing a separate straight-down case.
const DIAGONAL_UP_IMPULSE := 115.0
const DIAGONAL_LATERAL_IMPULSE := 150.0
const DIAGONAL_ROCK_COST := 1

const LEFT_GUN_DIRECTION := Vector2(-0.70710678, 0.70710678)
const RIGHT_GUN_DIRECTION := Vector2(0.70710678, 0.70710678)

const GOAL_HEIGHT := 2200.0
const FALL_LIMIT := 500.0

const SIDE_MARGIN := 40.0
const SCREEN_WIDTH := 720.0

var velocity: Vector2 = Vector2.ZERO
var _start_y: float = 0.0
var _goal_reached: bool = false
var _finished: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var left_glock: Weapon = $LeftGlockMount
@onready var right_glock: Weapon = $RightGlockMount


func _ready() -> void:
	InputBridge.player = self
	_start_y = position.y

	left_glock.bullets_collide = false
	left_glock.use_fixed_aim = true
	left_glock.fixed_aim_direction = LEFT_GUN_DIRECTION
	left_glock.fired.connect(_on_glock_fired)

	right_glock.bullets_collide = false
	right_glock.use_fixed_aim = true
	right_glock.fixed_aim_direction = RIGHT_GUN_DIRECTION
	right_glock.fired.connect(_on_glock_fired)


func _process(_delta: float) -> void:
	# A fires the left gun, D fires the right, W fires both.
	left_glock.external_fire_held = InputBridge.fly_fire_left or InputBridge.fly_fire_up
	right_glock.external_fire_held = InputBridge.fly_fire_right or InputBridge.fly_fire_up


func _physics_process(delta: float) -> void:
	if _finished:
		return

	if GameState.rocks <= 0:
		_finished = true
		fell_to_arena.emit()
		return

	velocity.y += GRAVITY * delta
	position += velocity * delta
	position.x = clampf(position.x, SIDE_MARGIN, SCREEN_WIDTH - SIDE_MARGIN)

	if not _goal_reached and position.y <= _start_y - GOAL_HEIGHT:
		_goal_reached = true
		reached_goal_height.emit()

	if position.y >= _start_y + FALL_LIMIT:
		_finished = true
		fell_to_arena.emit()


func _on_glock_fired(aim_dir: Vector2) -> void:
	if _finished or GameState.rocks < DIAGONAL_ROCK_COST:
		return
	GameState.spend_rocks(DIAGONAL_ROCK_COST)
	velocity.y -= DIAGONAL_UP_IMPULSE
	velocity.x -= signf(aim_dir.x) * DIAGONAL_LATERAL_IMPULSE


func take_contact_damage(amount: int) -> void:
	GameState.take_damage(amount)


## Called by fly_ascent.gd once the kakapo visually reaches the top of the
## (by then frozen) camera view.
func mark_reached_top() -> void:
	_finished = true
