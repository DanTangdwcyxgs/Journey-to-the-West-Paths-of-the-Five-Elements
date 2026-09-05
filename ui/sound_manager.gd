class_name SoundManager
extends Node

const MIX_RATE := 44100.0
const BUS_NAME := "SFX"

var _player: AudioStreamPlayer
var _stream: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback
var _connected_scene: Node = null
var _connected_buttons: Array[Button] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_stream = AudioStreamGenerator.new()
	_stream.mix_rate = MIX_RATE
	_stream.buffer_length = 0.35
	_player = AudioStreamPlayer.new()
	_player.stream = _stream
	_player.bus = BUS_NAME if AudioServer.get_bus_index(BUS_NAME) >= 0 else &"Master"
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null or scene == _connected_scene:
		return
	_connected_scene = scene
	_connected_buttons.clear()
	_connect_buttons(scene)

func _connect_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			var button := child as Button
			if not button.pressed.is_connected(_on_button_pressed):
				button.pressed.connect(_on_button_pressed)
			_connected_buttons.append(button)
		_connect_buttons(child)

func _on_button_pressed() -> void:
	play_ui_confirm()

func play_ui_confirm() -> void:
	_play_notes([660.0, 880.0], 0.055, 0.075, 0.02)

func play_ui_back() -> void:
	_play_notes([440.0, 330.0], 0.065, 0.06, 0.02)

func play_attack(power: float = 1.0) -> void:
	var strength := clampf(power, 0.25, 2.0)
	_play_notes([180.0, 120.0], 0.10, 0.12 * strength, 0.06)

func play_hit(power: float = 1.0) -> void:
	var strength := clampf(power, 0.25, 2.0)
	_play_noise(0.075, 0.08 * strength)
	_play_notes([90.0, 65.0], 0.11, 0.08 * strength, 0.03)

func play_victory() -> void:
	_play_notes([523.25, 659.25, 783.99, 1046.5], 0.10, 0.10, 0.025)

func play_fail() -> void:
	_play_notes([392.0, 330.0, 261.63, 196.0], 0.10, 0.09, 0.025)

func _play_notes(frequencies: Array[float], note_duration: float, amplitude: float, gap: float) -> void:
	if _playback == null:
		return
	for frequency in frequencies:
		_fill_sine(frequency, note_duration, amplitude)
		if gap > 0.0:
			_fill_silence(gap)

func _fill_sine(frequency: float, duration: float, amplitude: float) -> void:
	var frames := maxi(1, int(MIX_RATE * duration))
	for i in range(frames):
		if _playback.get_frames_available() <= 0:
			return
		var t := float(i) / MIX_RATE
		var envelope := 1.0 - (float(i) / float(frames))
		var sample := sin(TAU * frequency * t) * amplitude * envelope
		_playback.push_frame(Vector2(sample, sample))

func _fill_silence(duration: float) -> void:
	var frames := maxi(1, int(MIX_RATE * duration))
	for _i in range(frames):
		if _playback.get_frames_available() <= 0:
			return
		_playback.push_frame(Vector2.ZERO)

func _play_noise(duration: float, amplitude: float) -> void:
	var frames := maxi(1, int(MIX_RATE * duration))
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(frames):
		if _playback.get_frames_available() <= 0:
			return
		var envelope := 1.0 - (float(i) / float(frames))
		var sample := rng.randf_range(-1.0, 1.0) * amplitude * envelope
		_playback.push_frame(Vector2(sample, sample))
