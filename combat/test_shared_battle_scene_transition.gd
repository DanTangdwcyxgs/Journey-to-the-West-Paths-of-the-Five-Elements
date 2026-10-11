extends SceneTree

## End-to-end shared recruitment battle smoke using production scene transitions.
## Every user:// file touched by this test is backed up and restored.

const CASES := [
	{"chapter_id":"SHARED-03-EAGLE-SORROW","encounter_id":"SHARED_EAGLE_SORROW","choice_event_id":"LONGMA_ENCOUNTER","choice_id":"SAVE_THE_DRAGON","expected_recruit":"LONGMA","next_chapter":"SHARED-04-EARLY-DEMON-TALES","expected_world_location":"EAGLE_SORROW"},
	{"chapter_id":"SHARED-05-GAOJIAZHUANG","encounter_id":"SHARED_GAOJIAZHUANG","choice_event_id":"BAJIE_ENCOUNTER","choice_id":"OFFER_REDEMPTION","expected_recruit":"BAJIE","next_chapter":"SHARED-06-FOUR-PERSON-JOURNEY","expected_world_location":"GAOJIAZHUANG"},
	{"chapter_id":"SHARED-07-FLOWING-SANDS","encounter_id":"SHARED_FLOWING_SANDS","choice_event_id":"WUJING_ENCOUNTER","choice_id":"ACCEPT_WUJING","expected_recruit":"WUJING","next_chapter":"SHARED-08-PARTY-FULL","expected_world_location":"FLOWING_SANDS"},
]

var failures: Array[String] = []

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var save_path: String = NarrativeSave.SAVE_PATH
	var encounter_path: String = BountyEncounterState.PATH
	var resume_path: String = BountyEncounterState.RESUME_PATH
	var save_backup := _capture_file(save_path)
	var encounter_backup := _capture_file(encounter_path)
	var resume_backup := _capture_file(resume_path)
	_remove_file(save_path)
	_remove_file(encounter_path)
	_remove_file(resume_path)

	var bootstrap := Control.new()
	bootstrap.name = "SharedBattleSceneTransitionBootstrap"
	root.add_child(bootstrap)
	current_scene = bootstrap

	var completed_cases := 0
	for spec in CASES:
		var chapter_id := str(spec["chapter_id"])
		var narrative := _prepare_narrative(chapter_id)
		if narrative == null:
			break
		if not narrative.save():
			_record(false, "%s fixture should save before entering production scenes" % chapter_id)
			break
		if not BountyEncounterState.clear_completed_event_session():
			_record(false, "%s fixture should start without a stale handoff" % chapter_id)
			break

		var menu: MainMenu = null
		if current_scene is JourneyScreen:
			(current_scene as JourneyScreen).call("_back_to_menu")
			menu = await _wait_for_main_menu()
		elif current_scene is MainMenu:
			menu = current_scene as MainMenu
		else:
			var menu_error: Error = change_scene_to_file("res://ui/main_menu.tscn")
			_record(menu_error == OK, "%s should enter production MainMenu" % chapter_id)
			menu = await _wait_for_main_menu()
		if menu == null:
			_record(false, "%s should reach MainMenu before continuing the save" % chapter_id)
			break
		_record(not menu.continue_button.disabled, "%s Continue should be enabled for the prepared save" % chapter_id)
		if menu.continue_button.disabled:
			break
		menu.continue_button.emit_signal("pressed")

		var journey := await _wait_for_journey()
		if journey == null:
			_record(false, "%s MainMenu Continue should load production Journey" % chapter_id)
			break
		var battle := await _drive_journey_into_battle(journey, spec)
		if battle == null:
			_record(false, "%s Journey should switch into its production recruitment BattleUI" % chapter_id)
			break
		_record(battle.encounter_type == "shared", "%s scene transition should preserve shared encounter type" % chapter_id)
		_record(battle.encounter_id == str(spec["encounter_id"]), "%s scene transition should preserve canonical encounter ID" % chapter_id)

		var pre_battle_record := BountyEncounterState.get_active_record()
		_record(str(pre_battle_record.get("source_chapter_id", "")) == chapter_id, "%s handoff should preserve source chapter" % chapter_id)
		_record(not pre_battle_record.get("event_resume", {}).is_empty(), "%s handoff should preserve EventSession snapshot" % chapter_id)

		battle.call_deferred("_on_combat_finished", "allies")
		await process_frame
		await process_frame
		_record(battle.encounter_resolved, "%s production NarrativeBattleUI should resolve victory" % chapter_id)
		_record(battle.status_label != null and battle.status_label.text.find("共享章节完成") >= 0, "%s victory UI should show shared chapter completion" % chapter_id)
		_record(battle.status_label != null and battle.status_label.text.find("奖励：") >= 0, "%s victory UI should show rewards" % chapter_id)
		_record(battle.return_button != null and battle.return_button.text == "继续旅途", "%s victory UI should expose production return control" % chapter_id)
		if not battle.encounter_resolved or battle.return_button == null:
			break

		var committed := NarrativeManager.new()
		_record(committed.load(), "%s victory should persist a loadable narrative" % chapter_id)
		_record(committed.state.current_shared_chapter == str(spec["next_chapter"]), "%s victory should advance the canonical shared chapter" % chapter_id)
		_record(str(spec["expected_recruit"]) in committed.state.recruited_characters, "%s victory should recruit the expected companion" % chapter_id)
		var expected_world_location := str(spec.get("expected_world_location", ""))
		if not expected_world_location.is_empty():
			_record(str(committed.state.get_world_state().get("current_location", "")) == expected_world_location, "%s victory should preserve the story-established WorldMap location" % chapter_id)

		battle.return_button.emit_signal("pressed")
		var resumed_journey := await _wait_for_journey()
		if resumed_journey == null:
			_record(false, "%s Continue Journey button should load production Journey" % chapter_id)
			break
		_record(resumed_journey.event_session != null, "%s Journey should restore EventSession after battle" % chapter_id)
		if resumed_journey.event_session == null:
			break
		var resumed_action: Dictionary = resumed_journey.event_session.get_action()
		_record(str(resumed_action.get("kind", "")) == EventRunner.DIALOGUE, "%s EventSession should resume at after-battle dialogue" % chapter_id)
		_record(not str(resumed_action.get("text", "")).is_empty(), "%s after-battle dialogue should contain text" % chapter_id)

		var ended := await _drive_resumed_session_to_end(resumed_journey, chapter_id)
		_record(ended, "%s resumed session should reach END through Journey UI" % chapter_id)
		_record(resumed_journey.event_session == null, "%s END should close the active EventSession" % chapter_id)
		_record(resumed_journey.phase_label != null and resumed_journey.phase_label.text.find("战后剧情完成") >= 0, "%s END should show completion feedback" % chapter_id)
		_record(not FileAccess.file_exists(encounter_path), "%s END should remove active encounter file" % chapter_id)
		_record(not FileAccess.file_exists(resume_path), "%s END should remove pending resume file" % chapter_id)

		var persisted_after_end := NarrativeManager.new()
		_record(persisted_after_end.load(), "%s END should leave a loadable save" % chapter_id)
		if persisted_after_end.state != null:
			_record(persisted_after_end.state.current_shared_chapter == str(spec["next_chapter"]), "%s END must not advance chapter twice" % chapter_id)
			_record(str(spec["expected_recruit"]) in persisted_after_end.state.recruited_characters, "%s recruit should persist after END" % chapter_id)
			_record(chapter_id in persisted_after_end.state.completed_shared_chapters, "%s should remain recorded as completed" % chapter_id)

		if chapter_id == "SHARED-03-EAGLE-SORROW":
			_record("LONGMA-01" in resumed_journey.narrative.state.available_memory_chapters, "actual Longma recruitment should unlock LONGMA-01 memory")
			_record("LONGMA-02" in resumed_journey.narrative.state.available_memory_chapters, "actual Longma recruitment should unlock LONGMA-02 memory")
			var memory_row_index := -1
			for row_index in range(resumed_journey.list.get_item_count()):
				if resumed_journey.list.get_item_text(row_index) == "回忆 · LONGMA-02":
					memory_row_index = row_index
					break
			_record(memory_row_index >= 0, "the production Journey list should surface unlocked LONGMA-02 memory")
			if memory_row_index >= 0:
				resumed_journey.list.select(memory_row_index)
				resumed_journey.call("_on_sidebar_item_selected", memory_row_index)
				resumed_journey.call("_play_selected_memory")
				_record(resumed_journey.memory_playback_session != null, "the unlocked memory should open through the production Journey button")
				if resumed_journey.memory_playback_session != null:
					var shared_context_before_memory: Dictionary = resumed_journey.narrative.state.snapshot_shared_context()
					var narrative_before_memory: Dictionary = resumed_journey.narrative.serialize().duplicate(true)
					_record(resumed_journey.dialogue_full_text.find("罪责落到身上") >= 0, "LONGMA-02 memory should begin at its canonical opening dialogue")
					resumed_journey.call("_advance_primary")
					_record(not resumed_journey.dialogue_revealing and resumed_journey.memory_playback_session.get_current_position() == 1, "memory input should reveal the current dialogue before advancing")
					resumed_journey.call("_advance_primary")
					_record(resumed_journey.memory_playback_session.get_current_position() == 2, "memory should advance to its post-battle dialogue without entering combat")
					_record(resumed_journey.dialogue_full_text.find("真正的担当") >= 0, "LONGMA-02 memory should include its canonical aftermath dialogue")
					_record(resumed_journey.primary_button.text == "完成回忆", "the last memory dialogue should expose explicit completion")
					resumed_journey.call("_advance_primary")
					resumed_journey.call("_advance_primary")
					_record(resumed_journey.memory_playback_session == null, "memory completion should return to the Journey presentation")
					_record(current_scene == resumed_journey, "read-only memory playback must not replace the Journey scene with BattleUI")
					_record(resumed_journey.narrative.state.snapshot_shared_context() == shared_context_before_memory, "memory playback should preserve chapter, timeline, completed shared chapters and roster")
					_record("LONGMA-02" not in resumed_journey.narrative.state.available_memory_chapters, "finished memory should leave the available list")
					_record("LONGMA-02" in resumed_journey.narrative.state.played_memory_chapters, "finished memory should enter the played list")
					var before_non_memory := narrative_before_memory.duplicate(true)
					var after_non_memory := resumed_journey.narrative.serialize().duplicate(true)
					before_non_memory.erase("available_memory_chapters")
					before_non_memory.erase("played_memory_chapters")
					after_non_memory.erase("available_memory_chapters")
					after_non_memory.erase("played_memory_chapters")
					_record(before_non_memory == after_non_memory, "Memory completion should only change the memory availability/played flags")
					var memory_save := NarrativeManager.new()
					_record(memory_save.load(), "finished Longma memory should leave a loadable save")
					if memory_save.state != null:
						_record("LONGMA-02" in memory_save.state.played_memory_chapters, "played-memory status should persist after reload")
						_record(memory_save.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "memory save must preserve the post-Eagle-Sorrow shared chapter")
					_record(memory_save.state.current_global_timeline == shared_context_before_memory.get("current_global_timeline"), "memory save must preserve global timeline")
					_record(not FileAccess.file_exists(encounter_path), "memory playback must not create a new active battle handoff")
					_record(not FileAccess.file_exists(resume_path), "memory playback must not create pending battle-resume data")

		completed_cases += 1
		if completed_cases < CASES.size():
			resumed_journey.call("_back_to_menu")
			var next_menu := await _wait_for_main_menu()
			if next_menu == null:
				_record(false, "production Journey should return to MainMenu between cases")
				break

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty() and completed_cases == CASES.size():
		print("SHARED_BATTLE_SCENE_TRANSITION_PASS cases=%d" % completed_cases)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		if completed_cases != CASES.size():
			push_error("SHARED_BATTLE_SCENE_TRANSITION_INCOMPLETE cases=%d/%d" % [completed_cases, CASES.size()])
		print("SHARED_BATTLE_SCENE_TRANSITION_FAIL failures=%d cases=%d/%d" % [failures.size(), completed_cases, CASES.size()])
		quit(1)

func _prepare_narrative(target_chapter: String) -> NarrativeManager:
	var narrative := NarrativeManager.new()
	if not narrative.start_new_game("WUKONG"):
		_record(false, "Wukong route should initialize shared fixture")
		return null
	narrative.encounter_character("TANG")
	narrative.encounter_character("WUKONG")
	narrative.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
	if not SharedJourneyManager.complete("SHARED-01-FIVE-ELEMENTS", narrative):
		_record(false, "Shared-01 fixture should complete")
		return null
	if not SharedJourneyManager.complete("SHARED-02-EARLY-PILGRIMAGE", narrative):
		_record(false, "Shared-02 fixture should complete")
		return null

	if target_chapter == "SHARED-05-GAOJIAZHUANG" or target_chapter == "SHARED-07-FLOWING-SANDS":
		if not _resolve_setup_battle(narrative, "SHARED-03-EAGLE-SORROW", "SHARED_EAGLE_SORROW", "LONGMA_ENCOUNTER", "SAVE_THE_DRAGON"):
			_record(false, "Shared-03 preparation battle should resolve for later cases")
			return null
		if not SharedJourneyManager.complete("SHARED-04-EARLY-DEMON-TALES", narrative):
			_record(false, "Shared-04 fixture should complete before Gaojiazhuang")
			return null

	if target_chapter == "SHARED-07-FLOWING-SANDS":
		if not _resolve_setup_battle(narrative, "SHARED-05-GAOJIAZHUANG", "SHARED_GAOJIAZHUANG", "BAJIE_ENCOUNTER", "OFFER_REDEMPTION"):
			_record(false, "Shared-05 preparation battle should resolve for Flowing Sands")
			return null
		if not SharedJourneyManager.complete("SHARED-06-FOUR-PERSON-JOURNEY", narrative):
			_record(false, "Shared-06 fixture should complete before Flowing Sands")
			return null

	narrative.state.mark_route_complete("WUKONG")
	narrative.state.set_current_shared_chapter(target_chapter)
	return narrative

func _resolve_setup_battle(narrative: NarrativeManager, chapter_id: String, encounter_id: String, event_id: String, choice_id: String) -> bool:
	var events := SharedEventManager.new()
	if not events.apply_choice(narrative, event_id, choice_id):
		return false
	var encounters := EncounterManager.new()
	var definition: Dictionary = encounters.get_definition(encounter_id)
	if definition.is_empty():
		return false
	var result := BattleResolutionService.resolve_narrative_victory(
		narrative,
		"shared",
		encounter_id,
		"",
		chapter_id,
		"SHARED_JOURNEY",
		str(definition.get("name", encounter_id)),
		definition.get("rewards", []),
		definition.get("world_effects", []),
		encounters
	)
	return not result.is_empty()

func _drive_journey_into_battle(journey: JourneyScreen, spec: Dictionary) -> BattleUI:
	journey.primary_button.emit_signal("pressed")
	for _step in range(48):
		await process_frame
		if current_scene is BattleUI:
			return current_scene as BattleUI
		if current_scene != journey:
			return null
		if journey.event_session == null:
			_record(false, "%s should start its production EventSession" % str(spec["chapter_id"]))
			return null
		var action: Dictionary = journey.event_session.get_action()
		var kind := str(action.get("kind", ""))
		match kind:
			EventRunner.DIALOGUE:
				journey.primary_button.emit_signal("pressed")
			EventRunner.CHOICE:
				if not _press_event_choice(journey, action, str(spec["choice_id"])):
					_record(false, "%s canonical choice button should exist in Journey UI" % str(spec["chapter_id"]))
					return null
			EventRunner.WAIT, EventRunner.MOVE:
				var transition_kind := kind
				var seconds := maxf(float(action.get("seconds", 0.0)), 0.35) + 0.12
				journey.primary_button.emit_signal("pressed")
				await create_timer(seconds).timeout
				if transition_kind == EventRunner.MOVE:
					var expected_location := str(spec.get("expected_world_location", ""))
					if not expected_location.is_empty():
						_record(str(journey.narrative.state.get_world_state().get("current_location", "")) == expected_location, "%s story MOVE should set WorldMap location to %s" % [str(spec["chapter_id"]), expected_location])
						var moved_save := NarrativeManager.new()
						_record(moved_save.load(), "%s story move save should reload" % str(spec["chapter_id"]))
						if moved_save.state != null:
							_record(str(moved_save.state.get_world_state().get("current_location", "")) == expected_location, "%s story move location should persist through reload" % str(spec["chapter_id"]))
			EventRunner.BATTLE:
				journey.primary_button.emit_signal("pressed")
			_:
				_record(false, "%s reached unexpected pre-battle action: %s" % [str(spec["chapter_id"]), kind])
				return null
	return null

func _press_event_choice(journey: JourneyScreen, action: Dictionary, choice_id: String) -> bool:
	var selected_label := ""
	for choice in action.get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			selected_label = str(choice.get("label", choice_id))
			break
	if selected_label.is_empty():
		return false
	for child in journey.choice_box.get_children():
		var button := child as Button
		if button != null and button.text == selected_label:
			button.emit_signal("pressed")
			return true
	return false

func _drive_resumed_session_to_end(journey: JourneyScreen, chapter_id: String) -> bool:
	for _step in range(24):
		await process_frame
		if journey.event_session == null:
			return true
		var action: Dictionary = journey.event_session.get_action()
		var kind := str(action.get("kind", ""))
		match kind:
			EventRunner.DIALOGUE:
				journey.primary_button.emit_signal("pressed")
			EventRunner.END:
				journey.primary_button.emit_signal("pressed")
			EventRunner.WAIT, EventRunner.MOVE:
				var seconds := maxf(float(action.get("seconds", 0.0)), 0.35) + 0.12
				journey.primary_button.emit_signal("pressed")
				await create_timer(seconds).timeout
			_:
				_record(false, "%s resumed session reached unexpected pre-END action: %s" % [chapter_id, kind])
				return false
	return journey.event_session == null

func _wait_for_main_menu() -> MainMenu:
	for _frame in range(45):
		await process_frame
		if current_scene is MainMenu:
			return current_scene as MainMenu
	return null

func _wait_for_journey() -> JourneyScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is JourneyScreen:
			return current_scene as JourneyScreen
	return null

func _capture_file(path: String) -> Dictionary:
	var existed: bool = FileAccess.file_exists(path)
	var content: PackedByteArray = FileAccess.get_file_as_bytes(path) if existed else PackedByteArray()
	return {"existed": existed, "content": content}

func _remove_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_record(error == OK, "temporary test cleanup should remove %s (error=%s)" % [path, str(error)])

func _restore_file(path: String, backup: Dictionary) -> void:
	if bool(backup.get("existed", false)):
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			_record(false, "could not restore previous user file: %s" % path)
			return
		file.store_buffer(backup.get("content", PackedByteArray()) as PackedByteArray)
		file.close()
	else:
		_remove_file(path)

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
