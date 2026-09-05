extends RefCounted

## Regression coverage for the complete Wujing Origin Route.
const CHAPTER_IDS := ["WUJING-01", "WUJING-02", "WUJING-03", "WUJING-04", "WUJING-05", "WUJING-06", "WUJING-07", "WUJING-08"]
const CHOICE_IDS := {"WUJING-02": "ACCEPT_FAULT", "WUJING-06": "ATONE"}

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("WUJING"), "Wujing route should start")
	var encounter_manager := EncounterManager.new()
	var choices_verified := 0
	var battles_verified := 0

	for chapter_id in CHAPTER_IDS:
		var current := manager.origin_routes.get_current_chapter(manager, "WUJING")
		assert(str(current.get("id", "")) == chapter_id, "%s should be current before execution" % chapter_id)
		var sequence_id := "%s-SEQUENCE" % chapter_id
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, "%s sequence should load" % sequence_id)
		assert(EventSequenceValidator.validate(definition).get("valid", false), "%s sequence should validate" % sequence_id)

		var runner := EventRunner.new(definition, manager, "ORIGIN")
		var action: Dictionary = runner.start()
		assert(not action.is_empty(), "%s should start" % chapter_id)
		var guard := 0
		var has_battle := false
		while true:
			guard += 1
			assert(guard < 16, "%s exceeded progression guard" % chapter_id)
			match str(action.get("kind", "")):
				EventRunner.DIALOGUE, EventRunner.WAIT, EventRunner.MOVE:
					action = runner.complete_action()
				EventRunner.CHOICE:
					assert(CHOICE_IDS.has(chapter_id), "%s choice must be declared" % chapter_id)
					action = runner.submit_choice(str(CHOICE_IDS[chapter_id]))
					choices_verified += 1
				EventRunner.BATTLE:
					has_battle = true
					var handoff: Dictionary = action.get("handoff", {})
					var encounter_id := str(handoff.get("encounter_id", ""))
					assert(encounter_id != "", "%s battle needs encounter id" % chapter_id)
					assert(str(handoff.get("source_chapter_id", "")) == chapter_id, "%s battle source chapter must match" % chapter_id)
					var encounter_definition: Dictionary = encounter_manager.get_definition(encounter_id)
					assert(not encounter_definition.is_empty(), "%s encounter definition should load" % encounter_id)
					var rewards: Array = encounter_definition.get("rewards", []).duplicate(true)
					var effects: Array = encounter_definition.get("world_effects", []).duplicate(true)
					assert(not rewards.is_empty(), "%s encounter should have production rewards" % encounter_id)
					var resolved := BattleResolutionService.resolve_narrative_victory(
						manager,
						"origin",
						encounter_id,
						str(handoff.get("source_stage_id", "")),
						chapter_id,
						str(handoff.get("source_route_id", "")),
						encounter_id,
						rewards,
						effects,
						encounter_manager
					)
					assert(not resolved.is_empty(), "%s battle should advance origin chapter" % chapter_id)
					action = runner.resolve_battle(true)
					battles_verified += 1
				EventRunner.END:
					assert(runner.is_finished(), "%s should finish" % chapter_id)
					break
				_:
					assert(false, "%s returned unsupported action %s" % [chapter_id, str(action.get("kind", ""))])

		if not has_battle:
			var completed := manager.complete_origin_chapter("WUJING")
			assert(str(completed.get("id", "")) == chapter_id, "%s END should complete the current non-battle origin chapter" % chapter_id)

		assert(str(manager.state.completed_chapters[manager.state.completed_chapters.size() - 1]) == chapter_id, "%s should be the latest completed chapter" % chapter_id)

		if chapter_id == "WUJING-03":
			assert(manager.save(), "Wujing progress should save after WUJING-03")
			var loaded := NarrativeManager.new()
			assert(loaded.load(), "Wujing progress should reload")
			assert(loaded.state.starting_character == "WUJING", "reload should preserve Wujing route")
			assert(loaded.state.current_origin_chapter == "WUJING-04", "reload should resume at WUJING-04")
			manager = loaded

	assert(choices_verified == 2, "Wujing should verify two choices")
	assert(battles_verified == 2, "Wujing should verify two battles")
	assert(manager.origin_routes.is_complete(manager, "WUJING"), "Wujing route should complete")
	assert(manager.state.route_progress.get("WUJING", "") == NarrativeState.ROUTE_COMPLETE, "Wujing route should be marked complete")
	assert(manager.state.current_origin_chapter == "", "completed Wujing route should clear active origin chapter")
	assert(manager.state.origin_choices.get("WUJING-02", "") == "ACCEPT_FAULT", "WUJING-02 choice should persist")
	assert(manager.state.origin_choices.get("WUJING-06", "") == "ATONE", "WUJING-06 choice should persist")

	return {
		"passed": true,
		"chapters_verified": CHAPTER_IDS.size(),
		"choices_verified": choices_verified,
		"battles_verified": battles_verified,
		"save_reload_checkpoint": "WUJING-03",
		"route_complete": true,
	}
