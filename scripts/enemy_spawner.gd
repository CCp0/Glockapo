extends Node2D

@export var spawn_interval: float = 2.0
@export var min_y: float = 150.0
@export var max_y: float = 650.0

@export var ground_spawn_interval: float = 7.0
const GROUND_Y := 695.0

var _time_since_spawn: float = 0.0
var _time_since_ground_spawn: float = 0.0


func _process(delta: float) -> void:
	_time_since_spawn += delta
	if _time_since_spawn >= spawn_interval:
		_time_since_spawn = 0.0
		_spawn_enemy(GameState.current_biome.enemy_scene, randf_range(min_y, max_y))

	_time_since_ground_spawn += delta
	if _time_since_ground_spawn >= ground_spawn_interval:
		_time_since_ground_spawn = 0.0
		_spawn_enemy(GameState.current_biome.ground_enemy_scene, GROUND_Y)


func _spawn_enemy(enemy_scene: PackedScene, spawn_y: float) -> void:
	if enemy_scene == null:
		return

	var enemy := enemy_scene.instantiate() as EnemyBase
	var from_left: bool = randf() < 0.5
	var viewport_width: float = get_viewport_rect().size.x

	enemy.position = Vector2(-80.0 if from_left else viewport_width + 80.0, spawn_y)
	var direction: float = 1.0 if from_left else -1.0
	enemy.velocity = Vector2(direction * enemy.speed, 0.0)
	var is_ground: bool = enemy.spawn_location == EnemyBase.SpawnLocation.GROUND
	enemy.movement_pattern = EnemyBase.MovementPattern.STRAIGHT if is_ground else _random_movement_pattern()

	get_parent().add_child(enemy)


func _random_movement_pattern() -> EnemyBase.MovementPattern:
	# Weighted toward diving so pigeons read as a real threat, not just
	# scenery drifting past.
	var roll: float = randf()
	if roll < 0.75:
		return EnemyBase.MovementPattern.DIVE
	elif roll < 0.90:
		return EnemyBase.MovementPattern.SINE_DRIFT
	else:
		return EnemyBase.MovementPattern.STRAIGHT
