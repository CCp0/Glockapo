extends CharacterBody2D

const SPEED := 300.0
const ACCELERATION := 1760.0
const GRAVITY := 1400.0
const RECOIL_STRENGTH := 210.0
const DOWN_SHOT_RECOIL_STRENGTH := 300.0
const DOWN_SHOT_AIM_Y := 0.7

@onready var sprite: Sprite2D = $Sprite2D
@onready var glock_mount: Weapon = $GlockMount


func _ready() -> void:
	InputBridge.player = self
	glock_mount.fired.connect(_on_glock_fired)


func _physics_process(delta: float) -> void:
	# Only clear residual downward velocity, so an upward recoil impulse from
	# a down-shot isn't wiped out by this before it can launch the kakapo.
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
	velocity.y += GRAVITY * delta
	velocity.x = move_toward(velocity.x, InputBridge.move_vector.x * SPEED, ACCELERATION * delta)

	move_and_slide()

	if InputBridge.move_vector.x != 0.0:
		sprite.flip_h = InputBridge.move_vector.x < 0.0


func _on_glock_fired(aim_dir: Vector2) -> void:
	var strength: float = DOWN_SHOT_RECOIL_STRENGTH if aim_dir.y > DOWN_SHOT_AIM_Y else RECOIL_STRENGTH
	velocity += -aim_dir * strength


func take_contact_damage(amount: int) -> void:
	GameState.take_damage(amount)


func collect_rock() -> void:
	GameState.add_rock()
