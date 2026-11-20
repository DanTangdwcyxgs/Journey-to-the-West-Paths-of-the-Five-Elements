extends SceneTree

## Production Journey UI smoke for Origin sequences that contain their own CHOICE node.
## The legacy OriginEvent choice must not be preselected before EventRunner presents it.
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
	_record(fixture.start_new_game("TANG"), "Tang route should initialize")
	for _chapter_index in range(3):
		_record(not fixture.complete_origin_chapter("TANG").is_empty(), "TANG-01 through TANG-03 should complete before the choice sequence")
	_record(str(fixture.origin_routes.get_current_chapter(fixture, "TANG").get("id", "")) == "TANG-04", "fixture should stop at TANG-04")
	_record(fixture.save(), "TANG-04 choice fixture should persist before opening MainMenu")

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame
		_record(not menu.continue_button.disabled, "MainMenu should offer Continue for the saved TANG-04 fixture")
		menu.continue_button.emit_signal("pressed")
		var journey := await _wait_for_journey()
		_record(journey != null, "MainMenu Continue should open the production OriginSequenceJourneyScreen")
		if journey != null:
			_record(journey.narrative.state.starting_character == "TANG", "Journey should preserve Tang as the starting character")
			_record(str(journey.narrative.state.get_origin_choice("TANG-04")) == "", "TANG-04 should not have a legacy choice pre-recorded")
			_record(not journey.primary_button.disabled, "a migrated Origin EventSequence should expose the Continue action")
			_record(not _has_legacy_origin_choice_buttons(journey), "the legacy Origin choice UI must not appear before the EventSequence starts")

			journey.primary_button.emit_signal("pressed")
			await process_frame
			_record(journey.event_session != null, "production Continue should start TANG-04-SEQUENCE")
			if journey.event_session != null:
				_record(journey.event_session.sequence.get_id() == "TANG-04-SEQUENCE", "Journey should load the canonical TANG-04 sequence")
				_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "TANG-04 sequence should begin with canonical dialogue")
				journey.call("_reveal_dialogue_immediately")
				journey.primary_button.emit_signal("pressed")
				await process_frame
				var choice_action: Dictionary = journey.event_session.get_action()
				_record(str(choice_action.get("kind", "")) == EventRunner.CHOICE, "TANG-04 should reach its EventRunner-owned CHOICE node")
				_record(str(journey.narrative.state.get_origin_choice("TANG-04")) == "", "the Origin choice must remain unset until the production EventSequence choice is submitted")
				var choice_id := "FOLLOW_VOW"
				_record(_press_choice(journey, choice_action, choice_id), "EventRunner choice should be visible and actionable through Journey UI")
				await process_frame
				_record(journey.narrative.state.get_origin_choice("TANG-04") == choice_id, "the selected choice should be committed exactly by the EventSequence")
				_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.END, "the selected Origin choice should advance the sequence to END")
				journey.primary_button.emit_signal("pressed")
				await process_frame
				_record(journey.event_session == null, "Origin EventSequence END should close the active session")
				_record(str(journey.origin.get_current_chapter(journey.narrative, "TANG").get("id", "")) == "TANG-05", "successful END should advance the Origin chapter exactly once")

	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	if menu != null and is_instance_valid(menu) and menu.get_parent() == null:
		menu.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("ORIGIN_SEQUENCE_CHOICE_UI_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("ORIGIN_SEQUENCE_CHOICE_UI_FAIL failures=%d" % failures.size())
		quit(1)

func _has_legacy_origin_choice_buttons(journey: OriginSequenceJourneyScreen) -> bool:
	for child in journey.choice_box.get_children():
		if child is Button:
			return true
	return false

func _press_choice(journey: OriginSequenceJourneyScreen, action: Dictionary, choice_id: String) -> bool:
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

func _wait_for_journey() -> OriginSequenceJourneyScreen:
	for _frame in range(60):
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
