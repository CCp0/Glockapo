extends CharacterBody2D

const SPEED := 220.0
const ACCELERATION := 1760.0
const GRAVITY := 1400.0

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


func _on_glock_fired(recoil_impulse: Vector2) -> void:
	velocity += recoil_impulse


func take_contact_damage(amount: int) -> void:
	GameState.take_damage(amount)


func collect_rock() -> void:
	GameState.add_rock()
