class_name BiomeConfig
extends Resource

## Data describing one playable biome (forest, sea, city, ...).

@export var id: String = ""

@export var display_name: String = ""

## Placeholder background color until real background art exists
@export var sky_color: Color = Color(0.53, 0.75, 0.92)

## Placeholder ground color until real ground art exists
@export var ground_color: Color = Color(0.28, 0.42, 0.18)

## Darker base/soil band beneath the ground surface, where stumps sit
@export var ground_base_color: Color = Color(0.18, 0.12, 0.08)

@export var platform_scenes: Array[PackedScene] = []

## Enemy scene this biome's spawner instances (forest: wood pigeon).
@export var enemy_scene: PackedScene

@export var flight_obstacle_scenes: Array[PackedScene] = []
