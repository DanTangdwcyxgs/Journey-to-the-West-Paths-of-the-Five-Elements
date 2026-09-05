extends RefCounted

## Code-level regression coverage for the UI-independent event runner.
## This script is intentionally executable by a future Godot test harness;
## no Godot runtime execution is claimed by this change.

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("TANG"))
	assert(manager.encounter_character("WUKONG"))

	var invalid_sequence := EventSequenceDefinition.new({
		"id": "TEST-EVENT-RUNNER-INVALID",
		"start": "intro",
		"nodes": [
			{"id":"intro", "type":"dialogue", "text":"x", "next":"missing"}
		]
	})
	assert(not invalid_sequence.validate().get("valid", true))

	var sequence := EventSequenceDefinition.new({
		"schema_version": 1,
		"id": "TEST-EVENT-RUNNER",
		"start": "intro",
		"nodes": [
			{"id":"intro", "type":"dialogue", "speaker":"TANG", "text":"继续上路。", "next":"choice"},
			{"id":"choice", "type":"choice", "event_id":"SHARED-01-FIVE-ELEMENTS", "next_map": {"TRUST_WUKONG":"battle", "CAUTIOUS_VOW":"reward"}},
			{"id":"battle", "type":"battle", "encounter_type":"shared", "encounter_id":"SHARED_EAGLE_SORROW", "source_chapter_id":"TEST-CHAPTER", "next":"after_battle"},
			{"id":"after_battle", "type":"reward", "rewards":["COIN_LOW"], "next":"finish"},
			{"id":"reward", "type":"reward", "rewards":["HERB"], "next":"finish"},
			{"id":"finish", "type":"end"}
		]
	})
	assert(sequence.validate().get("valid", false))

	var runner := EventRunner.new(sequence, manager, "SHARED")
	var action := runner.start()
	assert(action.get("kind", "") == EventRunner.DIALOGUE)
	action = runner.complete_action()
	assert(action.get("kind", "") == EventRunner.CHOICE)
	assert(action.get("event_id", "") == "SHARED-01-FIVE-ELEMENTS")
	assert(action.get("next_map", {}).get("TRUST_WUKONG", "") == "battle")

	action = runner.submit_choice("TRUST_WUKONG")
	assert(action.get("kind", "") == EventRunner.BATTLE)
	var handoff: Dictionary = action.get("handoff", {})
	assert(handoff.get("encounter_type", "") == "shared")
	assert(handoff.get("encounter_id", "") == "SHARED_EAGLE_SORROW")
	assert(handoff.get("source_chapter_id", "") == "TEST-CHAPTER")

	var saved := runner.to_dict()
	var resumed := EventRunner.new(sequence, manager, "SHARED")
	assert(resumed.restore(saved))
	assert(resumed.get_action().get("kind", "") == EventRunner.BATTLE)

	action = resumed.resolve_battle(true)
	assert(action.get("kind", "") == EventRunner.REWARD)
	action = resumed.complete_action()
	assert(action.get("kind", "") == EventRunner.END)
	assert(resumed.is_finished())

	# The choice is persisted by EventRuntime and cannot be selected twice.
	assert(resumed.submit_choice("TRUST_WUKONG").is_empty())

	return {
		"passed": true,
		"sequence_id": sequence.get_id(),
		"supports_graph_validation": true,
		"supports_battle_resume": true,
		"supports_choice_persistence": true,
	}
