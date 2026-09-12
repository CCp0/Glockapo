extends HBoxContainer

const PIP_SIZE := Vector2(20, 20)
const PIP_COLOR := Color(0.8, 0.15, 0.15)
const PIP_EMPTY_COLOR := Color(0.3, 0.3, 0.3, 0.5)

var _pips: Array[ColorRect] = []


func _ready() -> void:
	for i in GameState.MAX_HP:
		var pip := ColorRect.new()
		pip.custom_minimum_size = PIP_SIZE
		add_child(pip)
		_pips.append(pip)
	GameState.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(GameState.hp)


func _on_hp_changed(new_value: int) -> void:
	for i in _pips.size():
		_pips[i].color = PIP_COLOR if i < new_value else PIP_EMPTY_COLOR
