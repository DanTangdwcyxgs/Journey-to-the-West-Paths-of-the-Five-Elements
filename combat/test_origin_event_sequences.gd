extends RefCounted

## Runtime regression for the complete Wukong Origin Route sequence migration.
const WUKONG_SEQUENCE_IDS := [
	"WUK-01-SEQUENCE",
	"WUK-02-SEQUENCE",
	"WUK-03-SEQUENCE",
	"WUK-04-SEQUENCE",
	"WUK-05-SEQUENCE",
	"WUK-06-SEQUENCE",
	"WUK-07-SEQUENCE",
	"WUK-08-SEQUENCE",
	"WUK-09-SEQUENCE",
	"WUK-10-SEQUENCE",
	"WUK-11-SEQUENCE",
	"WUK-12-SEQUENCE",
	"WUK-13-SEQUENCE",
	"WUK-14-SEQUENCE",
	"WUK-15-SEQUENCE",
]

const CHOICE_IDS := {
	"WUK-03-SEQUENCE": "SEEK_FREEDOM",
	"WUK-08-SEQUENCE": "ACCEPT_TITLE",
	"WUK-13-SEQUENCE": "ENDURE",
}

const EXPECTED_BATTLES := {
	"WUK-02-SEQUENCE": "WUKONG_ORIGIN_WATER_CAVE",
	"WUK-06-SEQUENCE": "WUKONG_ORIGIN_DRAGON_PALACE",
	"WUK-11-SEQUENCE": "WUKONG_ORIGIN_HEAVENLY_TROOPS",
	"WUK-12-SEQUENCE": "WUKONG_ORIGIN_ERLANG_SHEN",
	"WUK-14-SEQUENCE": "WUKONG_ORIGIN_HEAVEN_PALACE",
}

static func run_all() -> Dictionary:
	var completed_sequences := 0
	var battle_handoffs := 0
	var choice_sequences := 0

	var manager := NarrativeManager.new()
	assert(manager.start_new_game("WUKONG"))

	var origin_events := OriginEventManager.new()
	var wuk03_definition := origin_events.get_definition("WUK-03")
	assert(not wuk03_definition.is_empty(), "WUK-03 definition should not be empty")
	assert(EventRuntime.can_present(wuk03_definition, manager, "ORIGIN"), "WUK-03 should be presentable")

	for sequence_id in WUKONG_SEQUENCE_IDS:
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, "%s definition should load" % sequence_id)
		assert(not definition.is_empty(), "%s definition should not be empty" % sequence_id)
		assert(definition.validate().get("valid", false), "%s definition should validate" % sequence_id)

		var runner := EventRunner.new(definition, manager, "ORIGIN")
		var action := runner.start()
		assert(not action.is_empty(), "%s should return a start action" % sequence_id)
		assert(not runner.has_error(), "%s start should not error" % sequence_id)

		var guard := 0
		while true:
			guard += 1
			assert(guard < 32, "%s exceeded safe action step count" % sequence_id)
			assert(not action.is_empty(), "%s returned an empty action" % sequence_id)

			var kind := str(action.get("kind", ""))
			match kind:
				EventRunner.DIALOGUE:
					action = runner.complete_action()
				EventRunner.WAIT:
					assert(float(action.get("seconds", -1.0)) >= 0.0, "%s WAIT should have non-negative seconds" % sequence_id)
					action = runner.complete_action()
				EventRunner.MOVE:
					action = runner.complete_action()
				EventRunner.CHOICE:
					assert(CHOICE_IDS.has(sequence_id), "%s choice id should be declared" % sequence_id)
					action = runner.submit_choice(str(CHOICE_IDS[sequence_id]))
					choice_sequences += 1
				EventRunner.BATTLE:
					assert(EXPECTED_BATTLES.has(sequence_id), "%s battle should be declared" % sequence_id)
					var expected_encounter := str(EXPECTED_BATTLES[sequence_id])
					assert(str(action.get("handoff", {}).get("encounter_id", "")) == expected_encounter, "%s battle handoff mismatch" % sequence_id)
					var saved := runner.to_dict()
					var resumed := EventRunner.new(definition, manager, "ORIGIN")
					assert(resumed.restore(saved), "%s battle snapshot should restore" % sequence_id)
					assert(resumed.get_action().get("kind", "") == EventRunner.BATTLE, "%s restored action should remain BATTLE" % sequence_id)
					action = resumed.resolve_battle(true)
					assert(not action.is_empty(), "%s battle victory should resume sequence" % sequence_id)
					runner = resumed
					battle_handoffs += 1
				EventRunner.END:
					assert(runner.is_finished(), "%s END should mark runner finished" % sequence_id)
					break
				_:
					assert(false, "%s returned unsupported action: %s" % [sequence_id, kind])

			assert(not runner.has_error(), "%s should not error during execution" % sequence_id)

		completed_sequences += 1

	assert(completed_sequences == WUKONG_SEQUENCE_IDS.size())
	assert(battle_handoffs == 5)
	assert(choice_sequences == 3)
	assert(int(manager.state.relationship_values.get("WUKONG_FREEDOM", 0)) == 2)
	assert(manager.state.get_origin_choice("WUK-03") == "SEEK_FREEDOM")
	assert(manager.state.get_origin_choice("WUK-08") == "ACCEPT_TITLE")
	assert(manager.state.get_origin_choice("WUK-13") == "ENDURE")

	return {
		"passed": true,
		"executed_sequences": completed_sequences,
		"expected_sequences": WUKONG_SEQUENCE_IDS.size(),
		"battle_handoffs_verified": battle_handoffs,
		"choice_sequences_verified": choice_sequences,
		"complete_wukong_route_verified": true,
	}
