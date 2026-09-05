extends SceneTree

## Regression coverage for the unified narrative battle commit boundary.
func _initialize() -> void:
	var encounter_manager := EncounterManager.new()
	var narrative := NarrativeManager.new()
	_assert(narrative.start_new_game("WUKONG"), "Wukong route should start")
	narrative.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
	narrative.encounter_character("TANG")
	narrative.encounter_character("WUKONG")
	narrative.set_shared_chapter("SHARED-03-EAGLE-SORROW")
	var events := SharedEventManager.new()
	_assert(events.apply_choice(narrative, "LONGMA_ENCOUNTER", "SAVE_THE_DRAGON"), "shared choice should resolve")

	var before := narrative.serialize().duplicate(true)
	var rejected := BattleResolutionService.resolve_narrative_victory(
		narrative, "shared", "SHARED_EAGLE_SORROW", "", "SHARED-03-EAGLE-SORROW", "WRONG_ROUTE",
		"鹰愁涧·白龙阻路", ["COIN_LOW"], [], encounter_manager
	)
	_assert(rejected.is_empty(), "invalid shared source must be rejected before mutation")
	_assert(narrative.serialize() == before, "invalid source must not mutate narrative state")

	var resolved := BattleResolutionService.resolve_narrative_victory(
		narrative, "shared", "SHARED_EAGLE_SORROW", "", "SHARED-03-EAGLE-SORROW", "SHARED_JOURNEY",
		"鹰愁涧·白龙阻路", ["COIN_LOW"], [], encounter_manager
	)
	_assert(not resolved.is_empty(), "valid shared resolution should succeed")
	_assert(narrative.state.get_inventory().get("currencies", {}).get("COIN", 0) == 100, "reward should be granted once")
	_assert("LONGMA" in narrative.state.recruited_characters, "shared resolution should recruit Longma")
	_assert(narrative.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "shared resolution should advance the chapter")
	_assert(narrative.state.current_global_timeline == 110, "shared resolution should preserve canonical timeline")

	var duplicate := BattleResolutionService.resolve_narrative_victory(
		narrative, "shared", "SHARED_EAGLE_SORROW", "", "SHARED-03-EAGLE-SORROW", "SHARED_JOURNEY",
		"鹰愁涧·白龙阻路", ["COIN_LOW"], [], encounter_manager
	)
	_assert(duplicate.is_empty(), "stale shared battle must be rejected")
	_assert(narrative.state.get_inventory().get("currencies", {}).get("COIN", 0) == 100, "stale battle must not duplicate reward")

	print("ALL BATTLE RESOLUTION SERVICE TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
