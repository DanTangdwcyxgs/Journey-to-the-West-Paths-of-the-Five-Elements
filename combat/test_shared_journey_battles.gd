extends SceneTree

## Regression coverage for shared recruit-node battles, rewards, and five-person convergence.
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
	narrative.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
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

	_assert(not SharedJourneyManager.complete("SHARED-03-EAGLE-SORROW", narrative), "recruit chapter must not complete without a resolved battle")
	narrative.state.record_milestone("SHARED_BATTLE_SHARED_EAGLE_SORROW", narrative.state.current_global_timeline)
	_assert(SharedJourneyManager.complete("SHARED-03-EAGLE-SORROW", narrative), "Eagle Sorrow should complete after battle resolution")
	_assert("LONGMA" in narrative.state.recruited_characters, "Longma should be recruited at Eagle Sorrow")
	_assert(narrative.state.current_global_timeline == 110, "Eagle Sorrow should preserve canonical timeline")
	_assert(narrative.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "Eagle Sorrow should advance to the next chapter")
	_assert("LONGMA-01" in narrative.state.available_memory_chapters, "Longma memories should unlock immediately on recruitment")

	_assert(SharedJourneyManager.complete("SHARED-04-EARLY-DEMON-TALES", narrative), "early demon chapter should advance")
	_assert(narrative.state.get_inventory().get("items", {}).get("HERB", 0) == 1, "non-combat chapter reward should grant one HERB")
	_assert(narrative.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "Gaojiazhuang should follow the early demon chapter")
	_assert(shared_events.apply_choice(narrative, "BAJIE_ENCOUNTER", "OFFER_REDEMPTION"), "Bajie event choice should resolve")
	narrative.state.record_milestone("SHARED_BATTLE_SHARED_GAOJIAZHUANG", narrative.state.current_global_timeline)
	_assert(SharedJourneyManager.complete("SHARED-05-GAOJIAZHUANG", narrative), "Gaojiazhuang should complete after battle resolution")
	_assert("BAJIE" in narrative.state.recruited_characters, "Bajie should be recruited at Gaojiazhuang")
	_assert("BAJIE-01" in narrative.state.available_memory_chapters, "Bajie memories should unlock immediately on recruitment")
	_assert(narrative.state.current_shared_chapter == "SHARED-06-FOUR-PERSON-JOURNEY", "Gaojiazhuang should advance to four-person journey")

	_assert(SharedJourneyManager.complete("SHARED-06-FOUR-PERSON-JOURNEY", narrative), "four-person journey should advance")
	_assert(narrative.state.get_inventory().get("items", {}).get("HERB", 0) == 2, "second non-combat chapter reward should grant another HERB")
	_assert(shared_events.apply_choice(narrative, "WUJING_ENCOUNTER", "ACCEPT_WUJING"), "Wujing event choice should resolve")
	narrative.state.record_milestone("SHARED_BATTLE_SHARED_FLOWING_SANDS", narrative.state.current_global_timeline)
	_assert(SharedJourneyManager.complete("SHARED-07-FLOWING-SANDS", narrative), "Flowing Sands should complete after battle resolution")
	_assert("WUJING" in narrative.state.recruited_characters, "Wujing should be recruited at Flowing Sands")
	_assert("WUJING-01" in narrative.state.available_memory_chapters, "Wujing memories should unlock immediately on recruitment")
	_assert(narrative.state.current_shared_chapter == "SHARED-08-PARTY-FULL", "Flowing Sands should advance to party convergence")

	_assert(SharedJourneyManager.complete("SHARED-08-PARTY-FULL", narrative), "party convergence chapter should complete")
	_assert(narrative.state.get_inventory().get("items", {}).get("HERB", 0) == 3, "party convergence reward should grant one HERB")
	_assert(narrative.state.recruited_characters.size() == NarrativeState.CHARACTER_IDS.size(), "party convergence should contain all five canonical characters")
	_assert("PARTY_FULL" in narrative.state.journey_log.get("active_world_effects", []), "party convergence should activate PARTY_FULL")
	var formation := narrative.state.get_party_formation()
	_assert(formation.get("roster", []) == ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA"], "full party formation roster should be persisted")
	_assert(formation.get("front_row", []) == ["TANG", "WUKONG", "LONGMA"], "full party should default to three front-row members")
	_assert(formation.get("back_row", []) == ["BAJIE", "WUJING"], "full party should default to two back-row members")
	_assert(narrative.state.current_shared_chapter == "SHARED-09-FULL-PILGRIMAGE", "party convergence should advance to full pilgrimage")
	_assert(SharedJourneyManager.complete("SHARED-09-FULL-PILGRIMAGE", narrative), "full pilgrimage opening should complete")
	_assert(narrative.state.get_inventory().get("currencies", {}).get("COIN", 0) == 300, "full pilgrimage opening should grant COIN_MEDIUM once")
	_assert("FULL_PILGRIMAGE_BEGINS" in narrative.state.journey_log.get("active_world_effects", []), "full pilgrimage milestone should be active")
	_assert(narrative.state.current_shared_chapter == "SHARED-09-FULL-PILGRIMAGE", "final shared chapter should remain stable")

	print("ALL SHARED JOURNEY BATTLE TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
