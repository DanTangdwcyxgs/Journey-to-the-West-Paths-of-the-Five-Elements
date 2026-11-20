extends SceneTree

func _initialize() -> void:
	var route_ids := [
		"WUKONG_ORIGIN",
		"TANG_ORIGIN",
		"LONGMA_ORIGIN",
		"BAJIE_ORIGIN",
		"WUJING_ORIGIN"
	]
	for route_id in route_ids:
		var first := BattleTutorial.first_battle_for_route(route_id)
		_assert(not first.is_empty(), "%s should expose a data-driven first encounter" % route_id)
		_assert(not str(first.get("chapter_id", "")).is_empty(), "%s first encounter should have a chapter ID" % route_id)
		_assert(not str(first.get("encounter_id", "")).is_empty(), "%s first encounter should have an encounter ID" % route_id)
		_assert(BattleTutorial.should_show_for("origin", route_id, str(first.get("chapter_id", ""))), "%s should show the tutorial at its first Origin battle" % route_id)
		_assert(not BattleTutorial.should_show_for("origin", route_id, "NOT_THE_FIRST_BATTLE"), "%s should not auto-show it in a later chapter" % route_id)
		_assert(not BattleTutorial.should_show_for("shared", route_id, str(first.get("chapter_id", ""))), "Shared battles must not trigger the Origin tutorial")
		_assert(not BattleTutorial.should_show_for("bounty", route_id, str(first.get("chapter_id", ""))), "Optional bounties must not trigger the Origin tutorial")

	var character_ids := ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA"]
	for character_id in character_ids:
		var guide := BattleTutorial.guide_text_for_character(character_id)
		_assert(guide.contains("弱点") and guide.contains("Break"), "%s guide should explain weakness and Break" % character_id)
		_assert(guide.contains("BP") and guide.contains("Boost"), "%s guide should explain BP and Boost" % character_id)
		_assert(guide.contains("道具"), "%s guide should explain item targeting" % character_id)
		_assert(guide.length() > 180, "%s guide should contain a useful amount of instruction" % character_id)

	_assert(BattleTutorial.normalize_character_id("tangseng") == "TANG", "Tang aliases should normalize to the route key")
	_assert(BattleTutorial.normalize_character_id("sha_wujing") == "WUJING", "Wujing aliases should normalize to the route key")

	var battle_ui := BattleUI.new()
	battle_ui.starting_character_id = "WUKONG"
	battle_ui._build_ui()
	_assert(battle_ui.tutorial_button != null, "BattleUI should expose a manual tutorial button")
	_assert(battle_ui.tutorial_dialog != null, "BattleUI should own a tutorial dialog")
	_assert(battle_ui.tutorial_dialog.dialog_text.contains("孙悟空"), "BattleUI should present the selected character's guide")
	battle_ui.free()

	print("ALL BATTLE TUTORIAL TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
