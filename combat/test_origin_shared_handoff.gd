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
			assert(str(recruited_id) in manager.state.recruited_characters, "%s missing recruited %s" % [character, str(recruited_id)])

		var route := StartRouteCatalog.get_route(character)
		assert(str(route.get("handoff_shared_chapter")) == manager.state.current_shared_chapter, "%s catalog handoff should match runtime" % character)

	return {
		"passed": true,
		"routes_verified": CASES.size(),
		"origin_to_shared_handoffs_verified": CASES.size(),
		"timeline_handoffs_verified": CASES.size(),
		"recruitment_rosters_verified": CASES.size(),
	}
