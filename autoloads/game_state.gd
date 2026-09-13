extends Node

signal hp_changed(new_value: int)
signal died
signal rocks_changed(new_value: int)

const MAX_HP := 5
const ROCKS_TO_UNLOCK_FLY := 20

var current_biome: BiomeConfig = preload("res://resources/biomes/forest.tres")
var hp: int = MAX_HP
var wave: int = 1
var rocks: int = 25
var birds_downed_this_wave: int = 0
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


## Called when a nest is destroyed: rocks reset (so the Fly button hides
## again until the next 20), the wave ramps up, birds-this-wave resets.
func start_new_wave() -> void:
	wave += 1
	nests_destroyed_this_run += 1
	rocks = 0
	birds_downed_this_wave = 0
	rocks_changed.emit(rocks)


func reset() -> void:
	hp = MAX_HP
	wave = 1
	rocks = 0
	birds_downed_this_wave = 0
	nests_destroyed_this_run = 0
	_dead = false
	hp_changed.emit(hp)
	rocks_changed.emit(rocks)
