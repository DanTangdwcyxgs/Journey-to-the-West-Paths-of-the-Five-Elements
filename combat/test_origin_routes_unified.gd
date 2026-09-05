extends RefCounted

## Unified quality gate for all five Origin Route EventSequence catalogs.
const ROUTES := {
	"WUKONG": {
		"route_id": "WUKONG_ORIGIN",
		"sequence_ids": ["WUK-01-SEQUENCE", "WUK-02-SEQUENCE", "WUK-03-SEQUENCE", "WUK-04-SEQUENCE", "WUK-05-SEQUENCE", "WUK-06-SEQUENCE", "WUK-07-SEQUENCE", "WUK-08-SEQUENCE", "WUK-09-SEQUENCE", "WUK-10-SEQUENCE", "WUK-11-SEQUENCE", "WUK-12-SEQUENCE", "WUK-13-SEQUENCE", "WUK-14-SEQUENCE", "WUK-15-SEQUENCE"],
		"choices": {"WUK-03-SEQUENCE": "SEEK_FREEDOM", "WUK-08-SEQUENCE": "ACCEPT_TITLE", "WUK-13-SEQUENCE": "ENDURE"},
		"battles": {"WUK-02-SEQUENCE": "WUKONG_ORIGIN_WATER_CAVE", "WUK-06-SEQUENCE": "WUKONG_ORIGIN_DRAGON_PALACE", "WUK-11-SEQUENCE": "WUKONG_ORIGIN_HEAVENLY_TROOPS", "WUK-12-SEQUENCE": "WUKONG_ORIGIN_ERLANG_SHEN", "WUK-14-SEQUENCE": "WUKONG_ORIGIN_HEAVEN_PALACE"},
	},
	"TANG": {
		"route_id": "TANG_ORIGIN",
		"sequence_ids": ["TANG-01-SEQUENCE", "TANG-02-SEQUENCE", "TANG-03-SEQUENCE", "TANG-04-SEQUENCE", "TANG-05-SEQUENCE", "TANG-06-SEQUENCE", "TANG-07-SEQUENCE", "TANG-08-SEQUENCE"],
		"choices": {"TANG-04-SEQUENCE": "FOLLOW_VOW", "TANG-07-SEQUENCE": "KEEP_WALKING"},
		"battles": {"TANG-06-SEQUENCE": "TANG_ORIGIN_DOUBLE_RIDGE", "TANG-08-SEQUENCE": "TANG_ORIGIN_FIVE_ELEMENTS"},
	},
	"LONGMA": {
		"route_id": "LONGMA_ORIGIN",
		"sequence_ids": ["LONGMA-01-SEQUENCE", "LONGMA-02-SEQUENCE", "LONGMA-03-SEQUENCE", "LONGMA-04-SEQUENCE", "LONGMA-05-SEQUENCE", "LONGMA-06-SEQUENCE"],
		"choices": {"LONGMA-02-SEQUENCE": "ACCEPT_PUNISHMENT", "LONGMA-04-SEQUENCE": "SERVE_WILLINGLY"},
		"battles": {"LONGMA-02-SEQUENCE": "LONGMA_ORIGIN_SEA_CLIFF", "LONGMA-05-SEQUENCE": "LONGMA_ORIGIN_YINGCHOU"},
	},
	"BAJIE": {
		"route_id": "BAJIE_ORIGIN",
		"sequence_ids": ["BAJIE-01-SEQUENCE", "BAJIE-02-SEQUENCE", "BAJIE-03-SEQUENCE", "BAJIE-04-SEQUENCE", "BAJIE-05-SEQUENCE", "BAJIE-06-SEQUENCE", "BAJIE-07-SEQUENCE", "BAJIE-08-SEQUENCE", "BAJIE-09-SEQUENCE"],
		"choices": {"BAJIE-02-SEQUENCE": "HOLD_BACK", "BAJIE-06-SEQUENCE": "CHOOSE_HOME"},
		"battles": {"BAJIE-06-SEQUENCE": "BAJIE_ORIGIN_GAO_WILD", "BAJIE-08-SEQUENCE": "BAJIE_ORIGIN_WUKONG_DUEL"},
	},
	"WUJING": {
		"route_id": "WUJING_ORIGIN",
		"sequence_ids": ["WUJING-01-SEQUENCE", "WUJING-02-SEQUENCE", "WUJING-03-SEQUENCE", "WUJING-04-SEQUENCE", "WUJING-05-SEQUENCE", "WUJING-06-SEQUENCE", "WUJING-07-SEQUENCE", "WUJING-08-SEQUENCE"],
		"choices": {"WUJING-02-SEQUENCE": "ACCEPT_FAULT", "WUJING-06-SEQUENCE": "ATONE"},
		"battles": {"WUJING-03-SEQUENCE": "WUJING_ORIGIN_FLOWING_SANDS", "WUJING-07-SEQUENCE": "WUJING_ORIGIN_BODHISATTVA"},
	},
}

static func run_all() -> Dictionary:
	var route_count := 0
	var sequence_count := 0
	var choice_count := 0
	var battle_count := 0
	var origin_events := OriginEventManager.new()
	var encounter_manager := EncounterManager.new()

	for character in ROUTES.keys():
		var route: Dictionary = ROUTES[character]
		var route_id := str(route.get("route_id"))
		assert(route_id != "", "%s should declare route id" % character)
		var manager := NarrativeManager.new()
		assert(manager.start_new_game(character), "%s route should start" % character)
		assert(manager.state.starting_character == character, "%s starting character should remain isolated" % character)

		var sequence_ids: Array = route["sequence_ids"]
		var choices: Dictionary = route["choices"]
		var battles: Dictionary = route["battles"]
		for sequence_id_variant in sequence_ids:
			var sequence_id := str(sequence_id_variant)
			var expected_chapter := sequence_id.replace("-SEQUENCE", "")
			var definition := EventSequenceManager.get_definition(sequence_id)
			assert(definition != null, "%s should load" % sequence_id)
			var definition_dict: Dictionary = definition.to_dict()
			assert(str(definition_dict.get("namespace")) == "ORIGIN", "%s must be Origin namespace" % sequence_id)
			assert(str(definition_dict.get("chapter_id")) == expected_chapter, "%s chapter id must be exact" % sequence_id)
			var validation := EventSequenceValidator.validate(definition)
			assert(validation.get("valid"), "%s -> %s" % [sequence_id, str(validation)])

			var runner := EventRunner.new(definition, manager, "ORIGIN")
			var action: Dictionary = runner.start()
			assert(not action.is_empty(), "%s should start" % sequence_id)
			var guard := 0
			while true:
				guard += 1
				assert(guard < 32, "%s exceeded unified action guard" % sequence_id)
				match str(action.get("kind")):
					EventRunner.DIALOGUE, EventRunner.WAIT, EventRunner.MOVE:
						action = runner.complete_action()
					EventRunner.CHOICE:
						assert(choices.has(sequence_id), "%s choice must be declared in unified catalog" % sequence_id)
						var event_definition := origin_events.get_definition(expected_chapter)
						assert(not event_definition.is_empty(), "%s choice event %s must exist" % [sequence_id, expected_chapter])
						var expected_choice := str(choices[sequence_id])
						var found_choice := false
						var choice_variants: Array = event_definition.get_choices()
						for choice_variant in choice_variants:
							if str(choice_variant.get("id")) == expected_choice:
								found_choice = true
								break
						assert(found_choice, "%s choice %s must exist in %s" % [sequence_id, expected_choice, expected_chapter])
						action = runner.submit_choice(expected_choice)
						choice_count += 1
					EventRunner.BATTLE:
						assert(battles.has(sequence_id), "%s battle must be declared in unified catalog" % sequence_id)
						var handoff: Dictionary = action["handoff"]
						var encounter_id := str(handoff.get("encounter_id"))
						assert(encounter_id == str(battles[sequence_id]), "%s battle encounter mismatch" % sequence_id)
						assert(str(handoff.get("source_chapter_id")) == expected_chapter, "%s battle source chapter mismatch" % sequence_id)
						assert(str(handoff.get("source_route_id")) == route_id, "%s battle source route mismatch" % sequence_id)
						var encounter_definition: Dictionary = encounter_manager.get_definition(encounter_id)
						assert(not encounter_definition.is_empty(), "%s encounter must exist" % encounter_id)
						assert(str(encounter_definition.get("source")) == route_id, "%s encounter source must match route" % encounter_id)
						var snapshot := runner.to_dict()
						var restored := EventRunner.new(definition, manager, "ORIGIN")
						assert(restored.restore(snapshot), "%s battle snapshot must restore" % sequence_id)
						action = restored.resolve_battle(true)
						assert(not action.is_empty(), "%s battle should resume" % sequence_id)
						runner = restored
						battle_count += 1
					EventRunner.END:
						assert(runner.is_finished(), "%s END should finish" % sequence_id)
						break
					_:
						assert(false, "%s returned unsupported action %s" % [sequence_id, str(action.get("kind"))])

			assert(not runner.has_error(), "%s should not error" % sequence_id)
			sequence_count += 1

		assert(manager.state.starting_character == character, "%s route state must remain isolated after sequence execution" % character)
		route_count += 1

	assert(route_count == 5)
	assert(sequence_count == 46)
	assert(choice_count == 11)
	assert(battle_count == 13)

	return {
		"passed": true,
		"routes_verified": route_count,
		"sequences_verified": sequence_count,
		"choice_cross_references_verified": choice_count,
		"battle_cross_references_verified": battle_count,
		"route_isolation_verified": true,
	}
