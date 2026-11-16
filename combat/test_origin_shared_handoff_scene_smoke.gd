extends SceneTree

## Production scene smoke for later-start Origin routes entering their first Shared sequence.
## Each case persists an Origin -> Shared handoff, continues through MainMenu,
## starts the real Shared EventSequence, and commits its first story MOVE.

const CASES := [
	{"character":"LONGMA","chapter":"SHARED-03-EAGLE-SORROW","sequence":"SHARED-03-EAGLE-SORROW-SEQUENCE","location":"EAGLE_SORROW","next_node":"EAGLE_SORROW"},
	{"character":"BAJIE","chapter":"SHARED-05-GAOJIAZHUANG","sequence":"SHARED-05-GAOJIAZHUANG-SEQUENCE","location":"GAOJIAZHUANG","next_node":"BLACK_WIND_NORTH_PATH"},
	{"character":"WUJING","chapter":"SHARED-07-FLOWING-SANDS","sequence":"SHARED-07-FLOWING-SANDS-SEQUENCE","location":"FLOWING_SANDS","next_node":"GAOJIAZHUANG"},
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

	var completed_cases := 0
	for case_variant in CASES:
		var spec: Dictionary = case_variant
		var character := str(spec["character"])
		var chapter_id := str(spec["chapter"])
		var fixture := _prepare_handoff(character)
		_record(fixture != null, "%s Origin should finish and produce a Shared handoff save" % character)
		if fixture == null:
			break
		_record(fixture.state.current_shared_chapter == chapter_id, "%s handoff should target %s" % [character, chapter_id])
		_record(fixture.save(), "%s handoff fixture should persist before MainMenu Continue" % character)

		var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
		_record(menu_scene != null, "production MainMenu scene should load")
		var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
		_record(menu != null, "production MainMenu should instantiate")
		if menu == null:
			break
		root.add_child(menu)
		current_scene = menu
		await process_frame
		_record(not menu.continue_button.disabled, "%s Continue should be enabled for the saved handoff" % character)
		if menu.continue_button.disabled:
			break
		menu.continue_button.emit_signal("pressed")

		var journey := await _wait_for_journey()
		_record(journey != null, "%s MainMenu Continue should load production Journey" % character)
		if journey == null:
			break
		_record(journey.narrative.state.starting_character == character, "%s Journey should preserve its starting-character identity" % character)
		_record(journey.narrative.state.current_shared_chapter == chapter_id, "%s Journey should resume at %s" % [character, chapter_id])

		journey.call("_advance_primary")
		_record(journey.event_session != null, "%s Journey should start its first Shared EventSequence" % character)
		if journey.event_session == null:
			break
		_record(journey.event_session.sequence.get_id() == str(spec["sequence"]), "%s should load the expected production sequence" % character)
		var first_action: Dictionary = journey.event_session.get_action()
		_record(str(first_action.get("kind", "")) == EventRunner.DIALOGUE, "%s Shared sequence should begin with canonical dialogue" % character)
		if str(first_action.get("kind", "")) != EventRunner.DIALOGUE:
			break

		journey.call("_reveal_dialogue_immediately")
		journey.call("_advance_primary")
		var move_action: Dictionary = journey.event_session.get_action()
		_record(str(move_action.get("kind", "")) == EventRunner.MOVE, "%s Shared sequence should reach its first canonical MOVE" % character)
		if str(move_action.get("kind", "")) != EventRunner.MOVE:
			break
		_record(str(move_action.get("marker_id", "")) == str(spec["location"]), "%s MOVE should target its canonical story location" % character)

		journey.call("_advance_primary")
		var moved := false
		for _frame in range(120):
			await process_frame
			if current_scene != journey:
				break
			var world_state: Dictionary = journey.narrative.state.get_world_state()
			if str(world_state.get("current_location", "")) == str(spec["location"]) and not journey.event_transition_pending:
				moved = true
				break
		_record(moved, "%s production MOVE should commit its story-established map location" % character)
		if moved:
			var moved_world: Dictionary = journey.narrative.state.get_world_state()
			_record(str(moved_world.get("current_location", "")) == str(spec["location"]), "%s current location should match the canonical MOVE" % character)
			_record(str(spec["location"]) in moved_world.get("visited_nodes", []), "%s MOVE should persist the visited-node fact" % character)
			_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.CHOICE, "%s EventSequence should resume at its recruitment choice after MOVE" % character)
			_record(journey.narrative.state.current_shared_chapter == chapter_id, "%s MOVE alone must not complete its Shared chapter" % character)
			var reloaded := NarrativeManager.new()
			_record(reloaded.load(), "%s MOVE should leave a loadable save" % character)
			if reloaded.state != null:
				_record(reloaded.state.get_world_state().get("current_location", "") == str(spec["location"]), "%s story location should persist after reload" % character)
				_record(reloaded.state.current_shared_chapter == chapter_id, "%s story MOVE must preserve the current Shared chapter" % character)

			var world_map := WorldMapManager.new()
			_record(world_map.can_visit(journey.narrative, str(spec["next_node"])), "%s should satisfy the next route-appropriate WorldMap gate" % character)

		completed_cases += 1
		var active_scene: Node = current_scene
		current_scene = null
		if is_instance_valid(active_scene):
			active_scene.free()
		await process_frame

	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty() and completed_cases == CASES.size():
		print("ORIGIN_SHARED_HANDOFF_SCENE_SMOKE_PASS cases=%d" % completed_cases)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		if completed_cases != CASES.size():
			push_error("ORIGIN_SHARED_HANDOFF_SCENE_SMOKE_INCOMPLETE cases=%d/%d" % [completed_cases, CASES.size()])
		print("ORIGIN_SHARED_HANDOFF_SCENE_SMOKE_FAIL failures=%d" % failures.size())
		quit(1)

func _prepare_handoff(character_id: String) -> NarrativeManager:
	var narrative := NarrativeManager.new()
	if not narrative.start_new_game(character_id):
		_record(false, "%s Origin should initialize" % character_id)
		return null
	var guard := 0
	while not narrative.origin_routes.is_complete(narrative, character_id):
		guard += 1
		if guard >= 64:
			_record(false, "%s Origin should complete within the chapter guard" % character_id)
			return null
		if narrative.complete_origin_chapter(character_id).is_empty():
			_record(false, "%s Origin chapter progression should remain valid" % character_id)
			return null
	if not narrative.handoff_origin_to_shared(character_id):
		_record(false, "%s Origin should reconcile into Shared Journey" % character_id)
		return null
	return narrative

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
