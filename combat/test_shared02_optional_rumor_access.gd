extends SceneTree

## Shared-02 ends at timeline 105. The production map must allow the promised
## optional Eagle Sorrow rumor detour before the canonical Shared-03 sequence.
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
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the post-Shared-02 fixture")
	fixture.encounter_character("TANG")
	fixture.encounter_character("WUKONG")
	fixture.state.record_milestone("WUKONG_RECRUITED", 100)
	fixture.state.current_global_timeline = 105
	fixture.state.set_current_shared_chapter("SHARED-03-EAGLE-SORROW")
	fixture.state.completed_shared_chapters = ["SHARED-01-FIVE-ELEMENTS", "SHARED-02-EARLY-PILGRIMAGE"]
	fixture.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")
	_record(fixture.save(), "post-Shared-02 state should be saved before opening WorldMap")

	var expected_completed := fixture.state.completed_shared_chapters.duplicate()
	var map_scene := load("res://ui/world_map.tscn") as PackedScene
	_record(map_scene != null, "production WorldMap scene should load")
	var world_map: WorldMapScreen = map_scene.instantiate() as WorldMapScreen if map_scene != null else null
	_record(world_map != null, "production WorldMap scene should instantiate")
	if world_map != null:
		root.add_child(world_map)
		current_scene = world_map
		await process_frame

		_record(world_map.status_label.text.find("五行山") >= 0, "the optional detour should begin from the saved Five Elements Mountain location")
		var eagle_index := _find_node(world_map, "鹰愁涧")
		_record(eagle_index >= 0, "Eagle Sorrow should be reachable at timeline 105 after Shared-02")
		if eagle_index >= 0:
			world_map.node_list.select(eagle_index)
			world_map.call("_on_node_selected", eagle_index)
			_record(not world_map.travel_button.disabled, "Eagle Sorrow travel should be enabled before Shared-03")
			world_map.travel_button.emit_signal("pressed")
			await process_frame
			_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "the real map control should travel to Eagle Sorrow before Longma recruitment")
			_record(world_map.rumor_list.get_item_count() > 0, "Yellow Fang rumor should be visible at the post-Shared-02 timeline")
			if world_map.rumor_list.get_item_count() > 0:
				world_map.rumor_list.select(0)
				world_map.rumor_button.emit_signal("pressed")
				await process_frame
				_record("RUMOR_YELLOW_FANG" in world_map.narrative.state.get_world_state().get("heard_rumors", []), "hearing the optional rumor should persist its heard marker")
				_record("BOUNTY_YELLOW_FANG" in world_map.narrative.state.get_world_state().get("discovered_bounties", []), "hearing the rumor should discover the optional bounty")
			_record(not world_map.bounty_button.disabled, "the discovered optional bounty should be challengeable at Eagle Sorrow")
			_record(world_map.bounty_label.text.find("不推进西游主线") >= 0, "the UI should keep the optional bounty explicitly separate from mainline progression")

			var optional_challenge_button := world_map.bounty_button
			optional_challenge_button.emit_signal("pressed")
			var battle := await _wait_for_battle()
			_record(battle != null, "the optional bounty should launch the production BattleUI before Shared-03")
			if battle != null:
				_record(battle.encounter_type == "bounty", "the early optional fight should use the bounty resolution path")
				_record(battle.encounter_id == "BOUNTY_YELLOW_FANG", "the early optional fight should retain the optional Yellow Fang ID")
				battle.call_deferred("_on_combat_finished", "allies")
				for _frame in range(12):
					await process_frame
					if battle.encounter_resolved:
						break
				_record(battle.encounter_resolved, "the optional bounty should resolve through the production victory callback")
				_record(battle.return_button != null and battle.return_button.text == "返回地图", "the optional fight should return to WorldMap, not advance Journey")
				if battle.return_button != null:
					battle.return_button.emit_signal("pressed")
					world_map = await _wait_for_world_map()
					_record(world_map != null, "optional bounty victory should return to the production WorldMap")
					if world_map != null:
						_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "optional bounty return should preserve Eagle Sorrow")
						_record(world_map.narrative.state.current_global_timeline == 105, "optional bounty victory before Shared-03 must not advance the global timeline")
						_record(world_map.narrative.state.current_shared_chapter == "SHARED-03-EAGLE-SORROW", "optional bounty victory must leave Shared-03 as the next canonical chapter")
						_record("BOUNTY_YELLOW_FANG" in world_map.narrative.state.get_journey_log().get("defeated_targets", []), "optional bounty victory should record only its own defeated-target ID")

			var persisted := NarrativeManager.new()
			_record(persisted.load(), "the early optional exploration should leave a reloadable save")
			if persisted.state != null:
				_record(persisted.state.current_global_timeline == 105, "optional rumor discovery must not advance global chronology")
				_record(persisted.state.current_shared_chapter == "SHARED-03-EAGLE-SORROW", "optional rumor discovery must preserve the next canonical chapter")
				_record(persisted.state.completed_shared_chapters == expected_completed, "optional rumor discovery must not complete or skip Shared-03")
				_record(str(persisted.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "Eagle Sorrow location should survive save reload")

	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("SHARED02_OPTIONAL_RUMOR_ACCESS_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("SHARED02_OPTIONAL_RUMOR_ACCESS_FAIL failures=%d" % failures.size())
		quit(1)

func _find_node(world_map: WorldMapScreen, label: String) -> int:
	for index in range(world_map.node_list.get_item_count()):
		if world_map.node_list.get_item_text(index).find(label) >= 0:
			return index
	return -1

func _wait_for_battle() -> BattleUI:
	for _frame in range(45):
		await process_frame
		if current_scene is BattleUI:
			return current_scene as BattleUI
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
