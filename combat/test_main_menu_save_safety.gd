extends SceneTree

## Production MainMenu save preview and overwrite-confirmation regression.
## The test backs up and restores the user's existing narrative slot.
var failures: Array[String] = []

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var save_path: String = NarrativeSave.SAVE_PATH
	var save_backup := _capture_file(save_path)
	_remove_file(save_path)

	var fixture := NarrativeManager.new()
	_record(fixture.start_new_game("BAJIE"), "existing-save fixture should initialize Bajie's route")
	fixture.state.current_global_timeline = 130
	fixture.state.set_current_shared_chapter("SHARED-05-GAOJIAZHUANG")
	_record(fixture.save(), "existing-save fixture should persist before MainMenu opens")

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame

		_record(menu.save_present, "MainMenu should detect the existing save slot")
		_record(menu.save_loadable, "MainMenu should load the existing save before rendering its preview")
		_record(not menu.continue_button.disabled, "Continue should be enabled only for a loadable save")
		_record(menu.current_label.text.find("猪八戒") >= 0, "save preview should identify the actual starting protagonist")
		_record(menu.current_label.text.find("T0130") >= 0, "save preview should show the persisted global timeline")
		_record(menu.current_label.text.find("SHARED-05-GAOJIAZHUANG") >= 0, "save preview should show the persisted Shared chapter")
		_record(menu.continue_button.text.find("猪八戒") >= 0, "Continue control should identify which save it will resume")

		menu.selected_character = "TANG"
		menu.call("_start_new_game")
		await process_frame
		_record(is_instance_valid(menu.overwrite_dialog), "starting a new route with an existing save should open an explicit confirmation")
		if is_instance_valid(menu.overwrite_dialog):
			_record(menu.overwrite_dialog.title == "覆盖现有存档？", "overwrite dialog should clearly identify the destructive action")
			_record(menu.overwrite_dialog.dialog_text.find("覆盖") >= 0, "overwrite dialog should explain that the single save slot will be replaced")
			menu.overwrite_dialog.get_cancel_button().emit_signal("pressed")
			await process_frame
			var after_cancel := NarrativeManager.new()
			_record(after_cancel.load(), "canceling overwrite should leave the existing save readable")
			if after_cancel.state != null:
				_record(after_cancel.state.starting_character == "BAJIE", "canceling overwrite must preserve the existing protagonist")
				_record(after_cancel.state.current_global_timeline == 130, "canceling overwrite must preserve the existing timeline")

		menu.call("_start_new_game")
		await process_frame
		if is_instance_valid(menu.overwrite_dialog):
			menu.overwrite_dialog.get_ok_button().emit_signal("pressed")
		var new_journey: OriginSequenceJourneyScreen = await _wait_for_journey()
		_record(new_journey != null, "confirming overwrite should start the selected new route through production Journey")
		if new_journey != null:
			_record(new_journey.narrative.state.starting_character == "TANG", "confirmed overwrite should persist and load the newly selected protagonist")
			var persisted_new_game := NarrativeManager.new()
			_record(persisted_new_game.load(), "confirmed overwrite should leave a loadable new save")
			if persisted_new_game.state != null:
				_record(persisted_new_game.state.starting_character == "TANG", "confirmed overwrite should replace the prior save with the selected new route")

	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	if menu != null and is_instance_valid(menu) and menu.get_parent() == null:
		menu.free()
	await process_frame
	_restore_file(save_path, save_backup)

	if failures.is_empty():
		print("MAIN_MENU_SAVE_SAFETY_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("MAIN_MENU_SAVE_SAFETY_FAIL failures=%d" % failures.size())
		quit(1)

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
