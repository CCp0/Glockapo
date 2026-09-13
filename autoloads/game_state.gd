extends Node

signal hp_changed(new_value: int)
signal died
signal rocks_changed(new_value: int)
signal ground_invasion_started

const MAX_HP := 5
const ROCKS_TO_UNLOCK_FLY := 20
# Chance each wave after the first nest of a ground-pigeon invasion.
const GROUND_INVASION_CHANCE := 0.4

var current_biome: BiomeConfig = preload("res://resources/biomes/forest.tres")
var hp: int = MAX_HP
var wave: int = 1
var rocks: int = 20
var birds_downed_this_wave: int = 0
var total_birds_downed_this_run: int = 0
var nests_destroyed_this_run: int = 0

var _dead: bool = false


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp)
	if hp == 0:
		_dead = true
		died.emit()


func add_rock() -> void:
	rocks += 1
	rocks_changed.emit(rocks)


func spend_rocks(amount: int) -> void:
	rocks = maxi(rocks - amount, 0)
	rocks_changed.emit(rocks)


func start_new_wave() -> void:
	wave += 1
	nests_destroyed_this_run += 1
	birds_downed_this_wave = 0

	# wave is at least 2 here, i.e. this can't trigger until after the
	# first nest is destroyed.
	if randf() < GROUND_INVASION_CHANCE:
		ground_invasion_started.emit()


func reset() -> void:
	hp = MAX_HP
	wave = 1
	rocks = 0
	birds_downed_this_wave = 0
	total_birds_downed_this_run = 0
	nests_destroyed_this_run = 0
	_dead = false
	hp_changed.emit(hp)
	rocks_changed.emit(rocks)
