extends Node2D

@export var spawn_interval: float = 2.0
@export var min_y: float = 150.0
@export var max_y: float = 650.0

var _time_since_spawn: float = 0.0


func _process(delta: float) -> void:
	_time_since_spawn += delta
	if _time_since_spawn >= spawn_interval:
		_time_since_spawn = 0.0
		_spawn_enemy()


func _spawn_enemy() -> void:
	var enemy_scene: PackedScene = GameState.current_biome.enemy_scene
	if enemy_scene == null:
		return

	var enemy := enemy_scene.instantiate() as EnemyBase
	var from_left: bool = randf() < 0.5
	var viewport_width: float = get_viewport_rect().size.x

	enemy.position = Vector2(-80.0 if from_left else viewport_width + 80.0, randf_range(min_y, max_y))
	var direction: float = 1.0 if from_left else -1.0
	enemy.velocity = Vector2(direction * enemy.speed, 0.0)
	enemy.movement_pattern = EnemyBase.MovementPattern.SINE_DRIFT if randf() < 0.5 else EnemyBase.MovementPattern.STRAIGHT

	get_parent().add_child(enemy)
