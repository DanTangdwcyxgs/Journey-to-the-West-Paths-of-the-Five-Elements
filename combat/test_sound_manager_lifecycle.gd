extends SceneTree

## Audio playback resources must be finite and released when the sound service exits.
func _initialize() -> void:
	await _run_lifecycle_test()

func _run_lifecycle_test() -> void:
	var manager := SoundManager.new()
	root.add_child(manager)
	await process_frame
	manager.play_ui_confirm()
	_assert(manager._player.stream is AudioStreamWAV, "sound effects should use finite WAV resources instead of a permanently playing generator")
	var wav := manager._player.stream as AudioStreamWAV
	_assert(wav != null and wav.data.size() > 0, "generated WAV data should contain PCM samples")
	_assert(wav.format == AudioStreamWAV.FORMAT_16_BITS and not wav.stereo, "generated WAV should use signed 16-bit mono PCM")

	manager.call("_release_audio_resources")
	_assert(manager._player == null, "cleanup should clear the AudioStreamPlayer reference")
	_assert(manager.get_child_count() == 0, "cleanup should free the generated player node")
	_assert(manager._pending_wavs.is_empty(), "cleanup should clear queued audio clips")

	var autoload := root.get_node_or_null("GameSfx") as SoundManager
	if autoload != null:
		autoload.call("_release_audio_resources")
		_assert(autoload._player == null, "autoload cleanup should clear its player reference")
		_assert(autoload.get_child_count() == 0, "autoload cleanup should free its generated player node")

	manager.queue_free()
	await process_frame
	print("SOUND_MANAGER_LIFECYCLE_PASS")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
