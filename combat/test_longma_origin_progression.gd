extends RefCounted

## Regression coverage for the complete Longma Origin Route.
const CHAPTER_IDS := ["LONGMA-01", "LONGMA-02", "LONGMA-03", "LONGMA-04", "LONGMA-05", "LONGMA-06"]
const CHOICE_IDS := {"LONGMA-02": "ACCEPT_PUNISHMENT", "LONGMA-04": "SERVE_WILLINGLY"}

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("LONGMA"), "Longma route should start")
	var encounter_manager := EncounterManager.new()
	var choices_verified := 0
	var battles_verified := 0

	for chapter_id in CHAPTER_IDS:
		var current := manager.origin_routes.get_current_chapter(manager, "LONGMA")
		assert(str(current.get("id", "")) == chapter_id, "%s should be current before execution" % chapter_id)
		var sequence_id := "%s-SEQUENCE" % chapter_id
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, "%s sequence should load" % sequence_id)
		assert(definition.validate().get("valid", false), "%s sequence should validate" % sequence_id)

		var runner := EventRunner.new(definition, manager, "ORIGIN")
		var action := runner.start()
		assert(not action.is_empty(), "%s should start" % chapter_id)
		var guard := 0
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
					assert(false, "%s returned unsupported action" % chapter_id)

		assert(str(manager.state.completed_chapters[manager.state.completed_chapters.size() - 1]) == chapter_id, "%s should be the latest completed chapter" % chapter_id)

		if chapter_id == "LONGMA-02":
			assert(manager.save(), "Longma progress should save after LONGMA-02")
			var loaded := NarrativeManager.new()
			assert(loaded.load(), "Longma progress should reload")
			assert(loaded.state.starting_character == "LONGMA", "reload should preserve Longma route")
			assert(loaded.state.current_origin_chapter == "LONGMA-03", "reload should resume at LONGMA-03")
			manager = loaded

	assert(choices_verified == 2, "Longma should verify two choices")
	assert(battles_verified == 2, "Longma should verify two battles")
	assert(manager.origin_routes.is_complete(manager, "LONGMA"), "Longma route should complete")
	assert(manager.state.route_progress.get("LONGMA", "") == NarrativeState.ROUTE_COMPLETE, "Longma route should be marked complete")
	assert(manager.state.current_origin_chapter == "", "completed Longma route should clear active origin chapter")
	assert(manager.state.origin_choices.get("LONGMA-02", "") == "ACCEPT_PUNISHMENT", "LONGMA-02 choice should persist")
	assert(manager.state.origin_choices.get("LONGMA-04", "") == "SERVE_WILLINGLY", "LONGMA-04 choice should persist")
	assert("LONGMA_GUARDS_PILGRIM" in manager.state.journey_log.get("active_world_effects", []), "Longma protection effect should persist")

	return {
		"passed": true,
		"chapters_verified": CHAPTER_IDS.size(),
		"choices_verified": choices_verified,
		"battles_verified": battles_verified,
		"save_reload_checkpoint": "LONGMA-02",
		"route_complete": true,
	}
