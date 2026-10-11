extends RefCounted

## If the final Origin -> Shared save fails, narrative and derived party state must both roll back.
class SaveFailingNarrativeManager:
	extends NarrativeManager

	var save_attempts: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		return false

static func run_all() -> Dictionary:
	var manager := SaveFailingNarrativeManager.new()
	assert(manager.start_new_game("WUKONG"), "Wukong route should initialize")
	var chapters: Array = manager.origin_routes.get_chapters("WUKONG")
	for i in range(maxi(chapters.size() - 1, 0)):
		var expected_id := str(chapters[i].get("id", ""))
		var completed: Dictionary = manager.complete_origin_chapter("WUKONG")
		assert(str(completed.get("id", "")) == expected_id, "%s should be completed before the rollback case" % expected_id)
	assert(str(manager.origin_routes.get_current_chapter(manager, "WUKONG").get("id", "")) == "WUK-15", "manager should be poised at the final Origin chapter")

	var journey := OriginSequenceJourneyScreen.new()
	journey.narrative = manager
	journey.party.initialize_from_saved_state(manager.state.recruited_characters, manager.state.get_party_formation())
	journey.call("_build_ui")
	var party_before: Dictionary = journey.party.to_dict().duplicate(true)
	var state_before: Dictionary = manager.serialize().duplicate(true)

	var definition: EventSequenceDefinition = EventSequenceManager.get_definition("WUK-15-SEQUENCE")
	assert(definition != null, "WUK-15 production sequence should load")
	var session := NarrativeEventSession.new(definition, manager, "ORIGIN")
	var action: Dictionary = session.start()
	var guard := 0
	while str(action.get("kind", "")) != EventRunner.END:
		guard += 1
		assert(guard < 12, "WUK-15 should reach END within its dialogue-only path")
		assert(str(action.get("kind", "")) == EventRunner.DIALOGUE, "WUK-15 rollback fixture should not require combat or choices")
		action = session.complete_action()
	assert(session.runner.is_finished(), "WUK-15 runner should be at its terminal END")

	journey.event_session = session
	journey.call("_finish_event_session")

	assert(manager.save_attempts == 1, "final Origin completion should attempt exactly one save")
	assert(manager.serialize() == state_before, "save failure should restore the full pre-END NarrativeState")
	assert(manager.state.current_shared_chapter.is_empty(), "failed save must not leave a half-committed Shared chapter")
	assert(str(manager.origin_routes.get_current_chapter(manager, "WUKONG").get("id", "")) == "WUK-15", "failed save should restore the final Origin chapter cursor")
	assert(journey.event_session == session, "failed save should keep the END session open for retry")
	assert(journey.party.to_dict() == party_before, "PartyManager should roll back alongside NarrativeState")
	assert(journey.phase_label.text.find("存档失败") >= 0, "Journey should communicate that the completion save failed")

	journey.free()
	return {
		"passed": true,
		"save_attempts": manager.save_attempts,
		"narrative_rollback_checked": true,
		"party_rollback_checked": true,
		"end_session_retryable": true,
	}
