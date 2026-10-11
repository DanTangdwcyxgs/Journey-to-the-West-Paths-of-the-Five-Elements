extends SceneTree

## The audio singleton owns a generated playback object; its lifecycle must be explicit.
func _initialize() -> void:
	await _run_lifecycle_test()

func _run_lifecycle_test() -> void:
	var manager := SoundManager.new()
	root.add_child(manager)
	await process_frame

	manager.call("_release_audio_resources")
	_assert(manager._playback == null, "cleanup should clear the AudioStreamGeneratorPlayback reference")
	_assert(manager._stream == null, "cleanup should clear the AudioStreamGenerator reference")
	_assert(manager._player == null, "cleanup should clear the AudioStreamPlayer reference")
	_assert(manager.get_child_count() == 0, "cleanup should free the generated player node")

	var autoload := root.get_node_or_null("GameSfx") as SoundManager
	if autoload != null:
		autoload.call("_release_audio_resources")
		_assert(autoload._playback == null, "autoload cleanup should release its playback reference")
		_assert(autoload.get_child_count() == 0, "autoload cleanup should free its generated player node")

	manager.queue_free()
	await process_frame
	print("SOUND_MANAGER_LIFECYCLE_PASS")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
