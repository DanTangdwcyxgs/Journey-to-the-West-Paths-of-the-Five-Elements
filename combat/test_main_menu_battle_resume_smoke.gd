extends SceneTree

## Real entry-to-battle smoke: MainMenu -> WUK-01 END -> WUK-02 battle ->
## BattleResolutionService -> production Journey scene -> after-battle dialogue -> save.
## Every user:// file touched by this test is backed up and restored.
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
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame
		menu.selected_character = "WUKONG"
		menu.call("_start_new_game")
		for _i in range(30):
			await process_frame
			if current_scene != menu:
				break

	var journey := current_scene as OriginSequenceJourneyScreen
	_record(journey != null, "new game should navigate to the production Journey scene")
	if journey != null:
		_record(FileAccess.file_exists(save_path), "new game should persist the narrative before transition")
		_record(journey.narrative.state.starting_character == "WUKONG", "Journey should load the selected Wukong route")
		journey.call("_advance_primary")
		for _i in range(5):
			if not is_instance_valid(journey) or journey.event_session == null:
				break
			journey.call("_advance_primary")
			await process_frame
		_record(journey.event_session == null, "WUK-01 END should finish through the Journey presentation path")
		var next_origin: Dictionary = journey.origin.get_current_chapter(journey.narrative, "WUKONG")
		_record(str(next_origin.get("id", "")) == "WUK-02", "WUK-01 completion should advance the real route cursor to WUK-02")

		journey.call("_advance_primary")
		for _i in range(8):
			if not is_instance_valid(journey):
				break
			journey.call("_advance_primary")
			await process_frame
			if current_scene != journey:
				break

	var battle := current_scene as BattleUI
	_record(battle != null, "WUK-02 production battle action should switch into BattleUI")
	if battle != null:
		_record(battle.encounter_type == "origin", "WUK-02 should use the Origin battle resolution path")
		_record(battle.encounter_id == "WUKONG_ORIGIN_WATER_CAVE", "WUK-02 should hand off the canonical Water Cave encounter")
		var handoff_before: Dictionary = BountyEncounterState.get_active_record()
		_record(not handoff_before.get("event_resume", {}).is_empty(), "battle handoff should persist EventSession resume context")
		_record(str(handoff_before.get("source_chapter_id", "")) == "WUK-02", "battle handoff should retain its source chapter")

		battle.call_deferred("_on_combat_finished", "allies")
		await process_frame
		await process_frame
		_record(battle.encounter_resolved, "production NarrativeBattleUI should atomically resolve victory")
		_record(battle.status_label.text.find("个人章节完成") >= 0, "victory UI should show personal chapter settlement")
		_record(battle.status_label.text.find("战后剧情") >= 0, "victory UI should direct the player to post-battle story")
		_record(battle.return_button != null and battle.return_button.text == "继续旅途", "victory button should return to Journey")

		if battle.return_button != null:
			battle.return_button.emit_signal("pressed")
			for _i in range(30):
				await process_frame
				if current_scene != battle:
					break

	var resumed := current_scene as OriginSequenceJourneyScreen
	_record(resumed != null, "victory continuation should return to the production Journey scene")
	if resumed != null:
		_record(resumed.event_session != null, "Journey should restore EventSession after the battle scene transition")
		if resumed.event_session != null:
			_record(resumed.event_session.sequence.get_id() == "WUK-02-SEQUENCE", "resume should restore WUK-02 rather than restart the chapter")
			var action: Dictionary = resumed.event_session.get_action()
			_record(str(action.get("kind", "")) == EventRunner.DIALOGUE, "battle resume should continue at after-battle dialogue")
			_record(str(action.get("text", "")).find("承担后果") >= 0, "resumed dialogue should be the canonical WUK-02 continuation")

		var persisted := NarrativeManager.new()
		_record(persisted.load(), "victory should persist a loadable narrative")
		if persisted.state != null:
			var after_victory_chapter: Dictionary = resumed.origin.get_current_chapter(persisted, "WUKONG")
			_record(str(after_victory_chapter.get("id", "")) == "WUK-03", "battle victory should advance the persisted route cursor to WUK-03")

		for _i in range(6):
			if not is_instance_valid(resumed) or resumed.event_session == null:
				break
			resumed.call("_advance_primary")
			await process_frame
		_record(resumed.event_session == null, "post-battle END should close the resumed sequence")
		_record(resumed.phase_label.text.find("战后剧情完成") >= 0, "Journey should show post-battle completion feedback")
		var persisted_after_end := NarrativeManager.new()
		_record(persisted_after_end.load(), "post-battle END should leave a loadable save")
		if persisted_after_end.state != null:
			var final_chapter: Dictionary = resumed.origin.get_current_chapter(persisted_after_end, "WUKONG")
			_record(str(final_chapter.get("id", "")) == "WUK-03", "END should preserve the next chapter cursor instead of advancing WUK-02 twice")

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
		print("MAIN_MENU_BATTLE_RESUME_SMOKE_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("MAIN_MENU_BATTLE_RESUME_SMOKE_FAIL failures=%d" % failures.size())
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
