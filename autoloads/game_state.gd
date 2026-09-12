extends Node

## Cross-scene session state (autoload singleton "GameState").
##
## Fields are added incrementally as each build-order milestone in
## docs/TECH_PLAN.md needs them (§7, §17) — this commit only needs the
## active biome so the arena scene has something to read. Rocks, HP,
## wave/mode tracking, and the high-score counters land in later commits
## rather than sitting here unused ahead of time.

## The biome currently being played — drives arena dressing, platforms,
## and (later) enemies/flight obstacles. Defaults to the forest draft.
var current_biome: BiomeConfig = preload("res://resources/biomes/forest.tres")
