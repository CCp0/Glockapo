extends Node

signal hp_changed(new_value: int)
signal died

const MAX_HP := 5

var current_biome: BiomeConfig = preload("res://resources/biomes/forest.tres")
var hp: int = MAX_HP
var birds_downed_this_wave: int = 0

var _dead: bool = false


func take_damage(amount: int) -> void:
	if _dead:
		return
	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp)
	if hp == 0:
		_dead = true
		died.emit()


func reset() -> void:
	hp = MAX_HP
	birds_downed_this_wave = 0
	_dead = false
	hp_changed.emit(hp)
