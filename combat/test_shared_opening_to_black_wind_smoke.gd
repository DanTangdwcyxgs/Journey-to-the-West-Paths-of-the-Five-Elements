extends SceneTree

## One persisted production UI flow from the final Wukong Origin chapter to Longma recruitment and Memory:
## WUK-15 END -> Shared-01 -> Shared-02 -> Shared-03 battle -> LONGMA-02 playback -> Shared-04.
## User save and encounter handoff files are backed up and restored.

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

	var fixture := NarrativeManager.new()
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the final Origin fixture")
	var origin_chapters: Array = fixture.origin_routes.get_chapters("WUKONG")
	_record(origin_chapters.size() == 15, "Wukong Origin fixture should use its canonical 15 chapters")
	var origin_guard := 0
	while not fixture.origin_routes.is_complete(fixture, "WUKONG") and origin_guard < 32:
		origin_guard += 1
		var current_origin: Dictionary = fixture.origin_routes.get_current_chapter(fixture, "WUKONG")
		if str(current_origin.get("id", "")) == "WUK-15":
			break
		var completed_origin: Dictionary = fixture.complete_origin_chapter("WUKONG")
		_record(not completed_origin.is_empty(), "canonical earlier Origin chapter should complete for the fixture")
	_record(str(fixture.origin_routes.get_current_chapter(fixture, "WUKONG").get("id", "")) == "WUK-15", "fixture should save at the final Wukong Origin chapter, before its real END")
	_record(fixture.state.current_shared_chapter.is_empty(), "Origin fixture must not pre-apply the Shared handoff")
	_record(fixture.save(), "WUK-15 fixture should save before entering the production UI")
	var initial_timeline := fixture.state.current_global_timeline

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame
		_record(not menu.continue_button.disabled, "Continue should be enabled for the Shared-01 save")
		menu.continue_button.emit_signal("pressed")

	var journey: JourneyScreen = await _wait_for_journey()
	_record(journey != null, "MainMenu Continue should load the production Journey screen")
	if journey != null:
		journey = await _drive_sequence(journey, "WUK-15-SEQUENCE", "", "")
		if journey != null:
			_record(journey.narrative.state.route_progress.get("WUKONG", "") == NarrativeState.ROUTE_COMPLETE, "real WUK-15 END should complete the Wukong Origin route")
			_record(journey.narrative.state.current_shared_chapter == "SHARED-01-FIVE-ELEMENTS", "real WUK-15 END should hand off to Shared-01 on the same save")
			_record("WUKONG_RECRUITED" in journey.narrative.state.completed_milestones, "production Origin handoff should record WUKONG_RECRUITED")
			_record("TANG" in journey.narrative.state.recruited_characters and "WUKONG" in journey.narrative.state.recruited_characters, "Origin handoff should reconcile the canonical starting party")
			var handoff_save := NarrativeManager.new()
			_record(handoff_save.load(), "WUK-15 END should persist a loadable Origin-to-Shared handoff")
			if handoff_save.state != null:
				_record(handoff_save.state.current_shared_chapter == "SHARED-01-FIVE-ELEMENTS", "Shared-01 handoff should survive an immediate save reload")
				_record(handoff_save.state.current_origin_chapter.is_empty(), "handoff save should clear the active Origin chapter")
		if journey != null:
			journey = await _drive_sequence(journey, "SHARED-01-FIVE-ELEMENTS-SEQUENCE", "TRUST_WUKONG", "FIVE_ELEMENTS_MOUNTAIN")
			if journey != null:
				_record(journey.narrative.state.current_shared_chapter == "SHARED-02-EARLY-PILGRIMAGE", "Shared-01 END should advance to Shared-02")
				_record("SHARED-01-FIVE-ELEMENTS" in journey.narrative.state.completed_shared_chapters, "Shared-01 should be committed to completed chapters")
				_assert_saved_location("FIVE_ELEMENTS_MOUNTAIN", "Shared-01")

				journey = await _drive_sequence(journey, "SHARED-02-EARLY-PILGRIMAGE-SEQUENCE", "KEEP_MOVING", "FIVE_ELEMENTS_MOUNTAIN")
				if journey != null:
					_record(journey.narrative.state.current_shared_chapter == "SHARED-03-EAGLE-SORROW", "Shared-02 END should advance to Eagle Sorrow")
					_record("SHARED-02-EARLY-PILGRIMAGE" in journey.narrative.state.completed_shared_chapters, "Shared-02 should be committed to completed chapters")

					journey = await _drive_sequence(journey, "SHARED-03-EAGLE-SORROW-SEQUENCE", "SAVE_THE_DRAGON", "EAGLE_SORROW", "SHARED_EAGLE_SORROW")
					if journey != null:
						_record(journey.narrative.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "Longma victory should advance the current chapter to Shared-04")
						_record("LONGMA" in journey.narrative.state.recruited_characters, "Longma should be recruited in the production battle")
						_record("LONGMA-01" in journey.narrative.state.available_memory_chapters and "LONGMA-02" in journey.narrative.state.available_memory_chapters, "Longma recruitment should unlock the personal memories")
						_record("SHARED-03-EAGLE-SORROW" in journey.narrative.state.completed_shared_chapters, "Eagle Sorrow victory should be recorded as completed")
						_assert_saved_location("EAGLE_SORROW", "Shared-03 Longma recruitment")

						journey = await _play_longma_memory(journey)
						if journey != null:
							journey = await _drive_sequence(journey, "SHARED-04-EARLY-DEMON-TALES-SEQUENCE", "", "BLACK_WIND_NORTH_PATH")
						if journey != null:
							_record(journey.narrative.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "Shared-04 END should advance to Shared-05")
							_record("SHARED-04-EARLY-DEMON-TALES" in journey.narrative.state.completed_shared_chapters, "Shared-04 should be committed to completed chapters")
							_record(journey.narrative.state.current_global_timeline > initial_timeline, "the first Shared arc should advance the canonical global timeline")
							_record("BLACK_WIND_NORTH_PATH" in journey.narrative.state.get_world_state().get("visited_nodes", []), "North Path should remain in the exploration visit history")
							_record(not FileAccess.file_exists(encounter_path), "completed Longma battle should not leave an active encounter")
							_record(not FileAccess.file_exists(resume_path), "completed Longma story should clear pending resume data")

	var persisted := NarrativeManager.new()
	_record(persisted.load(), "the complete first Shared arc should leave a loadable save")
	if persisted.state != null:
		_record(persisted.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "saved progression should resume at Shared-05")
		_record(persisted.state.get_world_state().get("current_location", "") == "BLACK_WIND_NORTH_PATH", "saved location should match Shared-04's story arrival")
		_record(persisted.state.current_global_timeline > initial_timeline, "timeline advancement should persist after reload")
		for chapter_id in ["SHARED-01-FIVE-ELEMENTS", "SHARED-02-EARLY-PILGRIMAGE", "SHARED-03-EAGLE-SORROW", "SHARED-04-EARLY-DEMON-TALES"]:
			_record(chapter_id in persisted.state.completed_shared_chapters, "%s should persist as a completed Shared chapter" % chapter_id)
		_record("LONGMA" in persisted.state.recruited_characters, "Longma recruitment should persist at the end of the Shared arc")
		_record("LONGMA-01" in persisted.state.available_memory_chapters and "LONGMA-02" in persisted.state.available_memory_chapters, "Longma memories should remain unlocked in the final save")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	if is_instance_valid(menu):
		menu.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("SHARED_OPENING_TO_BLACK_WIND_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("SHARED_OPENING_TO_BLACK_WIND_FAIL failures=%d" % failures.size())
		quit(1)

func _drive_sequence(journey: JourneyScreen, sequence_id: String, choice_id: String, expected_location: String, expected_battle_id: String = "") -> JourneyScreen:
	if journey == null:
		return null
	if journey.event_session == null:
		journey.primary_button.emit_signal("pressed")
		for _frame in range(45):
			await process_frame
			if current_scene is JourneyScreen:
				journey = current_scene as JourneyScreen
				if journey.event_session != null:
					break
	_record(journey.event_session != null, "%s should create a production EventSession" % sequence_id)
	if journey.event_session == null:
		return journey
	_record(journey.event_session.sequence.get_id() == sequence_id, "Journey should start sequence %s" % sequence_id)

	var finished := false
	for _step in range(240):
		await process_frame
		if current_scene is BattleUI:
			var battle := current_scene as BattleUI
			_record(not expected_battle_id.is_empty(), "%s should not enter an unexpected battle" % sequence_id)
			_record(battle.encounter_type == "shared", "%s battle should use the Shared resolution path" % sequence_id)
			_record(battle.encounter_id == expected_battle_id, "%s battle should hand off the canonical encounter" % sequence_id)
			battle.call_deferred("_on_combat_finished", "allies")
			for _frame in range(12):
				await process_frame
				if battle.encounter_resolved:
					break
			_record(battle.encounter_resolved, "%s production battle should resolve victory" % sequence_id)
			_record(battle.return_button != null and battle.return_button.text == "继续旅途", "%s battle should expose the production Journey return button" % sequence_id)
			if battle.return_button == null:
				break
			battle.return_button.emit_signal("pressed")
			journey = await _wait_for_journey()
			if journey == null:
				_record(false, "%s battle should return to Journey" % sequence_id)
				return null
			continue

		if not current_scene is JourneyScreen:
			_record(false, "%s should remain in Journey or enter its expected BattleUI" % sequence_id)
			break
		journey = current_scene as JourneyScreen
		if journey.event_session == null:
			finished = true
			break
		var action: Dictionary = journey.event_session.get_action()
		var kind := str(action.get("kind", ""))
		match kind:
			EventRunner.DIALOGUE:
				if journey.dialogue_revealing:
					journey.call("_reveal_dialogue_immediately")
				else:
					journey.primary_button.emit_signal("pressed")
			EventRunner.CHOICE:
				if not _press_choice(journey, action, choice_id):
					_record(false, "%s should expose canonical choice %s" % [sequence_id, choice_id])
					break
			EventRunner.MOVE, EventRunner.WAIT:
				var seconds := maxf(float(action.get("seconds", 0.0)), 0.35) + 0.15
				journey.primary_button.emit_signal("pressed")
				await create_timer(seconds).timeout
				if kind == EventRunner.MOVE:
					var marker := str(action.get("marker_id", ""))
					_record(not marker.is_empty(), "%s MOVE should declare a WorldMap marker" % sequence_id)
					_record(str(journey.narrative.state.get_world_state().get("current_location", "")) == marker, "%s MOVE should commit location %s" % [sequence_id, marker])
					_record(marker == expected_location, "%s MOVE should target its expected canonical location" % sequence_id)
					var move_save := NarrativeManager.new()
					_record(move_save.load(), "%s MOVE should be saved before story continues" % sequence_id)
					if move_save.state != null:
						_record(str(move_save.state.get_world_state().get("current_location", "")) == marker, "%s MOVE should persist through reload" % sequence_id)
			EventRunner.BATTLE:
				journey.primary_button.emit_signal("pressed")
			EventRunner.END:
				journey.primary_button.emit_signal("pressed")
			_:
				_record(false, "%s encountered unsupported action kind %s" % [sequence_id, kind])
				break
	_record(finished, "%s should reach and handle END through the production UI" % sequence_id)
	if finished and not expected_location.is_empty():
		_record(str(journey.narrative.state.get_world_state().get("current_location", "")) == expected_location, "%s should finish at %s" % [sequence_id, expected_location])
	return journey

func _press_choice(journey: JourneyScreen, action: Dictionary, choice_id: String) -> bool:
	var label := ""
	for choice in action.get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			label = str(choice.get("label", choice_id))
			break
	if label.is_empty():
		return false
	for child in journey.choice_box.get_children():
		var button := child as Button
		if button != null and button.text == label:
			button.emit_signal("pressed")
			return true
	return false

func _play_longma_memory(journey: JourneyScreen) -> JourneyScreen:
	if journey == null:
		return null

	var memory_row := -1
	for index in range(journey.list.get_item_count()):
		if journey.list.get_item_text(index) == "回忆 · LONGMA-02":
			memory_row = index
			break
	_record(memory_row >= 0, "Longma recruitment should expose LONGMA-02 in the production Journey memory list")
	if memory_row < 0:
		return journey

	var shared_context_before: Dictionary = journey.narrative.state.snapshot_shared_context()
	var state_before: Dictionary = journey.narrative.serialize().duplicate(true)
	journey.list.select(memory_row)
	journey.call("_on_sidebar_item_selected", memory_row)
	_record(not journey.memory_button.disabled, "selecting LONGMA-02 should enable the real memory playback control")
	journey.memory_button.emit_signal("pressed")
	_record(journey.memory_playback_session != null, "Journey should open a real LONGMA-02 read-only MemoryPlaybackSession")
	if journey.memory_playback_session == null:
		return journey

	_record(journey.memory_playback_session.chapter_title == "龙子获罪", "Longma memory should use the canonical chapter title")
	_record(journey.memory_playback_session.get_total_entries() == 2, "battle memory should present only its two canonical dialogue entries")
	_record(journey.dialogue_full_text.find("罪责落到身上") >= 0, "Longma Memory should start with the canonical pre-battle dialogue")
	_record(journey.primary_button.text == "继续回忆", "the first dialogue should expose a continue action")
	_record(journey.party_button.disabled and journey.world_button.disabled and journey.save_button.disabled, "world-changing controls should be locked during memory playback")

	journey.call("_advance_primary")
	_record(not journey.dialogue_revealing, "first memory input should reveal the opening text")
	journey.call("_advance_primary")
	_record(journey.memory_playback_session.get_current_position() == 2, "second memory input should advance to the post-battle dialogue")
	_record(journey.dialogue_full_text.find("真正的担当") >= 0, "Longma Memory should show its canonical post-battle dialogue")
	_record(journey.primary_button.text == "完成回忆", "last memory entry should require explicit completion")
	_record(journey.narrative.serialize() == state_before, "reading historical dialogue must not mutate present NarrativeState")
	_record(journey.memory_playback_session.shared_context_unchanged(), "Memory playback must preserve Shared chapter, roster and timeline")

	journey.call("_advance_primary")
	_record(not journey.dialogue_revealing, "the final memory dialogue should reveal before it can be completed")
	journey.call("_advance_primary")
	_record(journey.memory_playback_session == null, "explicit memory completion should return to Journey")
	_record(journey.narrative.state.snapshot_shared_context() == shared_context_before, "memory completion must preserve Shared chapter, roster and timeline")
	_record("LONGMA-02" not in journey.narrative.state.available_memory_chapters, "finished Longma memory should leave the available-memory list")
	_record("LONGMA-02" in journey.narrative.state.played_memory_chapters, "finished Longma memory should enter the played-memory list")
	_record(not journey.party_button.disabled and not journey.world_button.disabled and not journey.save_button.disabled, "Journey controls should unlock after playback")

	var expected_non_memory := state_before.duplicate(true)
	var actual_after_memory := journey.narrative.serialize().duplicate(true)
	expected_non_memory.erase("available_memory_chapters")
	expected_non_memory.erase("played_memory_chapters")
	actual_after_memory.erase("available_memory_chapters")
	actual_after_memory.erase("played_memory_chapters")
	_record(actual_after_memory == expected_non_memory, "only Memory availability/played flags may change after replay")

	var saved_memory := NarrativeManager.new()
	_record(saved_memory.load(), "Memory completion should persist a reloadable save")
	if saved_memory.state != null:
		_record("LONGMA-02" in saved_memory.state.played_memory_chapters, "played-memory flag should survive save reload")
		_record(saved_memory.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "memory save should retain the post-Eagle-Sorrow Shared-04 chapter")
		_record(saved_memory.state.current_global_timeline == shared_context_before.get("current_global_timeline"), "memory save should preserve chronology")
		_record(str(saved_memory.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "memory save should preserve Eagle Sorrow as the current location")

	return journey

func _assert_saved_location(expected_location: String, context: String) -> void:
	var saved := NarrativeManager.new()
	_record(saved.load(), "%s should leave a loadable save" % context)
	if saved.state != null:
		_record(str(saved.state.get_world_state().get("current_location", "")) == expected_location, "%s should persist location %s" % [context, expected_location])

func _wait_for_journey() -> JourneyScreen:
	for _frame in range(60):
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
