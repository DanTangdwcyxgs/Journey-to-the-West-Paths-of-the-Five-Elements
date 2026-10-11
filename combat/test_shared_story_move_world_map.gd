extends SceneTree

## Production Shared-04 story MOVE should update the current World Map location,
## persist it, and expose connected exploration nodes in the real WorldMap UI.
## All user:// handoff/save files are backed up and restored.

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
	_record(fixture.start_new_game("WUKONG"), "Wukong route should initialize the Shared-04 move fixture")
	fixture.encounter_character("TANG")
	fixture.encounter_character("WUKONG")
	fixture.state.mark_route_complete("WUKONG")
	fixture.state.record_milestone("WUKONG_RECRUITED", 100)
	fixture.state.current_global_timeline = 120
	fixture.state.set_current_shared_chapter("SHARED-04-EARLY-DEMON-TALES")
	for chapter_id in ["SHARED-01-FIVE-ELEMENTS", "SHARED-02-EARLY-PILGRIMAGE", "SHARED-03-EAGLE-SORROW"]:
		if chapter_id not in fixture.state.completed_shared_chapters:
			fixture.state.completed_shared_chapters.append(chapter_id)
	fixture.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")
	_record(fixture.save(), "Shared-04 canonical prerequisite save should be written")

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu != null:
		root.add_child(menu)
		current_scene = menu
		await process_frame
		_record(not menu.continue_button.disabled, "Continue should be enabled for Shared-04 fixture")
		menu.continue_button.emit_signal("pressed")

	var journey: JourneyScreen = await _wait_for_journey()
	_record(journey != null, "MainMenu Continue should load the production Journey screen")
	if journey != null:
		journey.call("_advance_primary")
		_record(journey.event_session != null, "Journey should create the Shared-04 EventSession")
		if journey.event_session != null:
			_record(journey.event_session.sequence.get_id() == "SHARED-04-EARLY-DEMON-TALES-SEQUENCE", "production Journey should start the canonical Shared-04 sequence")
			var reached_move := false
			for _step in range(32):
				if journey.event_session == null:
					break
				var action: Dictionary = journey.event_session.get_action()
				var kind := str(action.get("kind", ""))
				if kind == EventRunner.MOVE:
					reached_move = true
					journey.call("_advance_primary")
					break
				if kind != EventRunner.DIALOGUE:
					_record(false, "Shared-04 pre-move path should contain only dialogue: %s" % kind)
					break
				journey.call("_advance_primary")
				await process_frame
			_record(reached_move, "Shared-04 dialogue should reach its canonical MOVE node")

			var move_committed := false
			for _frame in range(90):
				await process_frame
				if journey.narrative.state.get_world_state().get("current_location", "") == "BLACK_WIND_NORTH_PATH":
					move_committed = true
					break
				if current_scene != journey:
					break
			_record(move_committed, "finishing the MOVE transition should write the Black Wind North Path location")
			var moved_world: Dictionary = journey.narrative.state.get_world_state()
			_record("BLACK_WIND_NORTH_PATH" in moved_world.get("visited_nodes", []), "story movement should record the destination in visited_nodes")
			_record("BLACK_WIND_NORTH_PATH" in moved_world.get("discovered_nodes", []), "story movement should record the destination in discovered_nodes")
			_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "EventSession should advance only after the location save succeeds")

			var reloaded := NarrativeManager.new()
			_record(reloaded.load(), "story-move save should reload")
			if reloaded.state != null:
				_record(reloaded.state.get_world_state().get("current_location", "") == "BLACK_WIND_NORTH_PATH", "Black Wind North Path should persist after reload")
				_record(reloaded.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "movement save should not complete Shared-04 by itself")

			journey.world_button.emit_signal("pressed")
			var world_map: WorldMapScreen = await _wait_for_world_map()
			_record(world_map != null, "Journey Map button should load the production WorldMap scene")
			if world_map != null:
				_record(world_map.status_label.text.find("黑风山北道") >= 0, "WorldMap status should show the story-established current location")
				var eagle_index := -1
				for index in range(world_map.node_list.get_item_count()):
					if world_map.node_list.get_item_text(index).find("鹰愁涧") >= 0:
						eagle_index = index
						break
				_record(eagle_index >= 0, "Eagle Sorrow should be available as a connected exploration node")
				if eagle_index >= 0:
					world_map.node_list.select(eagle_index)
					world_map.call("_on_node_selected", eagle_index)
					_record(not world_map.travel_button.disabled, "connected Eagle Sorrow node should be travelable")
					world_map.travel_button.emit_signal("pressed")
					await process_frame
					_record(world_map.narrative.state.get_world_state().get("current_location", "") == "EAGLE_SORROW", "real WorldMap travel should move the player from North Path to Eagle Sorrow")
					var map_save := NarrativeManager.new()
					_record(map_save.load(), "WorldMap exploration travel should save")
					if map_save.state != null:
						_record(map_save.state.get_world_state().get("current_location", "") == "EAGLE_SORROW", "Eagle Sorrow travel should persist after reload")
						_record("EAGLE_SORROW" in map_save.state.get_world_state().get("visited_nodes", []), "Eagle Sorrow travel should append the visited-node record")

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
		print("SHARED_STORY_MOVE_WORLDMAP_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("SHARED_STORY_MOVE_WORLDMAP_FAIL failures=%d" % failures.size())
		quit(1)

func _wait_for_journey() -> JourneyScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is JourneyScreen:
			return current_scene as JourneyScreen
	return null

func _wait_for_world_map() -> WorldMapScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is WorldMapScreen:
			return current_scene as WorldMapScreen
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
