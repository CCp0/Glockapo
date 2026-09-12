extends CharacterBody2D

const SPEED := 220.0
const GRAVITY := 1400.0

@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	velocity.x = InputBridge.move_vector.x * SPEED
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.0
