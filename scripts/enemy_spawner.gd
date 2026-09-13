extends Node2D
class_name EnemySpawner

@export var spawn_interval: float = 2.0
@export var min_y: float = 150.0
@export var max_y: float = 650.0

@export var ground_spawn_interval: float = 7.0
const GROUND_Y := 695.0

# A ground invasion drops this many extra ground pigeons, spaced evenly
# across a ~10s window, on top of the normal ground spawn timer.
const INVASION_PIGEON_COUNT := 5
const INVASION_INTERVAL := 2.5

# Difficulty ramps with GameState.wave: spawns come faster and enemies move
# quicker each wave, both capped so it never gets unfairly extreme.
const INTERVAL_REDUCTION_PER_WAVE := 0.15
const MIN_SPAWN_INTERVAL := 0.7
const GROUND_INTERVAL_REDUCTION_PER_WAVE := 0.5
const MIN_GROUND_SPAWN_INTERVAL := 2.5
const SPEED_INCREASE_PER_WAVE := 0.1
const MAX_SPEED_MULTIPLIER := 2.0

# Dropped in immediately whenever the arena is reset for a new wave, so
# it doesn't sit empty until the timers naturally catch up.
const NEW_WAVE_BURST_COUNT := 3

var _time_since_spawn: float = 0.0
var _time_since_ground_spawn: float = 0.0

var _invasion_spawns_remaining: int = 0
var _time_since_invasion_spawn: float = 0.0


func _ready() -> void:
	GameState.ground_invasion_started.connect(_start_invasion)


func _process(delta: float) -> void:
	_time_since_spawn += delta
	if _time_since_spawn >= _effective_spawn_interval():
		_time_since_spawn = 0.0
		_spawn_enemy(GameState.current_biome.enemy_scene, randf_range(min_y, max_y))

	_time_since_ground_spawn += delta
	if _time_since_ground_spawn >= _effective_ground_spawn_interval():
		_time_since_ground_spawn = 0.0
		_spawn_enemy(GameState.current_biome.ground_enemy_scene, GROUND_Y)

	if _invasion_spawns_remaining > 0:
		_time_since_invasion_spawn += delta
		if _time_since_invasion_spawn >= INVASION_INTERVAL:
			_time_since_invasion_spawn = 0.0
			_spawn_enemy(GameState.current_biome.ground_enemy_scene, GROUND_Y)
			_invasion_spawns_remaining -= 1


## Called when the arena is repopulated after a flight (successful or
## not) — restarts the spawn timers fresh and drops in an immediate
## handful of enemies rather than leaving the arena empty until the
## regular timers next fire.
func reset_for_new_wave() -> void:
	_time_since_spawn = 0.0
	_time_since_ground_spawn = 0.0
	for i in NEW_WAVE_BURST_COUNT:
		_spawn_enemy(GameState.current_biome.enemy_scene, randf_range(min_y, max_y))


func _effective_spawn_interval() -> float:
	return maxf(spawn_interval - (GameState.wave - 1) * INTERVAL_REDUCTION_PER_WAVE, MIN_SPAWN_INTERVAL)


func _effective_ground_spawn_interval() -> float:
	return maxf(ground_spawn_interval - (GameState.wave - 1) * GROUND_INTERVAL_REDUCTION_PER_WAVE, MIN_GROUND_SPAWN_INTERVAL)


func _start_invasion() -> void:
	_invasion_spawns_remaining = INVASION_PIGEON_COUNT
	# Push straight past the interval so the first one lands almost
	# immediately — the invasion should announce itself, not creep in.
	_time_since_invasion_spawn = INVASION_INTERVAL


func _spawn_enemy(enemy_scene: PackedScene, spawn_y: float) -> void:
	if enemy_scene == null:
		return

	var enemy := enemy_scene.instantiate() as EnemyBase
	var from_left: bool = randf() < 0.5
	var viewport_width: float = get_viewport_rect().size.x

	var speed_multiplier: float = minf(1.0 + (GameState.wave - 1) * SPEED_INCREASE_PER_WAVE, MAX_SPEED_MULTIPLIER)
	enemy.speed *= speed_multiplier

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
