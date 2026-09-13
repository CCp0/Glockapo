extends Button


func _ready() -> void:
	visible = GameState.rocks >= GameState.ROCKS_TO_UNLOCK_FLY
	GameState.rocks_changed.connect(_on_rocks_changed)


func _on_rocks_changed(new_value: int) -> void:
	visible = new_value >= GameState.ROCKS_TO_UNLOCK_FLY
