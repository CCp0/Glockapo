extends Node2D
class_name NestCutscene

signal finished

enum Phase { HOLD, DRAW, SHOOTING, END_HOLD, BLANK }

const HOLD_DURATION := 1.0
const DRAW_DURATION := 0.5
const SHOT_INTERVAL := 0.35
const END_HOLD_DURATION := 0.5
const BLANK_DURATION := 0.4

const SHAKE_MAGNITUDE := 6.0
const SHAKE_SPEED := 30.0

var _phase: Phase = Phase.HOLD
var _phase_timer: float = 0.0
var _timer: float = 0.0
var _shots_fired: int = 0
var _shots_needed: int = 0
var _finished: bool = false
var _kakapo_base_position: Vector2

@onready var camera: Camera2D = $Camera2D
@onready var kakapo_sprite: Sprite2D = $KakapoSprite
@onready var glock_sprite: Sprite2D = $GlockSprite
@onready var nest_sprite: AnimatedSprite2D = $Nest
@onready var blank_overlay: Polygon2D = $BlankOverlay
@onready var gunshot_audio: AudioStreamPlayer = $GunshotAudio


func _ready() -> void:
	camera.make_current()
	_kakapo_base_position = kakapo_sprite.position
	_shots_needed = nest_sprite.sprite_frames.get_frame_count("default") - 1
	if _shots_needed <= 0:
		_advance_phase(Phase.END_HOLD)


func _process(delta: float) -> void:
	_timer += delta
	_phase_timer += delta
	kakapo_sprite.position = _kakapo_base_position + Vector2(sin(_timer * SHAKE_SPEED) * SHAKE_MAGNITUDE, 0.0)

	match _phase:
		Phase.HOLD:
			if _phase_timer >= HOLD_DURATION:
				_advance_phase(Phase.DRAW)
		Phase.DRAW:
			
			var draw_progress: float = clampf(_phase_timer / DRAW_DURATION, 0.0, 1.0)
			glock_sprite.scale = Vector2(-draw_progress, draw_progress)
			if _phase_timer >= DRAW_DURATION:
				_advance_phase(Phase.SHOOTING)
		Phase.SHOOTING:
			if _phase_timer >= SHOT_INTERVAL:
				_phase_timer = 0.0
				_shots_fired += 1
				gunshot_audio.play()
				nest_sprite.frame = _shots_fired
				if _shots_fired >= _shots_needed:
					_advance_phase(Phase.END_HOLD)
		Phase.END_HOLD:
			if _phase_timer >= END_HOLD_DURATION:
				blank_overlay.visible = true
				_advance_phase(Phase.BLANK)
		Phase.BLANK:
			if _phase_timer >= BLANK_DURATION and not _finished:
				_finished = true
				finished.emit()


func _advance_phase(next: Phase) -> void:
	_phase = next
	_phase_timer = 0.0
