extends RefCounted

## Regression coverage for all five Origin Route -> Shared Journey handoffs.
const CASES := [
	{"character":"WUKONG", "shared":"SHARED-01-FIVE-ELEMENTS", "milestone":"WUKONG_RECRUITED", "timeline":100, "roster":["TANG", "WUKONG"]},
	{"character":"TANG", "shared":"SHARED-01-FIVE-ELEMENTS", "milestone":"WUKONG_RECRUITED", "timeline":100, "roster":["TANG", "WUKONG"]},
	{"character":"LONGMA", "shared":"SHARED-03-EAGLE-SORROW", "milestone":"BAI_LONGMA_RECRUITED", "timeline":110, "roster":["TANG", "WUKONG", "LONGMA"]},
	{"character":"BAJIE", "shared":"SHARED-05-GAOJIAZHUANG", "milestone":"ZHU_BAJIE_RECRUITED", "timeline":130, "roster":["TANG", "WUKONG", "LONGMA", "BAJIE"]},
	{"character":"WUJING", "shared":"SHARED-07-FLOWING-SANDS", "milestone":"SHA_WUJING_RECRUITED", "timeline":150, "roster":["TANG", "WUKONG", "LONGMA", "BAJIE", "WUJING"]},
]

static func run_all() -> Dictionary:
	for case_variant in CASES:
		var case_data: Dictionary = case_variant
		var character := str(case_data["character"])
		var manager := NarrativeManager.new()
		assert(manager.start_new_game(character), "%s route should start" % character)

		var guard := 0
		while not manager.origin_routes.is_complete(manager, character):
			guard += 1
			assert(guard < 64, "%s origin should finish within chapter guard" % character)
			var completed := manager.complete_origin_chapter(character)
			assert(not completed.is_empty(), "%s origin chapter should complete" % character)

		assert(manager.get_origin_status(character)["complete"], "%s origin status should be complete" % character)
		assert(manager.handoff_origin_to_shared(character), "%s should hand off to shared journey" % character)
		assert(manager.state.current_shared_chapter == str(case_data["shared"]), "%s shared chapter mismatch" % character)
		assert(manager.state.current_global_timeline == int(case_data["timeline"]), "%s handoff timeline mismatch" % character)
		assert(str(case_data["milestone"]) in manager.state.completed_milestones, "%s handoff milestone missing" % character)
		assert(manager.state.current_origin_route == "", "%s origin route should clear" % character)
		assert(manager.state.current_origin_chapter == "", "%s origin chapter should clear" % character)

		var expected_roster: Array = case_data["roster"]
		assert(manager.state.recruited_characters.size() == expected_roster.size(), "%s roster size mismatch" % character)
		for recruited_id in expected_roster:
			var recruited_id_string := str(recruited_id)
			assert(recruited_id_string in manager.state.recruited_characters, "%s missing recruited %s" % [character, recruited_id_string])
			var recruitment_milestone := ""
			match recruited_id_string:
				"WUKONG": recruitment_milestone = "WUKONG_RECRUITED"
				"LONGMA": recruitment_milestone = "BAI_LONGMA_RECRUITED"
				"BAJIE": recruitment_milestone = "ZHU_BAJIE_RECRUITED"
				"WUJING": recruitment_milestone = "SHA_WUJING_RECRUITED"
			if not recruitment_milestone.is_empty():
				assert(recruitment_milestone in manager.state.completed_milestones, "%s should restore roster milestone %s" % [character, recruitment_milestone])

		var world_map := WorldMapManager.new()
		match character:
			"LONGMA":
				assert(world_map.can_visit(manager, "EAGLE_SORROW"), "Longma start should satisfy the Wukong milestone needed at Eagle Sorrow")
			"BAJIE":
				manager.state.add_world_node_visit("GAOJIAZHUANG")
				assert(world_map.can_visit(manager, "BLACK_WIND_NORTH_PATH"), "Bajie start should satisfy the prior Wukong gate and reach the Yellow Wind path")
			"WUJING":
				manager.state.add_world_node_visit("FLOWING_SANDS")
				assert(world_map.can_visit(manager, "GAOJIAZHUANG"), "Wujing start should retain the Longma milestone required to revisit Gaojiazhuang")

		var route := StartRouteCatalog.get_route(character)
		assert(str(route.get("handoff_shared_chapter")) == manager.state.current_shared_chapter, "%s catalog handoff should match runtime" % character)

		var shared_chapters := SharedJourneyManager.get_all_chapters()
		var current_index := -1
		for i in range(shared_chapters.size()):
			if str(shared_chapters[i].get("id", "")) == manager.state.current_shared_chapter:
				current_index = i
				break
		assert(current_index >= 0, "%s handoff should point to a registered Shared chapter" % character)
		for i in range(current_index):
			var historical_id := str(shared_chapters[i].get("id", ""))
			assert(historical_id in manager.state.completed_shared_chapters, "%s should reconcile prior Shared chapter %s" % [character, historical_id])
			assert(historical_id in manager.state.completed_chapters, "%s should retain prior chapter history %s" % [character, historical_id])
			assert(historical_id in manager.state.completed_milestones, "%s should record prior chronology milestone %s" % [character, historical_id])
			var historical := ChapterDefinition.new(shared_chapters[i])
			if historical.is_combat():
				assert("SHARED_BATTLE_%s" % historical.get_encounter_id() in manager.state.completed_milestones, "%s should retain prior battle fact %s" % [character, historical.get_encounter_id()])
				var legacy_target_id := historical.get_legacy_boss_target_id()
				if not legacy_target_id.is_empty():
					assert(legacy_target_id in manager.state.get_journey_log().get("defeated_targets", []), "%s should retain prior boss journal %s" % [character, legacy_target_id])
			for effect_variant in historical.get_world_effects():
				var effect_id := str(effect_variant)
				assert(effect_id in manager.state.completed_milestones, "%s should retain prior world milestone %s" % [character, effect_id])
				assert(effect_id in manager.state.get_journey_log().get("active_world_effects", []), "%s should activate prior world effect %s" % [character, effect_id])
		assert(manager.state.current_shared_chapter not in manager.state.completed_shared_chapters, "%s current Shared chapter must not be pre-completed" % character)
		assert(SharedJourneyManager.can_enter(manager.state.current_shared_chapter, manager.state), "%s should be able to enter the first Shared chapter after handoff" % character)

		var current_definition := SharedJourneyManager.get_definition(manager.state.current_shared_chapter)
		if current_definition.is_combat():
			manager.state.record_milestone("SHARED_BATTLE_%s" % current_definition.get_encounter_id(), current_definition.get_timeline())
			var roster_before := manager.state.recruited_characters.duplicate()
			assert(SharedJourneyManager.complete(current_definition.get_id(), manager, false), "%s Shared chapter should complete when its start character is already recruited" % character)
			assert(manager.state.recruited_characters == roster_before, "%s repeated recruitment must not duplicate or change the party roster" % character)
			for recruitment_variant in current_definition.get_recruitments():
				var recruitment: Dictionary = recruitment_variant
				for memory_variant in recruitment.get("memories", []):
					var memory_id := str(memory_variant)
					assert(memory_id in manager.state.available_memory_chapters or memory_id in manager.state.played_memory_chapters, "%s repeated recruitment should still unlock memory %s" % [character, memory_id])
			assert(manager.state.current_shared_chapter == current_definition.get_next_id(), "%s should advance after its Shared recruitment chapter" % character)

	return {
		"passed": true,
		"routes_verified": CASES.size(),
		"origin_to_shared_handoffs_verified": CASES.size(),
		"timeline_handoffs_verified": CASES.size(),
		"recruitment_rosters_verified": CASES.size(),
	}
