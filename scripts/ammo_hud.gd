extends HBoxContainer

const BulletTexture := preload("res://assets/glock/BulletSprite.png")
const EmptyBulletTexture := preload("res://assets/glock/EmptyBulletSprite.png")
const PIP_SIZE := Vector2(20, 20)
const PIP_SEPARATION := 2

# The source art is a 64x64 canvas with a lot of transparent padding around
# a small bullet shape; crop tightly to it so pips actually sit close
# together instead of each showing mostly empty space.
const SPRITE_CONTENT_REGION := Rect2(26, 29, 14, 7)

var _pips: Array[TextureRect] = []
var _filled_texture: AtlasTexture
var _empty_texture: AtlasTexture


func _ready() -> void:
	_filled_texture = _cropped(BulletTexture)
	_empty_texture = _cropped(EmptyBulletTexture)

	if not InputBridge.player:
		return
	var weapon: Weapon = InputBridge.player.glock_mount
	weapon.ammo_changed.connect(_on_ammo_changed)
	# The weapon already emitted its initial state before we could have
	# connected (it's readied earlier in the tree), so pull it directly.
	_on_ammo_changed(weapon.rounds_in_mag, Weapon.MAG_SIZE)


func _cropped(texture: Texture2D) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = SPRITE_CONTENT_REGION
	return atlas


func _on_ammo_changed(rounds_in_mag: int, mag_size: int) -> void:
	if _pips.is_empty():
		add_theme_constant_override("separation", PIP_SEPARATION)
		for i in mag_size:
			var pip := TextureRect.new()
			pip.custom_minimum_size = PIP_SIZE
			pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			add_child(pip)
			_pips.append(pip)

	for i in _pips.size():
		_pips[i].texture = _filled_texture if i < rounds_in_mag else _empty_texture
