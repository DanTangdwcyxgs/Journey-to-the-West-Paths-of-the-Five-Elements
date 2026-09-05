extends RefCounted

## Regression coverage for the Tang Origin production EventSequence catalog.
const SEQUENCE_IDS := [
	"TANG-01-SEQUENCE", "TANG-02-SEQUENCE", "TANG-03-SEQUENCE", "TANG-04-SEQUENCE",
	"TANG-05-SEQUENCE", "TANG-06-SEQUENCE", "TANG-07-SEQUENCE", "TANG-08-SEQUENCE",
]

const BATTLE_IDS := {
	"TANG-06-SEQUENCE": "TANG_ORIGIN_DOUBLE_RIDGE",
	"TANG-08-SEQUENCE": "TANG_ORIGIN_FIVE_ELEMENTS",
}

const CHOICE_IDS := {
	"TANG-04-SEQUENCE": "FOLLOW_VOW",
	"TANG-07-SEQUENCE": "KEEP_WALKING",
}

static func run_all() -> Dictionary:
	for sequence_id in SEQUENCE_IDS:
		var manager := NarrativeManager.new()
		assert(manager.start_new_game("TANG"), "Tang route should start")
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, "%s should load" % sequence_id)
		var validation := EventSequenceValidator.validate(definition)
		assert(validation.get("valid", false), "%s -> %s" % [sequence_id, str(validation)])
		assert(str(definition.to_dict().get("namespace", "")) == "ORIGIN", "%s should be Origin" % sequence_id)

		var runner := EventRunner.new(definition, manager, "ORIGIN")
		var action: Dictionary = runner.start()
		assert(not action.is_empty(), "%s should start" % sequence_id)
		var guard := 0
		while true:
			guard += 1
			assert(guard < 12, "%s exceeded action guard" % sequence_id)
			var kind := str(action.get("kind", ""))
			match kind:
				EventRunner.DIALOGUE, EventRunner.WAIT, EventRunner.MOVE:
					action = runner.complete_action()
				EventRunner.CHOICE:
					assert(CHOICE_IDS.has(sequence_id), "%s choice should have regression input" % sequence_id)
					action = runner.submit_choice(str(CHOICE_IDS[sequence_id]))
				EventRunner.BATTLE:
					var handoff: Dictionary = action.get("handoff", {})
					assert(str(handoff.get("encounter_id", "")) == str(BATTLE_IDS[sequence_id]), "%s battle encounter mismatch" % sequence_id)
					assert(str(handoff.get("source_chapter_id", "")) == sequence_id.replace("-SEQUENCE", ""), "%s battle source chapter mismatch" % sequence_id)
					var snapshot := runner.to_dict()
					var restored := EventRunner.new(definition, manager, "ORIGIN")
					assert(restored.restore(snapshot), "%s battle runner snapshot should restore" % sequence_id)
					action = restored.resolve_battle(true)
					assert(action.get("kind", "") == EventRunner.DIALOGUE, "%s battle should resume to after_battle" % sequence_id)
					runner = restored
				EventRunner.END:
					assert(runner.is_finished(), "%s should finish" % sequence_id)
					break
				_:
					assert(false, "%s returned unsupported action %s" % [sequence_id, kind])

		assert(manager.state.origin_choices.get(sequence_id.replace("-SEQUENCE", ""), "") == (CHOICE_IDS.get(sequence_id, "") if CHOICE_IDS.has(sequence_id) else ""), "%s choice persistence should match" % sequence_id)
		if sequence_id in BATTLE_IDS:
			assert(not manager.state.completed_chapters.has(sequence_id.replace("-SEQUENCE", "")), "%s runner-only battle regression must not advance chapter state" % sequence_id)

	return {
		"passed": true,
		"sequences_verified": SEQUENCE_IDS.size(),
		"battle_sequences_verified": BATTLE_IDS.size(),
		"choice_sequences_verified": CHOICE_IDS.size(),
		"uses_route_specific_catalog": true,
	}
