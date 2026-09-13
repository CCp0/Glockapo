extends Node

const FADE_DURATION := 0.8
const MIN_VOLUME_DB := -50.0

const TitleMusic := preload("res://assets/music/Title Screen Music.wav")
const GameplayMusic := preload("res://assets/music/Gameplay Music.wav")
const FlyingMusic := preload("res://assets/music/Flying Music.wav")

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active_player: AudioStreamPlayer
var _inactive_player: AudioStreamPlayer
var _current_stream: AudioStream = null

var _fade_time_remaining: float = 0.0
var _fading_in: AudioStreamPlayer = null
var _fading_out: AudioStreamPlayer = null


func _ready() -> void:
	# Music must keep playing (and fading) through the paused flight
	# sequence, same reasoning as InputBridge.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player_a = AudioStreamPlayer.new()
	_player_b = AudioStreamPlayer.new()
	add_child(_player_a)
	add_child(_player_b)
	
	_player_a.finished.connect(_on_finished.bind(_player_a))
	_player_b.finished.connect(_on_finished.bind(_player_b))
	_active_player = _player_a
	_inactive_player = _player_b

	print("[Music] ready — TitleMusic=%s GameplayMusic=%s FlyingMusic=%s" % [TitleMusic, GameplayMusic, FlyingMusic])


func _on_finished(player: AudioStreamPlayer) -> void:
	player.play()


func play_title() -> void:
	_crossfade_to(TitleMusic)


func play_gameplay() -> void:
	_crossfade_to(GameplayMusic)


func play_flying() -> void:
	_crossfade_to(FlyingMusic)


func _crossfade_to(stream: AudioStream) -> void:
	print("[Music] _crossfade_to(%s) — current is %s" % [stream, _current_stream])
	if stream == _current_stream:
		return
	_current_stream = stream

	_fading_out = _active_player if _active_player.playing else null
	_fading_in = _inactive_player

	_fading_in.stream = stream
	_fading_in.volume_db = MIN_VOLUME_DB
	_fading_in.play()
	_fade_time_remaining = FADE_DURATION

	print("[Music] playing=%s volume_db=%s stream=%s" % [_fading_in.playing, _fading_in.volume_db, _fading_in.stream])

	var previous_active: AudioStreamPlayer = _active_player
	_active_player = _inactive_player
	_inactive_player = previous_active


func _process(delta: float) -> void:
	if _fade_time_remaining <= 0.0:
		return

	_fade_time_remaining = maxf(_fade_time_remaining - delta, 0.0)
	var progress: float = 1.0 - _fade_time_remaining / FADE_DURATION

	_fading_in.volume_db = lerpf(MIN_VOLUME_DB, 0.0, progress)
	if _fading_out:
		_fading_out.volume_db = lerpf(0.0, MIN_VOLUME_DB, progress)

	if _fade_time_remaining <= 0.0 and _fading_out:
		_fading_out.stop()
		_fading_out = null
