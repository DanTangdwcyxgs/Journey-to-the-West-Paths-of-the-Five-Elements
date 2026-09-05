extends SceneTree

## SceneTree regression for the first Origin -> Shared -> EventSequence bridge.
func _initialize() -> void:
	var manager := NarrativeManager.new()
	_assert(manager.start_new_game("WUKONG"), "Wukong route should start")

	var guard := 0
	while not manager.origin_routes.is_complete(manager, "WUKONG"):
		guard += 1
		_assert(guard < 32, "Wukong origin should complete")
		_assert(not manager.complete_origin_chapter("WUKONG").is_empty(), "origin chapter should complete")

	_assert(manager.handoff_origin_to_shared("WUKONG"), "Wukong origin should enter shared journey")
	_assert(manager.state.current_shared_chapter == "SHARED-01-FIVE-ELEMENTS", "handoff should enter shared opening")

	var scene := load("res://ui/journey.tscn") as PackedScene
	_assert(scene != null, "journey scene should load")
	var instance := scene.instantiate()
	_assert(instance is JourneyScreen, "journey scene should instantiate JourneyScreen")
	instance.call("_build_ui")
	instance.narrative = manager
	instance.event_session = null

	instance.call("_advance_primary")
	_assert(instance.event_session != null, "shared opening should create event session")
	_assert(instance.event_session.sequence.get_id() == "SHARED-01-FIVE-ELEMENTS-SEQUENCE", "shared opening sequence id should match")
	_assert(instance.event_session.get_action().get("kind", "") == EventRunner.DIALOGUE, "shared opening should start with dialogue")

	instance.call("_advance_primary")
	_assert(instance.event_session.get_action().get("kind", "") == EventRunner.CHOICE, "shared opening should reach choice")

	instance.call("_submit_event_choice", "TRUST_WUKONG")
	_assert(manager.state.get_shared_choice("SHARED-01-FIVE-ELEMENTS") == "TRUST_WUKONG", "shared choice should persist")
	_assert(instance.event_session.get_action().get("kind", "") == EventRunner.DIALOGUE, "shared choice should continue to dialogue")

	instance.call("_advance_primary")
	_assert(instance.event_session != null, "sequence should remain until END is handled")
	_assert(instance.event_session.get_action().get("kind", "") == EventRunner.END, "shared opening should reach END")

	instance.call("_advance_primary")
	_assert(instance.event_session == null, "completed shared sequence should clear event session")
	_assert(manager.state.current_shared_chapter == "SHARED-02-EARLY-PILGRIMAGE", "shared completion should advance to next chapter")
	_assert("SHARED-01-FIVE-ELEMENTS" in manager.state.completed_shared_chapters, "shared opening should record completion")

	instance.queue_free()
	print("ALL SHARED OPENING JOURNEY BRIDGE TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
