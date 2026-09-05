extends RefCounted

## Regression coverage for real Tang Origin chapter progression and save/load.
const CHAPTER_IDS := [
	"TANG-01", "TANG-02", "TANG-03", "TANG-04",
	"TANG-05", "TANG-06", "TANG-07", "TANG-08",
]

const CHOICE_IDS := {
	"TANG-04": "FOLLOW_VOW",
	"TANG-07": "KEEP_WALKING",
}

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("TANG"), "Tang route should start")
	var encounter_manager := EncounterManager.new()
	var last_completed := ""

	for chapter_id in CHAPTER_IDS:
		var current: Dictionary = manager.origin_routes.get_current_chapter(manager, "TANG")
		assert(str(current.get("id", "")) == chapter_id, "%s should be the current chapter before execution" % chapter_id)

		var sequence_id := "%s-SEQUENCE" % chapter_id
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, "%s sequence should load" % sequence_id)
		assert(definition.validate().get("valid", false), "%s sequence should validate" % sequence_id)

		var has_battle := false
		for node in definition.get_nodes():
			if str(node.get("type", node.get("kind", ""))).to_lower() == EventRunner.BATTLE:
				has_battle = true
				break

		var runner := EventRunner.new(definition, manager, "ORIGIN")
		var action: Dictionary = runner.start()
		assert(not action.is_empty(), "%s should start" % chapter_id)

		var guard := 0
		while true:
			guard += 1
			assert(guard < 16, "%s exceeded progression guard" % chapter_id)
			var kind := str(action.get("kind", ""))
			match kind:
				EventRunner.DIALOGUE, EventRunner.WAIT, EventRunner.MOVE:
					action = runner.complete_action()
				EventRunner.CHOICE:
					assert(CHOICE_IDS.has(chapter_id), "%s choice must have an explicit regression value" % chapter_id)
					action = runner.submit_choice(str(CHOICE_IDS[chapter_id]))
				EventRunner.BATTLE:
					var handoff: Dictionary = action.get("handoff", {})
					var encounter_id := str(handoff.get("encounter_id", ""))
					assert(encounter_id != "", "%s battle handoff needs encounter id" % chapter_id)
					assert(str(handoff.get("source_chapter_id", "")) == chapter_id, "%s battle source chapter must match current chapter" % chapter_id)
					var encounter_definition: Dictionary = encounter_manager.get_definition(encounter_id)
					assert(not encounter_definition.is_empty(), "%s encounter definition should load" % encounter_id)
					var rewards: Array = encounter_definition.get("rewards", []).duplicate(true)
					var effects: Array = encounter_definition.get("world_effects", []).duplicate(true)
					assert(not rewards.is_empty(), "%s battle should have production rewards" % encounter_id)
					var resolved := BattleResolutionService.resolve_narrative_victory(
						manager,
						"origin",
						encounter_id,
						str(handoff.get("source_stage_id", "")),
						chapter_id,
						str(handoff.get("source_route_id", "")),
						str(encounter_definition.get("name", encounter_id)),
						rewards,
						effects,
						encounter_manager
					)
					assert(not resolved.is_empty(), "%s battle victory should atomically advance the origin chapter" % chapter_id)
					action = runner.resolve_battle(true)
				EventRunner.END:
					assert(runner.is_finished(), "%s runner should finish" % chapter_id)
					break
				_:
					assert(false, "%s returned unsupported action %s" % [chapter_id, kind])

		if not has_battle:
			var completed := manager.complete_origin_chapter("TANG")
			assert(str(completed.get("id", "")) == chapter_id, "%s END should complete the current non-battle origin chapter" % chapter_id)

		assert(str(manager.state.completed_chapters[manager.state.completed_chapters.size() - 1]) == chapter_id, "%s should be the latest completed origin chapter" % chapter_id)
		last_completed = chapter_id

		if chapter_id == "TANG-06":
			assert(manager.save(), "TANG-06 progress should save")
			var loaded := NarrativeManager.new()
			assert(loaded.load(), "saved TANG-06 progress should reload")
			assert(loaded.state.starting_character == "TANG", "reload should preserve starting character")
			assert(loaded.state.current_origin_chapter == "TANG-07", "reload should resume at TANG-07")
			manager = loaded

	assert(last_completed == "TANG-08", "entire Tang route should reach TANG-08")
	assert(manager.origin_routes.is_complete(manager, "TANG"), "Tang origin route should be complete")
	assert(manager.state.route_progress.get("TANG", "") == NarrativeState.ROUTE_COMPLETE, "Tang route should be marked complete")
	assert(manager.state.current_origin_chapter == "", "completed Tang route should clear active origin chapter")
	assert("TANG_APPROACHES_FIVE_ELEMENTS" in manager.state.journey_log.get("active_world_effects", []), "Five Elements approach world effect should persist")
	assert(manager.state.origin_choices.get("TANG-04", "") == "FOLLOW_VOW", "TANG-04 choice should persist")
	assert(manager.state.origin_choices.get("TANG-07", "") == "KEEP_WALKING", "TANG-07 choice should persist")

	return {
		"passed": true,
		"chapters_verified": CHAPTER_IDS.size(),
		"save_reload_checkpoint": "TANG-06",
		"route_complete": true,
	}
