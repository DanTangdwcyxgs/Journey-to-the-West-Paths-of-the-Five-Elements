extends RefCounted

## Runtime regression for the neutral EventSession orchestration boundary.

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("TANG"))
	assert(manager.encounter_character("WUKONG"))

	var sequence := EventSequenceDefinition.new({
		"schema_version": 1,
		"id": "TEST-EVENT-SESSION",
		"start": "intro",
		"nodes": [
			{"id":"intro", "type":"dialogue", "speaker":"TANG", "text":"继续。", "next":"choice"},
			{"id":"choice", "type":"choice", "event_id":"SHARED-01-FIVE-ELEMENTS", "next_map": {"TRUST_WUKONG":"battle"}},
			{"id":"battle", "type":"battle", "encounter_type":"shared", "encounter_id":"SHARED_EAGLE_SORROW", "source_chapter_id":"TEST-SESSION", "next":"finish"},
			{"id":"finish", "type":"end"}
		]
	})
	assert(sequence.validate().get("valid", false))

	var session := NarrativeEventSession.new(sequence, manager, "SHARED")
	assert(session.start().get("kind", "") == EventRunner.DIALOGUE)
	assert(session.complete_action().get("kind", "") == EventRunner.CHOICE)
	assert(session.submit_choice("TRUST_WUKONG").get("kind", "") == EventRunner.BATTLE)
	assert(session.is_waiting_for_battle())

	var handoff := session.start_battle_handoff()
	assert(handoff.get("encounter_type", "") == "shared")
	assert(handoff.get("encounter_id", "") == "SHARED_EAGLE_SORROW")
	assert(handoff.has("event_resume"))
	assert(handoff.get("event_resume", {}).get("runner", {}).get("pending_action", {}).get("kind", "") == EventRunner.BATTLE)

	var resumed := NarrativeEventSession.resume_from_battle_record(handoff, manager)
	assert(resumed != null)
	assert(not resumed.is_waiting_for_battle())
	assert(resumed.get_action().get("kind", "") == EventRunner.END)
	assert(resumed.runner.is_finished())

	return {
		"passed": true,
		"supports_battle_resume_context": true,
		"auto_resolves_completed_battle_handoff": true,
		"supports_ui_independent_session": true,
	}