extends Node2D

# Defaults to the forest resource currently (not GameState.current_biome)
@export var biome: BiomeConfig = preload("res://resources/biomes/forest.tres")

const KAKAPO_SPAWN_POSITION := Vector2(360, 650)
# Above the visible arena — a failed flight drops the kakapo back in from
# up here and lets normal arena gravity carry it down onto the ground.
const ARENA_DROP_IN_Y := -100.0

const FlyTransitionScene := preload("res://scenes/flight/fly_transition.tscn")
const FlyAscentScene := preload("res://scenes/flight/fly_ascent.tscn")
const NestCutsceneScene := preload("res://scenes/flight/nest_cutscene.tscn")

@onready var background: Polygon2D = $Background
@onready var soil_visual: Polygon2D = $Ground/SoilVisual
@onready var kakapo: CharacterBody2D = $Kakapo
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var main_camera: Camera2D = $MainCamera
@onready var fly_button: Button = $HUD/FlyButton
@onready var ammo_hud: Control = $HUD/AmmoHUD


func _ready() -> void:
	_apply_biome_colors()
	fly_button.pressed.connect(_on_fly_pressed)
	Music.play_gameplay()


func _apply_biome_colors() -> void:
	background.color = biome.sky_color
	soil_visual.color = biome.ground_base_color


func _on_fly_pressed() -> void:
	get_tree().paused = true
	Music.play_flying()
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
		# fell_to_arena originates from FlyingKakapo's _physics_process —
		# defer so any enemy add/remove below doesn't risk the same
		# mid-physics-flush error fixed for pigeon deaths earlier.
		call_deferred("_return_to_arena", drop_x)
	)


func _start_nest_cutscene() -> void:
	var cutscene := NestCutsceneScene.instantiate() as NestCutscene
	add_child(cutscene)
	cutscene.finished.connect(func() -> void:
		cutscene.queue_free()
		GameState.start_new_wave()
		call_deferred("_return_to_arena", KAKAPO_SPAWN_POSITION.x)
	)


func _return_to_arena(x_position: float) -> void:
	main_camera.make_current()
	Music.play_gameplay()
	InputBridge.player = kakapo
	kakapo.position = Vector2(x_position, ARENA_DROP_IN_Y)
	kakapo.velocity = Vector2.ZERO
	ammo_hud.visible = true
	_clear_enemies()
	enemy_spawner.reset_for_new_wave()
	get_tree().paused = false


func _clear_enemies() -> void:
	for child in get_children():
		if child is EnemyBase:
			child.queue_free()
