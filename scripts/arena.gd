extends Node2D

# Defaults to the forest resource currently (not GameState.current_biome)
@export var biome: BiomeConfig = preload("res://resources/biomes/forest.tres")

# scene_index into biome.platform_scenes (0 = branch, 1 = stump for forest).
# Negative scale.x mirrors a branch so it reads as entering from the right.
@export var platform_layout: Array[Dictionary] = [
	{"scene_index": 0, "position": Vector2(50, 480), "scale": Vector2(2.6, 2.6)},
	{"scene_index": 0, "position": Vector2(670, 380), "scale": Vector2(-2.6, 2.6)},
	{"scene_index": 1, "position": Vector2(180, 740), "scale": Vector2(1.5, 1.5)},
	{"scene_index": 1, "position": Vector2(540, 740), "scale": Vector2(1.5, 1.5)},
]

@onready var background: Polygon2D = $Background
@onready var grass_visual: Polygon2D = $Ground/GrassVisual
@onready var soil_visual: Polygon2D = $Ground/SoilVisual
@onready var platforms: Node2D = $Platforms


func _ready() -> void:
	_apply_biome_colors()
	_spawn_platforms()


func _apply_biome_colors() -> void:
	background.color = biome.sky_color
	grass_visual.color = biome.ground_color
	soil_visual.color = biome.ground_base_color


func _spawn_platforms() -> void:
	for entry: Dictionary in platform_layout:
		var scene: PackedScene = biome.platform_scenes[entry["scene_index"]]
		var instance: Node2D = scene.instantiate()
		instance.position = entry["position"]
		instance.scale = entry.get("scale", Vector2.ONE)
		platforms.add_child(instance)
