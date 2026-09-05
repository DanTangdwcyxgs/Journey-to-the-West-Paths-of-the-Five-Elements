extends RefCounted

## Runtime regression coverage for the production Shared Journey event sequences.
## This is intentionally separate from structural validation: it executes the
## actual JSON definitions through EventSequenceManager / EventRunner and
## verifies every migrated sequence reaches its expected handoff or END node.

const SHARED_SEQUENCE_IDS := [
	"SHARED-03-EAGLE-SORROW-SEQUENCE",
	"SHARED-04-EARLY-DEMON-TALES-SEQUENCE",
	"SHARED-05-GAOJIAZHUANG-SEQUENCE",
	"SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE",
	"SHARED-07-FLOWING-SANDS-SEQUENCE",
	"SHARED-08-PARTY-FULL-SEQUENCE",
	"SHARED-09-FULL-PILGRIMAGE-SEQUENCE",
]

const CHOICE_IDS := {
	"SHARED-03-EAGLE-SORROW-SEQUENCE": "SAVE_THE_DRAGON",
	"SHARED-05-GAOJIAZHUANG-SEQUENCE": "OFFER_REDEMPTION",
	"SHARED-07-FLOWING-SANDS-SEQUENCE": "ACCEPT_WUJING",
	"SHARED-08-PARTY-FULL-SEQUENCE": "SWEAR_TOGETHER",
}

const EXPECTED_BATTLES := {
	"SHARED-03-EAGLE-SORROW-SEQUENCE": "SHARED_EAGLE_SORROW",
	"SHARED-05-GAOJIAZHUANG-SEQUENCE": "SHARED_GAOJIAZHUANG",
	"SHARED-07-FLOWING-SANDS-SEQUENCE": "SHARED_FLOWING_SANDS",
}

static func run_all() -> Dictionary:
	var completed_sequences := 0
	var battle_handoffs := 0
	var world_moves := 0

	for sequence_id in SHARED_SEQUENCE_IDS:
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null)
		assert(not definition.is_empty())
		assert(definition.validate().get("valid", false))

		var manager := NarrativeManager.new()
		assert(manager.start_new_game("TANG"))
		manager.encounter_character("WUKONG")

		var runner := EventRunner.new(definition, manager, "SHARED")
		var action := runner.start()
		assert(not action.is_empty())
		assert(not runner.has_error())

		var guard := 0
		while not runner.is_finished():
			guard += 1
			assert(guard < 20)
			assert(not action.is_empty())

			var kind := str(action.get("kind", ""))
			match kind:
				EventRunner.DIALOGUE:
					action = runner.complete_action()
				EventRunner.WAIT:
					var seconds := float(action.get("seconds", -1.0))
					assert(seconds >= 0.0)
					action = runner.complete_action()
				EventRunner.MOVE:
					action = runner.complete_action()
					assert("BLACK_WIND_NORTH_PATH" in manager.state.get_world_state().get("visited_nodes", []))
					world_moves += 1
				EventRunner.CHOICE:
					assert(CHOICE_IDS.has(sequence_id))
					action = runner.submit_choice(str(CHOICE_IDS[sequence_id]))
				EventRunner.BATTLE:
					assert(EXPECTED_BATTLES.has(sequence_id))
					assert(str(action.get("handoff", {}).get("encounter_id", "")) == str(EXPECTED_BATTLES[sequence_id]))
					var saved := runner.to_dict()
					var resumed := EventRunner.new(definition, manager, "SHARED")
					assert(resumed.restore(saved))
					assert(resumed.get_action().get("kind", "") == EventRunner.BATTLE)
					action = resumed.resolve_battle(true)
					assert(not action.is_empty())
					runner = resumed
					battle_handoffs += 1
				EventRunner.END:
					assert(runner.is_finished())
					break
				_:
					assert(false)

			assert(not runner.has_error())

		assert(runner.is_finished())
		completed_sequences += 1

	assert(completed_sequences == SHARED_SEQUENCE_IDS.size())
	assert(battle_handoffs == 3)
	assert(world_moves == 1)
	return {
		"passed": true,
		"executed_sequences": completed_sequences,
		"expected_sequences": SHARED_SEQUENCE_IDS.size(),
		"battle_handoffs_verified": battle_handoffs,
		"world_moves_verified": world_moves,
	}
