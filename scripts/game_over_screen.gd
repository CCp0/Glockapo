extends CanvasLayer

@onready var restart_button: Button = $RestartButton


func _ready() -> void:
	visible = false
	GameState.died.connect(_on_died)
	restart_button.pressed.connect(_on_restart_pressed)


func _on_died() -> void:
	visible = true


func _on_restart_pressed() -> void:
	GameState.reset()
	get_tree().reload_current_scene()
