extends SceneTree

## End-to-end entry smoke: MainMenu -> saved new game -> production Journey -> Origin EventSequence.
## The test temporarily isolates and then restores all user:// files it touches.
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

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "main menu scene should load")
	var menu: MainMenu = null
	if menu_scene != null:
		menu = menu_scene.instantiate() as MainMenu
	_record(menu != null, "main menu scene should instantiate MainMenu")

	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame
		menu.selected_character = "WUKONG"
		menu.call("_start_new_game")
		for i in range(20):
			await process_frame
			if current_scene != menu:
				break

		_record(FileAccess.file_exists(save_path), "starting a route should persist the new narrative before navigation")
		var journey := current_scene as OriginSequenceJourneyScreen
		_record(journey != null, "MainMenu should navigate to the production Journey scene")
		if journey != null:
			_record(journey.narrative.state.starting_character == "WUKONG", "Journey should load the selected starting character")
			journey.call("_advance_primary")
			_record(journey.event_session != null, "Journey should enter the migrated WUK-01 EventSequence")
			if journey.event_session != null:
				_record(journey.event_session.sequence.get_id() == "WUK-01-SEQUENCE", "Journey should load the production WUK-01 sequence")
				_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "WUK-01 should start at its dialogue action")

	# Ensure no SceneTree nodes survive the smoke test process before restoring user files.
	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	if is_instance_valid(menu):
		menu.free()
	await process_frame

	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("MAIN_MENU_JOURNEY_ENTRY_SMOKE_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("MAIN_MENU_JOURNEY_ENTRY_SMOKE_FAIL failures=%d" % failures.size())
		quit(1)

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
