extends SceneTree

## End-to-end service regression: shared battle victory -> reward -> recruitment -> camp.
func _initialize() -> void:
	var encounter_manager := EncounterManager.new()
	var narrative := NarrativeManager.new()
	_assert(narrative.start_new_game("WUKONG"), "Wukong route should start")
	narrative.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
	_assert(narrative.encounter_character("TANG"), "Tang should join")
	_assert(narrative.encounter_character("WUKONG"), "Wukong should be present")
	_assert(narrative.set_shared_chapter("SHARED-03-EAGLE-SORROW"), "shared chapter should be set")
	var events := SharedEventManager.new()
	_assert(events.apply_choice(narrative, "LONGMA_ENCOUNTER", "SAVE_THE_DRAGON"), "Longma choice should resolve")

	var resolved := BattleResolutionService.resolve_narrative_victory(
		narrative, "shared", "SHARED_EAGLE_SORROW", "", "SHARED-03-EAGLE-SORROW", "SHARED_JOURNEY",
		"鹰愁涧·白龙阻路", ["COIN_LOW"], [], encounter_manager
	)
	_assert(not resolved.is_empty(), "shared battle should resolve")
	_assert(int(narrative.state.get_inventory().get("currencies", {}).get("COIN", 0)) == 100, "battle reward should persist")
	_assert("LONGMA" in narrative.state.recruited_characters, "victory should recruit Longma")
	_assert(narrative.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "victory should advance shared chapter")

	narrative.state.set_party_formation({
		"roster": ["TANG", "WUKONG", "LONGMA"],
		"front_row": ["TANG", "WUKONG"],
		"back_row": ["LONGMA"],
	})
	var timeline_before_camp: int = narrative.state.current_global_timeline
	var camp_result: Dictionary = CampService.rest(narrative)
	_assert(bool(camp_result.get("ok", false)), "camp rest should succeed")
	_assert(int(camp_result.get("members_present", -1)) == 3, "camp should see the post-recruitment party")
	_assert(narrative.state.current_global_timeline == timeline_before_camp, "camp should not advance chronology")
	var entries: Array = narrative.state.get_journey_log().get("entries", [])
	_assert(not entries.is_empty(), "journey log should contain the camp entry")
	var last_entry: Dictionary = entries.back()
	_assert(str(last_entry.get("type", "")) == "CAMP", "last journey entry should be camp")
	_assert(int(last_entry.get("party_present", -1)) == 3, "camp log should record the active party")

	print("ALL BATTLE PARTY CAMP LOOP TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
