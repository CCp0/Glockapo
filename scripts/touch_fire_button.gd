extends Button


func _ready() -> void:
	visible = OS.has_feature("mobile")
	button_down.connect(func() -> void: InputBridge.set_touch_fire_held(true))
	button_up.connect(func() -> void: InputBridge.set_touch_fire_held(false))
