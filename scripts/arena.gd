extends Node2D

## The ground arena — first end-to-end draft is the forest biome
## (docs/TECH_PLAN.md §17 step 1). Ground/sky colors and platform scenes
## are read from `biome` rather than hardcoded, so swapping in a sea or
## city biome later is a resource + level-layout change, not a rewrite.
## Kakapo, gun, enemies, and rocks all land in later commits.

# Defaults to the forest resource directly (not GameState.current_biome)
# so this scene stays loadable/testable standalone, independent of
# autoload init order. Once Main.tscn exists (flight milestone) it can
# assign GameState.current_biome onto an Arena instance before use.
@export var biome: BiomeConfig = preload("res://resources/biomes/forest.tres")

## Hand-authored level layout: which entry of biome.platform_scenes to
## place, and where. Positions are in this scene's local space.
@export var platform_layout: Array[Dictionary] = [
	{"scene_index": 0, "position": Vector2(220, 940)},
	{"scene_index": 1, "position": Vector2(520, 980)},
]

@onready var background: Polygon2D = $Background
@onready var ground_visual: Polygon2D = $Ground/GroundVisual
@onready var platforms: Node2D = $Platforms


func _ready() -> void:
	_apply_biome_colors()
	_spawn_platforms()


func _apply_biome_colors() -> void:
	background.color = biome.sky_color
	ground_visual.color = biome.ground_color


func _spawn_platforms() -> void:
	for entry: Dictionary in platform_layout:
		var scene: PackedScene = biome.platform_scenes[entry["scene_index"]]
		var instance: Node2D = scene.instantiate()
		instance.position = entry["position"]
		platforms.add_child(instance)
