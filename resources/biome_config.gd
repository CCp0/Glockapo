class_name BiomeConfig
extends Resource

## Data describing one playable biome (forest, sea, city, ...).
##
## Arena and FlyAscent scenes read from this instead of hardcoding enemy,
## platform, or obstacle art directly, so a new biome is a new .tres +
## art asset, not a script rewrite. See docs/TECH_PLAN.md §4.
##
## Draft 1 only ships resources/biomes/forest.tres; enemy_scene and
## flight_obstacle_scenes stay empty until the pigeons/flight milestones
## fill them in.

## Short machine-readable identifier, e.g. "forest".
@export var id: String = ""

## Human-readable name, e.g. "Forest".
@export var display_name: String = ""

## Placeholder background color until real background art exists.
@export var sky_color: Color = Color(0.53, 0.75, 0.92)

## Placeholder ground color until real ground art exists.
@export var ground_color: Color = Color(0.28, 0.42, 0.18)

## Platform scenes usable in this biome's arena (forest: branch/stump;
## future sea: buoy/dock; future city: ledge/awning).
@export var platform_scenes: Array[PackedScene] = []

## Enemy scene this biome's spawner instances (forest: wood pigeon).
@export var enemy_scene: PackedScene

## Obstacle scenes used by the flight ascent scene's obstacle spawner.
@export var flight_obstacle_scenes: Array[PackedScene] = []
