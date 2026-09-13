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

const KAKAPO_SPAWN_POSITION := Vector2(360, 650)
# Above the visible arena — a failed flight drops the kakapo back in from
# up here and lets normal arena gravity carry it down onto the ground.
const ARENA_DROP_IN_Y := -100.0

const FlyTransitionScene := preload("res://scenes/flight/fly_transition.tscn")
const FlyAscentScene := preload("res://scenes/flight/fly_ascent.tscn")
const NestCutsceneScene := preload("res://scenes/flight/nest_cutscene.tscn")

@onready var background: Polygon2D = $Background
@onready var grass_visual: Polygon2D = $Ground/GrassVisual
@onready var soil_visual: Polygon2D = $Ground/SoilVisual
@onready var platforms: Node2D = $Platforms
@onready var kakapo: CharacterBody2D = $Kakapo
@onready var main_camera: Camera2D = $MainCamera
@onready var fly_button: Button = $HUD/FlyButton
@onready var ammo_hud: Control = $HUD/AmmoHUD


func _ready() -> void:
	_apply_biome_colors()
	_spawn_platforms()
	fly_button.pressed.connect(_on_fly_pressed)


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


func _on_fly_pressed() -> void:
	get_tree().paused = true
	ammo_hud.visible = false
	# Rocks don't actually change until the ascent starts spending them, so
	# without this the button stays visible/clickable for the whole
	# sequence — hide it explicitly to block a double-press.
	fly_button.visible = false

	var transition := FlyTransitionScene.instantiate() as FlyTransition
	add_child(transition)
	transition.finished.connect(func() -> void:
		transition.queue_free()
		_start_ascent()
	)


func _start_ascent() -> void:
	var ascent := FlyAscentScene.instantiate() as FlyAscent
	add_child(ascent)
	ascent.reached_top.connect(func() -> void:
		ascent.queue_free()
		_start_nest_cutscene()
	)
	ascent.fell_to_arena.connect(func() -> void:
		# Land back in wherever they were horizontally, not always dead
		# center, so the drop-in feels continuous with where they were.
		var drop_x: float = ascent.flying_kakapo.position.x
		ascent.queue_free()
		_return_to_arena(drop_x)
	)


func _start_nest_cutscene() -> void:
	var cutscene := NestCutsceneScene.instantiate() as NestCutscene
	add_child(cutscene)
	cutscene.finished.connect(func() -> void:
		cutscene.queue_free()
		GameState.start_new_wave()
		_return_to_arena(KAKAPO_SPAWN_POSITION.x)
	)


func _return_to_arena(x_position: float) -> void:
	main_camera.make_current()
	InputBridge.player = kakapo
	kakapo.position = Vector2(x_position, ARENA_DROP_IN_Y)
	kakapo.velocity = Vector2.ZERO
	ammo_hud.visible = true
	get_tree().paused = false
