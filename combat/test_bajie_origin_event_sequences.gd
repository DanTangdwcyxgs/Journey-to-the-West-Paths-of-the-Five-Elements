extends RefCounted

## Regression coverage for the Bajie Origin production EventSequence catalog.
const SEQUENCE_IDS := [
	"BAJIE-01-SEQUENCE", "BAJIE-02-SEQUENCE", "BAJIE-03-SEQUENCE",
	"BAJIE-04-SEQUENCE", "BAJIE-05-SEQUENCE", "BAJIE-06-SEQUENCE",
	"BAJIE-07-SEQUENCE", "BAJIE-08-SEQUENCE", "BAJIE-09-SEQUENCE",
]

const BATTLE_IDS := {
	"BAJIE-06-SEQUENCE": "BAJIE_ORIGIN_GAO_WILD",
	"BAJIE-08-SEQUENCE": "BAJIE_ORIGIN_WUKONG_DUEL",
}

const CHOICE_IDS := {
	"BAJIE-02-SEQUENCE": "HOLD_BACK",
	"BAJIE-06-SEQUENCE": "CHOOSE_HOME",
}

static func run_all() -> Dictionary:
	for sequence_id in SEQUENCE_IDS:
		var manager := NarrativeManager.new()
		assert(manager.start_new_game("BAJIE"), "Bajie route should start")
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
			match str(action.get("kind", "")):
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
					assert(false, "%s returned unsupported action %s" % [sequence_id, str(action.get("kind", ""))])

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
