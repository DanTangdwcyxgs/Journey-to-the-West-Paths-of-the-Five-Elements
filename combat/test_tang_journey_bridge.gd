extends SceneTree

## Regression coverage for Tang Route entering the shared Journey presentation bridge.
func _initialize() -> void:
	var scene := load("res://ui/journey.tscn") as PackedScene
	_assert(scene != null, "journey scene should load")
	var instance := scene.instantiate()
	_assert(instance is JourneyScreen, "journey scene should remain JourneyScreen-compatible")
	instance.call("_build_ui")

	var manager := NarrativeManager.new()
	_assert(manager.start_new_game("TANG"), "Tang route should start")
	instance.narrative = manager
	instance.event_session = null

	instance.call("_advance_primary")
	_assert(instance.event_session != null, "Tang migrated chapter should create an event session")
	_assert(instance.event_session.sequence != null, "Tang event session should hold a sequence")
	_assert(instance.event_session.sequence.get_id() == "TANG-01-SEQUENCE", "Tang journey bridge should enter TANG-01 sequence")
	_assert(instance.event_session.get_action().get("kind", "") == EventRunner.DIALOGUE, "Tang TANG-01 should present dialogue")

	instance.queue_free()
	print("ALL TANG JOURNEY BRIDGE TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
