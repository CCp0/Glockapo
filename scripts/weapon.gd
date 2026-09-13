extends Node2D
class_name Weapon

signal fired(aim_direction: Vector2)
signal ammo_changed(rounds_in_mag: int, mag_size: int)

const MAG_SIZE := 8
const FIRE_COOLDOWN := 0.10
const RELOAD_TIME := 1

const BulletScene := preload("res://scenes/bullet.tscn")
const RockTexture := preload("res://assets/player_resources/Rock.png")
const ROCK_VISUAL_SCALE := Vector2(0.5, 0.5)

## When false, fired bullets don't collide with anything — used in flight
## mode, where the guns are propulsion-only and never deal damage.
@export var bullets_collide: bool = true

## Flight mode fixes the guns at a set angle triggered by a specific key
## rather than free mouse/stick aiming — set both below to enable that.
@export var use_fixed_aim: bool = false
@export var fixed_aim_direction: Vector2 = Vector2.DOWN

## Only read when use_fixed_aim is true; the owner sets this directly
## instead of the gun reading InputBridge.fire_held itself.
var external_fire_held: bool = false

@onready var muzzle: Marker2D = $Muzzle
@onready var muzzle_audio: AudioStreamPlayer2D = $MuzzleAudio

var rounds_in_mag := MAG_SIZE
var reloading := false

var _fire_cooldown_remaining := 0.0
var _reload_time_remaining := 0.0
var _mount_scale_magnitude: float


func _ready() -> void:
	_mount_scale_magnitude = absf(scale.x)
	ammo_changed.emit(rounds_in_mag, MAG_SIZE)


func _process(delta: float) -> void:
	var aim: Vector2 = fixed_aim_direction if use_fixed_aim else InputBridge.aim_vector
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
			ammo_changed.emit(rounds_in_mag, MAG_SIZE)
	elif rounds_in_mag == 0 or InputBridge.reload_pressed:
		_start_reload()

	var firing_requested: bool = external_fire_held if use_fixed_aim else InputBridge.fire_held
	if not reloading and _fire_cooldown_remaining <= 0.0 and rounds_in_mag > 0 and firing_requested:
		_fire()


func _start_reload() -> void:
	if rounds_in_mag < MAG_SIZE:
		reloading = true
		_reload_time_remaining = RELOAD_TIME


func _fire() -> void:
	rounds_in_mag -= 1
	_fire_cooldown_remaining = FIRE_COOLDOWN
	ammo_changed.emit(rounds_in_mag, MAG_SIZE)

	# Slight pitch variation so rapid fire doesn't sound like the exact
	# same clip stuttering.
	muzzle_audio.pitch_scale = randf_range(0.92, 1.08)
	muzzle_audio.play()

	var aim_dir: Vector2 = fixed_aim_direction if use_fixed_aim else InputBridge.aim_vector

	var bullet: Area2D = BulletScene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.direction = aim_dir
	bullet.monitoring = bullets_collide
	if not bullets_collide:
		# Flight mode fires rocks (the fuel being spent) instead of bullets.
		var bullet_sprite: Sprite2D = bullet.get_node("Sprite2D")
		bullet_sprite.texture = RockTexture
		bullet_sprite.scale = ROCK_VISUAL_SCALE
	get_tree().current_scene.add_child(bullet)

	fired.emit(aim_dir)
