extends Node2D

signal fired(recoil_impulse: Vector2)

const MAG_SIZE := 8
const FIRE_COOLDOWN := 0.15
const RELOAD_TIME := 1.5
const RECOIL_STRENGTH := 200.0
const DOWN_SHOT_RECOIL_STRENGTH := 300.0
const DOWN_SHOT_AIM_Y := 0.7

const BulletScene := preload("res://scenes/bullet.tscn")

@onready var muzzle: Marker2D = $Muzzle

var rounds_in_mag := MAG_SIZE
var reloading := false

var _fire_cooldown_remaining := 0.0
var _reload_time_remaining := 0.0
var _mount_scale_magnitude: float


func _ready() -> void:
	_mount_scale_magnitude = absf(scale.x)


func _process(delta: float) -> void:
	var aim: Vector2 = InputBridge.aim_vector
	# The art faces left at rest. Rotating a further half-turn to face right
	# would render it upside down, so we mirror the mount instead
	if aim.x >= 0.0:
		scale.x = -_mount_scale_magnitude
		rotation = aim.angle()
	else:
		scale.x = _mount_scale_magnitude
		rotation = aim.angle() + PI

	_fire_cooldown_remaining = maxf(_fire_cooldown_remaining - delta, 0.0)

	if reloading:
		_reload_time_remaining -= delta
		if _reload_time_remaining <= 0.0:
			reloading = false
			rounds_in_mag = MAG_SIZE
	elif rounds_in_mag == 0 or InputBridge.reload_pressed:
		_start_reload()

	if not reloading and _fire_cooldown_remaining <= 0.0 and rounds_in_mag > 0 and InputBridge.fire_held:
		_fire()


func _start_reload() -> void:
	if rounds_in_mag < MAG_SIZE:
		reloading = true
		_reload_time_remaining = RELOAD_TIME


func _fire() -> void:
	rounds_in_mag -= 1
	_fire_cooldown_remaining = FIRE_COOLDOWN

	var aim_dir: Vector2 = InputBridge.aim_vector

	var bullet: Area2D = BulletScene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = aim_dir
	get_tree().current_scene.add_child(bullet)

	var recoil_strength := DOWN_SHOT_RECOIL_STRENGTH if aim_dir.y > DOWN_SHOT_AIM_Y else RECOIL_STRENGTH
	fired.emit(-aim_dir * recoil_strength)
