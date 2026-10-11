extends SceneTree

## One persisted production UI flow from Origin handoff through the opening Shared arc:
## Shared-01 -> Shared-02 -> Eagle Sorrow / Longma -> Shared-04 / Black Wind North Path.
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
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the Shared opening fixture")
	var origin_guard := 0
	while not fixture.origin_routes.is_complete(fixture, "WUKONG"):
		origin_guard += 1
		if origin_guard >= 32:
			_record(false, "Wukong Origin fixture should complete within the route guard")
			break
		_record(not fixture.complete_origin_chapter("WUKONG").is_empty(), "canonical Origin chapter should complete for the saved fixture")
	_record(fixture.origin_routes.is_complete(fixture, "WUKONG"), "fixture should be at the completed Wukong handoff boundary")
	_record(fixture.handoff_origin_to_shared("WUKONG"), "Wukong should enter the first canonical Shared chapter")
	_record(fixture.state.current_shared_chapter == "SHARED-01-FIVE-ELEMENTS", "fixture should begin at Shared-01")
	_record(fixture.save(), "Shared-01 fixture should save before entering the production UI")
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
