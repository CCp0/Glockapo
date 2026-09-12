extends HBoxContainer

const RockTexture := preload("res://assets/player_resources/Rock.png")
const ICON_SIZE := Vector2(20, 20)

var _count_label: Label


func _ready() -> void:
	var icon := TextureRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = RockTexture
	add_child(icon)

	_count_label = Label.new()
	add_child(_count_label)

	GameState.rocks_changed.connect(_on_rocks_changed)
	_on_rocks_changed(GameState.rocks)


func _on_rocks_changed(new_value: int) -> void:
	_count_label.text = str(new_value)
