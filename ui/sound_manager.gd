class_name SoundManager
extends Node

const MIX_RATE := 44100.0
const BUS_NAME := "SFX"

var _player: AudioStreamPlayer
var _connected_scene: Node = null
var _connected_buttons: Array[Button] = []
var _pending_wavs: Array[AudioStreamWAV] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.bus = BUS_NAME if AudioServer.get_bus_index(BUS_NAME) >= 0 else &"Master"
	_player.finished.connect(_on_player_finished)
	add_child(_player)
	set_process(true)

func _exit_tree() -> void:
	_release_audio_resources()

## Stop audio and release player resources. Safe to invoke repeatedly.
func _release_audio_resources() -> void:
	set_process(false)
	_connected_buttons.clear()
	_connected_scene = null
	_pending_wavs.clear()

	var player_to_free: AudioStreamPlayer = _player
	_player = null
	if is_instance_valid(player_to_free):
		player_to_free.stop()
		player_to_free.stream = null
		if player_to_free.get_parent() == self:
			remove_child(player_to_free)
		player_to_free.free()

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
	var samples: Array[float] = []
	_append_noise(samples, 0.075, 0.08 * strength)
	_append_sine(samples, 90.0, 0.11, 0.08 * strength)
	_append_silence(samples, 0.03)
	_append_sine(samples, 65.0, 0.11, 0.08 * strength)
	_queue_samples(samples)

func play_victory() -> void:
	_play_notes([523.25, 659.25, 783.99, 1046.5], 0.10, 0.10, 0.025)

func play_fail() -> void:
	_play_notes([392.0, 330.0, 261.63, 196.0], 0.10, 0.09, 0.025)

func _play_notes(frequencies: Array[float], note_duration: float, amplitude: float, gap: float) -> void:
	var samples: Array[float] = []
	for frequency in frequencies:
		_append_sine(samples, frequency, note_duration, amplitude)
		if gap > 0.0:
			_append_silence(samples, gap)
	_queue_samples(samples)

func _append_sine(samples: Array[float], frequency: float, duration: float, amplitude: float) -> void:
	var frames := maxi(1, int(MIX_RATE * duration))
	for i in range(frames):
		var t := float(i) / MIX_RATE
		var envelope := 1.0 - (float(i) / float(frames))
		samples.append(sin(TAU * frequency * t) * amplitude * envelope)

func _append_silence(samples: Array[float], duration: float) -> void:
	var frames := maxi(1, int(MIX_RATE * duration))
	for _i in range(frames):
		samples.append(0.0)

func _append_noise(samples: Array[float], duration: float, amplitude: float) -> void:
	var frames := maxi(1, int(MIX_RATE * duration))
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(frames):
		var envelope := 1.0 - (float(i) / float(frames))
		samples.append(rng.randf_range(-1.0, 1.0) * amplitude * envelope)

func _queue_samples(samples: Array[float]) -> void:
	if _player == null or not is_instance_valid(_player) or samples.is_empty():
		return
	var pcm := PackedByteArray()
	pcm.resize(samples.size() * 2)
	for i in range(samples.size()):
		var sample_value: int = clampi(roundi(clampf(samples[i], -1.0, 1.0) * 32767.0), -32768, 32767)
		pcm.encode_s16(i * 2, sample_value)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(MIX_RATE)
	wav.stereo = false
	wav.data = pcm

	if _player.playing:
		_pending_wavs.append(wav)
	else:
		_start_wav(wav)

func _start_wav(wav: AudioStreamWAV) -> void:
	if _player == null or not is_instance_valid(_player) or wav == null:
		return
	_player.stream = wav
	_player.play()

func _on_player_finished() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_player.stream = null
	if not _pending_wavs.is_empty():
		_start_wav(_pending_wavs.pop_front())
