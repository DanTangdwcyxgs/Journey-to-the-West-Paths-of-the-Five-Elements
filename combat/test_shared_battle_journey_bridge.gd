extends SceneTree

## Regression coverage for the real Shared EventSequence -> JourneyScreen -> BattleUI ->
## BattleResolutionService -> resumed EventSession seam across all three recruit battles.
const CASES := [
	{
		"chapter_id": "SHARED-03-EAGLE-SORROW",
		"encounter_id": "SHARED_EAGLE_SORROW",
		"choice_event": "LONGMA_ENCOUNTER",
		"choice_id": "SAVE_THE_DRAGON",
		"expected_recruit": "LONGMA",
		"next_chapter": "SHARED-04-EARLY-DEMON-TALES",
		"milestone": "SHARED_BATTLE_SHARED_EAGLE_SORROW",
	},
	{
		"chapter_id": "SHARED-05-GAOJIAZHUANG",
		"encounter_id": "SHARED_GAOJIAZHUANG",
		"choice_event": "BAJIE_ENCOUNTER",
		"choice_id": "OFFER_REDEMPTION",
		"expected_recruit": "BAJIE",
		"next_chapter": "SHARED-06-FOUR-PERSON-JOURNEY",
		"milestone": "SHARED_BATTLE_SHARED_GAOJIAZHUANG",
	},
	{
		"chapter_id": "SHARED-07-FLOWING-SANDS",
		"encounter_id": "SHARED_FLOWING_SANDS",
		"choice_event": "WUJING_ENCOUNTER",
		"choice_id": "ACCEPT_WUJING",
		"expected_recruit": "WUJING",
		"next_chapter": "SHARED-08-PARTY-FULL",
		"milestone": "SHARED_BATTLE_SHARED_FLOWING_SANDS",
	},
]

func _initialize() -> void:
	var first := _new_base_narrative()
	_assert(await _run_bridge(first, CASES[0]), "Eagle Sorrow bridge should complete")
	_assert(first.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "Eagle bridge should advance shared chapter")
	_assert(SharedJourneyManager.complete("SHARED-04-EARLY-DEMON-TALES", first), "Early demon chapter should advance before Gaojiazhuang")
	_assert(first.save(), "progress before Gaojiazhuang should be persisted")

	_assert(await _run_bridge(first, CASES[1]), "Gaojiazhuang bridge should complete")
	_assert(first.state.current_shared_chapter == "SHARED-06-FOUR-PERSON-JOURNEY", "Gaojiazhuang bridge should advance shared chapter")
	_assert(SharedJourneyManager.complete("SHARED-06-FOUR-PERSON-JOURNEY", first), "Four-person chapter should advance before Flowing Sands")
	_assert(first.save(), "progress before Flowing Sands should be persisted")

	_assert(await _run_bridge(first, CASES[2]), "Flowing Sands bridge should complete")
	_assert(first.state.current_shared_chapter == "SHARED-08-PARTY-FULL", "Flowing Sands bridge should advance shared chapter")
	_assert(first.state.recruited_characters == ["WUKONG", "TANG", "LONGMA", "BAJIE", "WUJING"], "all three shared battle bridges should recruit the canonical companions")

	print("ALL SHARED BATTLE JOURNEY BRIDGE TESTS PASSED")
	quit(0)

func _new_base_narrative() -> NarrativeManager:
	var narrative := NarrativeManager.new()
	_assert(narrative.start_new_game("WUKONG"), "Wukong route should start")
	narrative.encounter_character("TANG")
	narrative.encounter_character("WUKONG")
	narrative.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
	narrative.set_shared_chapter("SHARED-03-EAGLE-SORROW")
	return narrative

func _run_bridge(narrative: NarrativeManager, spec: Dictionary) -> bool:
	var chapter_id := str(spec["chapter_id"])
	var encounter_id := str(spec["encounter_id"])
	var choice_event := str(spec["choice_event"])
	var choice_id := str(spec["choice_id"])
	if chapter_id == "SHARED-05-GAOJIAZHUANG":
		if not ("LONGMA" in narrative.state.recruited_characters and narrative.state.current_shared_chapter == chapter_id):
			return false
	if chapter_id == "SHARED-07-FLOWING-SANDS":
		if not ("BAJIE" in narrative.state.recruited_characters and narrative.state.current_shared_chapter == chapter_id):
			return false
	_assert(SharedJourneyManager.can_enter(chapter_id, narrative.state), "%s should be enterable" % chapter_id)
	_assert(SharedEventManager.new().apply_choice(narrative, choice_event, choice_id), "%s choice should persist" % choice_event)

	var session := NarrativeEventSession.new(EventSequenceManager.get_definition("%s-SEQUENCE" % chapter_id), narrative, "SHARED")
	var action := session.start()
	while str(action.get("kind", "")) == EventRunner.DIALOGUE:
		action = session.complete_action()
	_assert(str(action.get("kind", "")) == EventRunner.CHOICE, "%s sequence should reach its choice" % chapter_id)
	action = session.submit_choice(choice_id)
	_assert(str(action.get("kind", "")) == EventRunner.BATTLE, "%s sequence should reach its battle" % chapter_id)
	_assert(str(action.get("encounter_id", "")) == encounter_id, "%s battle encounter should be canonical" % chapter_id)
	_assert(narrative.save(), "%s pre-battle narrative should be persisted" % chapter_id)

	var handoff := session.start_battle_handoff()
	_assert(not handoff.is_empty(), "%s should create a battle handoff" % chapter_id)
	_assert(BountyEncounterState.start_encounter(
		str(handoff.get("encounter_type", "shared")),
		str(handoff.get("encounter_id", "")),
		str(handoff.get("source_stage_id", "")),
		str(handoff.get("source_chapter_id", "")),
		str(handoff.get("source_route_id", "SHARED_JOURNEY")),
		{"event_resume": handoff.get("event_resume", {})}
	), "%s battle handoff should enter neutral encounter state" % chapter_id)

	var battle_scene := load("res://ui/battle_ui.tscn") as PackedScene
	_assert(battle_scene != null, "battle UI scene should load for %s" % chapter_id)
	var battle_ui = battle_scene.instantiate()
	add_child(battle_ui)
	_assert(battle_ui is BattleUI, "battle UI should instantiate for %s" % chapter_id)
	battle_ui.call_deferred("_on_combat_finished", "allies")
	await process_frame
	await process_frame
	_assert(battle_ui.encounter_resolved, "%s BattleUI should atomically resolve victory" % chapter_id)
	_assert(str(battle_ui.status_label.text).find("共享章节完成") >= 0, "%s BattleUI should report shared completion" % chapter_id)
	battle_ui.queue_free()
	await process_frame

	_assert(narrative.load(), "%s test narrative should reload the committed battle result" % chapter_id)
	var active_after := BountyEncounterState.get_active_record()
	_assert(not active_after.is_empty(), "%s event resume should survive BattleUI victory" % chapter_id)
	_assert(not active_after.get("event_resume", {}).is_empty(), "%s event resume payload should survive victory" % chapter_id)
	_assert(str(active_after.get("encounter_id", "")) == encounter_id, "%s resumed record should retain encounter id" % chapter_id)

	var journey := load("res://ui/journey.tscn").instantiate()
	add_child(journey)
	journey.narrative = narrative
	journey.call("_restore_event_session")
	_assert(journey.event_session != null, "%s JourneyScreen should restore EventSession" % chapter_id)
	var resumed := journey.event_session.get_action()
	_assert(str(resumed.get("kind", "")) == EventRunner.DIALOGUE, "%s battle victory should resume into after-battle dialogue" % chapter_id)
	_assert("" != str(resumed.get("text", "")), "%s after-battle dialogue should contain story text" % chapter_id)
	_assert(narrative.state.current_shared_chapter == str(spec["next_chapter"]), "%s BattleResolutionService should advance the shared chapter" % chapter_id)
	_assert(str(spec["expected_recruit"]) in narrative.state.recruited_characters, "%s should recruit %s" % [chapter_id, str(spec["expected_recruit"])])
	_assert(narrative.state.get_inventory().get("currencies", {}).get("COIN", 0) > 0, "%s should apply its reward before story resume" % chapter_id)

	journey.queue_free()
	BountyEncounterState.clear()
	return true

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
