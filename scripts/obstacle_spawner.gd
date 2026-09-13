extends Node2D

@export var spawn_interval: float = 1.2

const SCREEN_WIDTH := 720.0
const SPAWN_ABOVE_PLAYER := 550.0
const SIDE_MARGIN := 60.0

var _time_since_spawn: float = 0.0


func _process(delta: float) -> void:
	_time_since_spawn += delta
	if _time_since_spawn >= spawn_interval:
		_time_since_spawn = 0.0
		_spawn_obstacle()


func _spawn_obstacle() -> void:
	if not is_instance_valid(InputBridge.player):
		return

	var scenes: Array[PackedScene] = GameState.current_biome.flight_obstacle_scenes
	if scenes.is_empty():
		return

	var scene: PackedScene = scenes[randi() % scenes.size()]
	var obstacle: Node2D = scene.instantiate()
	var spawn_y: float = InputBridge.player.global_position.y - SPAWN_ABOVE_PLAYER
	obstacle.position = Vector2(randf_range(SIDE_MARGIN, SCREEN_WIDTH - SIDE_MARGIN), spawn_y)
	add_child(obstacle)
