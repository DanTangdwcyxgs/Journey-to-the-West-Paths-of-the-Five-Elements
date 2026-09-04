extends SceneTree

## Regression coverage for the first three recruit-node shared battles.
func _initialize() -> void:
	var encounter_manager := EncounterManager.new()
	for encounter_id in ["SHARED_EAGLE_SORROW", "SHARED_GAOJIAZHUANG", "SHARED_FLOWING_SANDS"]:
		var definition := encounter_manager.get_definition(encounter_id)
		_assert(not definition.is_empty(), "%s definition should load" % encounter_id)
		var enemies := encounter_manager.build_enemies(encounter_id)
		_assert(enemies.size() == 2, "%s should build two enemies" % encounter_id)
		for enemy in enemies:
			_assert(not enemy.weaknesses.is_empty(), "%s should expose weakness data" % enemy.id)

	var narrative := NarrativeManager.new()
	_assert(narrative.start_new_game("WUKONG"), "Wukong route should start")
	narrative.encounter_character("TANG")
	narrative.encounter_character("WUKONG")
	narrative.set_shared_chapter("SHARED-03-EAGLE-SORROW")
	_assert(SharedJourneyManager.can_enter("SHARED-03-EAGLE-SORROW", narrative.state), "Eagle Sorrow should be enterable after Wukong recruitment")
	var shared_events := SharedEventManager.new()
	_assert(shared_events.apply_choice(narrative, "LONGMA_ENCOUNTER", "SAVE_THE_DRAGON"), "Longma event choice should resolve")
	_assert(BountyEncounterState.start_shared_encounter("SHARED_EAGLE_SORROW", "SHARED-03-EAGLE-SORROW"), "shared encounter handoff should succeed")
	var record := BountyEncounterState.get_active_record()
	_assert(str(record.get("encounter_type", "")) == "shared", "shared handoff must be typed as shared")
	_assert(str(record.get("source_chapter_id", "")) == "SHARED-03-EAGLE-SORROW", "shared handoff should retain canonical chapter id")
	BountyEncounterState.clear()

	var completion := SharedJourneyManager.complete("SHARED-03-EAGLE-SORROW", narrative)
	_assert(completion, "shared chapter should complete after a resolved battle")
	_assert("LONGMA" in narrative.state.recruited_characters, "Longma should be recruited at Eagle Sorrow")
	_assert(narrative.state.current_global_timeline == 110, "shared battle completion should preserve canonical timeline")
	_assert(narrative.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "shared battle should advance to the next chapter")
	_assert("LONGMA-01" in narrative.state.available_memory_chapters, "Longma memories should unlock immediately on recruitment")

	print("ALL SHARED JOURNEY BATTLE TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
