extends SceneTree

## SceneTree regression: completing the final Origin Sequence must immediately
## hand off to the first canonical Shared chapter, instead of leaving an empty
## current_shared_chapter behind a ROUTE_COMPLETE flag.
## The test seeds WUK-01..WUK-14 via the chapter manager, then uses production
## MainMenu Continue and the production WUK-15 Journey END handler.

var failures: Array[String] = []

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var save_path: String = NarrativeSave.SAVE_PATH
	var encounter_path: String = BountyEncounterState.PATH
	var resume_path: String = BountyEncounterState.RESUME_PATH
	var save_backup: Dictionary = _capture_file(save_path)
	var encounter_backup: Dictionary = _capture_file(encounter_path)
	var resume_backup: Dictionary = _capture_file(resume_path)
	_remove_file(save_path)
	_remove_file(encounter_path)
	_remove_file(resume_path)

	var fixture := NarrativeManager.new()
	_record(fixture.start_new_game("WUKONG"), "Wukong should start the final chapter fixture")
	var chapters: Array = fixture.origin_routes.get_chapters("WUKONG")
	_record(chapters.size() == 15, "Wukong fixture should use the canonical 15 chapter route")
	for i in range(maxi(chapters.size() - 1, 0)):
		var expected_id := str(chapters[i].get("id", ""))
		var completed: Dictionary = fixture.complete_origin_chapter("WUKONG")
		_record(str(completed.get("id", "")) == expected_id, "%s should be completed before the final chapter" % expected_id)
	_record(str(fixture.origin_routes.get_current_chapter(fixture, "WUKONG").get("id", "")) == "WUK-15", "fixture should resume exactly at WUK-15")
	_record(fixture.state.current_shared_chapter.is_empty(), "Origin-only fixture should not already have a shared chapter")
	_record(fixture.save(), "WUK-15 fixture should save before opening production UI")

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame
		_record(not menu.continue_button.disabled, "Continue should be enabled for WUK-15 save")
		menu.continue_button.emit_signal("pressed")

	var journey: OriginSequenceJourneyScreen = await _wait_for_origin_journey()
	_record(journey != null, "MainMenu Continue should load production OriginSequenceJourneyScreen")
	if journey != null:
		_record(journey.narrative.state.starting_character == "WUKONG", "loaded save should preserve the Wukong starting route")
		_record(str(journey.origin.get_current_chapter(journey.narrative, "WUKONG").get("id", "")) == "WUK-15", "production Journey should begin at WUK-15")
		journey.call("_advance_primary")
		_record(journey.event_session != null, "Journey should start the real WUK-15 EventSequence")
		if journey.event_session != null:
			_record(journey.event_session.sequence.get_id() == "WUK-15-SEQUENCE", "the current production sequence should be WUK-15")
			_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "WUK-15 should open on its story dialogue")
			var guard := 0
			while journey.event_session != null and guard < 16:
				guard += 1
				var action: Dictionary = journey.event_session.get_action()
				match str(action.get("kind", "")):
					EventRunner.DIALOGUE:
						journey.call("_advance_primary")
					EventRunner.END:
						journey.call("_advance_primary")
					EventRunner.WAIT, EventRunner.MOVE:
						journey.call("_advance_primary")
					_:
						_record(false, "WUK-15 should not require an unsupported action before route handoff: %s" % str(action.get("kind", "")))
						break
				await process_frame
			_record(journey.event_session == null, "WUK-15 END should finish through the real Journey handler")
			_record(journey.narrative.state.route_progress.get("WUKONG", "") == NarrativeState.ROUTE_COMPLETE, "the completed Wukong route should be marked complete")
			_record(journey.narrative.state.current_shared_chapter == "SHARED-01-FIVE-ELEMENTS", "final Origin END should enter the canonical first Shared chapter")
			_record("WUKONG_RECRUITED" in journey.narrative.state.completed_milestones, "handoff should record the canonical Wukong milestone")
			_record(journey.phase_label.text.find("已汇入共享西游") >= 0, "completion feedback should tell the player the Shared Journey has begun")
			_record(FileAccess.file_exists(save_path), "Origin-to-Shared handoff should persist the save")

			var persisted := NarrativeManager.new()
			_record(persisted.load(), "post-handoff save should be loadable")
			if persisted.state != null:
				_record(persisted.state.current_shared_chapter == "SHARED-01-FIVE-ELEMENTS", "Shared-01 should persist after reload")
				_record(persisted.state.current_origin_chapter.is_empty(), "handoff should clear the active Origin chapter")
				_record("TANG" in persisted.state.recruited_characters and "WUKONG" in persisted.state.recruited_characters, "handoff should reconcile the canonical starting roster")

			journey.call("_advance_primary")
			_record(journey.event_session != null, "the next production Journey action should enter Shared-01")
			if journey.event_session != null:
				_record(journey.event_session.sequence.get_id() == "SHARED-01-FIVE-ELEMENTS-SEQUENCE", "the first shared chapter should use its production EventSequence")
				_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "Shared-01 should start with the opening dialogue")

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
		print("ORIGIN_FINAL_SHARED_HANDOFF_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("ORIGIN_FINAL_SHARED_HANDOFF_FAIL failures=%d" % failures.size())
		quit(1)

func _wait_for_origin_journey() -> OriginSequenceJourneyScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is OriginSequenceJourneyScreen:
			return current_scene as OriginSequenceJourneyScreen
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
