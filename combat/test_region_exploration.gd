extends SceneTree

## Production WorldMap → Eagle Sorrow region → point discovery → save/reload → return.
## Region notes are optional world facts and may not advance the canonical Journey.
class ToggleSaveNarrativeManager:
	extends NarrativeManager

	var save_success: bool = false
	var save_attempts: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		return save_success

class IsolatedRegionExplorationScreen:
	extends RegionExplorationScreen

	func _ready() -> void:
		_initialize_region_screen(false)

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

	var region_manager := RegionExplorationManager.new()
	var definition := region_manager.get_region("EAGLE_SORROW")
	_record(not definition.is_empty(), "Eagle Sorrow should have a data-driven region definition")
	_record(region_manager.get_points("EAGLE_SORROW").size() == 3, "Eagle Sorrow should define three interactive points of interest")

	var fixture := NarrativeManager.new()
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the region exploration fixture")
	fixture.state.record_milestone("WUKONG_RECRUITED", 100)
	fixture.state.current_global_timeline = 105
	fixture.state.set_shared_chapter("SHARED-03-EAGLE-SORROW")
	fixture.state.completed_shared_chapters = [
		"SHARED-01-FIVE-ELEMENTS",
		"SHARED-02-EARLY-PILGRIMAGE"
	]
	fixture.state.add_world_node_visit("EAGLE_SORROW")
	_record(region_manager.can_enter(fixture, "EAGLE_SORROW"), "the optional Eagle Sorrow region should be available at timeline 105")
	var wrong_location := NarrativeManager.new()
	wrong_location.state = NarrativeState.from_dict(fixture.serialize())
	wrong_location.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")
	_record(not region_manager.can_enter(wrong_location, "EAGLE_SORROW"), "region entry must be bound to the current WorldMap location")
	_record(fixture.save(), "the starting region state should be persisted")

	var expected_chapter := fixture.state.current_shared_chapter
	var expected_timeline: int = fixture.state.current_global_timeline
	var expected_completed := fixture.state.completed_shared_chapters.duplicate(true)
	var expected_roster := fixture.state.recruited_characters.duplicate(true)

	var map_scene := load("res://ui/world_map.tscn") as PackedScene
	_record(map_scene != null, "production WorldMap scene should load")
	var world_map: WorldMapScreen = map_scene.instantiate() as WorldMapScreen if map_scene != null else null
	_record(world_map != null, "production WorldMap scene should instantiate")
	if world_map != null:
		root.add_child(world_map)
		current_scene = world_map
		await process_frame
		_record(world_map.region_button != null and world_map.region_button.visible, "WorldMap should show the region entry at Eagle Sorrow")
		_record(world_map.region_button != null and not world_map.region_button.disabled, "WorldMap region entry should be enabled after the timeline and location checks")
		if world_map.region_button != null:
			world_map.region_button.emit_signal("pressed")
			var region_screen: RegionExplorationScreen = await _wait_for_region()
			_record(region_screen != null, "the production region-entry button should open the RegionExploration scene")
			if region_screen != null:
				_record(region_screen.region_id == "EAGLE_SORROW", "the region screen should resolve its region from the persisted current location")
				_record(region_screen.point_list.get_item_count() == 3, "the production region screen should present its three points")
				var first_point_id := str(region_screen.point_list.get_item_metadata(0))
				region_screen.point_list.select(0)
				region_screen.call("_on_point_selected", 0)
				_record(not region_screen.inspect_button.disabled, "an undiscovered region point should be inspectable")
				region_screen.inspect_button.emit_signal("pressed")
				await process_frame

				_record(first_point_id in region_screen.narrative.state.get_world_state().get("discovered_region_points", []), "investigating a point should record its discovery marker")
				_record(region_screen.narrative.state.current_shared_chapter == expected_chapter, "region exploration must preserve the Shared chapter pointer")
				_record(region_screen.narrative.state.current_global_timeline == expected_timeline, "region exploration must not advance the global timeline")
				_record(region_screen.narrative.state.completed_shared_chapters == expected_completed, "region exploration must preserve completed Shared chapter history")
				_record(region_screen.narrative.state.recruited_characters == expected_roster, "region exploration must not change recruited characters")

				var reloaded := NarrativeManager.new()
				_record(reloaded.load(), "the region discovery should leave a loadable save")
				_record(first_point_id in reloaded.state.get_world_state().get("discovered_region_points", []), "the discovered point should survive a fresh NarrativeManager load")
				_record(region_screen.point_list.get_item_text(0).find("✓") >= 0, "the region list should reflect the committed discovery")
				_record(region_screen.inspect_button.disabled, "a committed point should no longer be repeatable")

				region_screen.return_button.emit_signal("pressed")
				world_map = await _wait_for_world_map()
				_record(world_map != null, "the production Return to World Map control should work")
				if world_map != null:
					_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "returning should preserve the current WorldMap location")
					_record(world_map.region_button.visible and not world_map.region_button.disabled, "the same region should remain available after returning")
					world_map.region_button.emit_signal("pressed")
					var reopened: RegionExplorationScreen = await _wait_for_region()
					_record(reopened != null, "the region should be reopenable after scene transition")
					if reopened != null:
						_record(reopened.point_list.get_item_text(0).find("✓") >= 0, "a discovery should remain visible after leaving and re-entering the region")
						reopened.return_button.emit_signal("pressed")
						world_map = await _wait_for_world_map()
						_record(world_map != null, "the player should be able to leave the region a second time")

	var persisted := NarrativeManager.new()
	_record(persisted.load(), "the successful production region pass should remain loadable for the rollback case")
	var failing_manager := ToggleSaveNarrativeManager.new()
	failing_manager.state = NarrativeState.from_dict(persisted.serialize())
	var isolated := IsolatedRegionExplorationScreen.new()
	isolated.narrative = failing_manager
	isolated.region_manager = RegionExplorationManager.new()
	isolated.world_map_manager = WorldMapManager.new()

	var old_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(old_scene):
		old_scene.free()
	await process_frame

	root.add_child(isolated)
	current_scene = isolated
	await process_frame
	_record(isolated.region_id == "EAGLE_SORROW", "the injected screen should initialize against the same current region")
	_record(isolated.point_list.get_item_count() == 3, "the injected screen should use the production point catalog")
	if isolated.point_list.get_item_count() > 1:
		isolated.point_list.select(1)
		isolated.call("_on_point_selected", 1)
		var retry_point_id := str(isolated.point_list.get_item_metadata(1))
		var before_failed_save: Dictionary = failing_manager.serialize().duplicate(true)
		_record(not isolated.inspect_button.disabled, "an undiscovered second point should be ready for the save-failure case")
		isolated.inspect_button.emit_signal("pressed")
		await process_frame

		_record(failing_manager.save_attempts == 1, "region discovery should attempt one save")
		_record(failing_manager.serialize() == before_failed_save, "a failed region save should restore the complete NarrativeState snapshot")
		_record(retry_point_id not in failing_manager.state.get_world_state().get("discovered_region_points", []), "failed save must roll back the discovery marker")
		_record(not isolated.inspect_button.disabled, "a failed save should leave the point retryable")
		_record(isolated.status_label.text.find("保存失败") >= 0, "a failed region save should be visible to the player")

		failing_manager.save_success = true
		isolated.inspect_button.emit_signal("pressed")
		await process_frame
		_record(failing_manager.save_attempts == 2, "retrying the region discovery should attempt a second save")
		_record(retry_point_id in failing_manager.state.get_world_state().get("discovered_region_points", []), "a successful retry should commit the discovery")
		_record(isolated.status_label.text.find("记录了断裂木牌的方位") >= 0, "successful interaction should show the point's authored feedback")
		_record(failing_manager.state.current_shared_chapter == expected_chapter, "the retry must preserve the canonical Shared chapter")
		_record(failing_manager.state.current_global_timeline == expected_timeline, "the retry must preserve the global timeline")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame

	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("REGION_EXPLORATION_SCENE_TREE_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("REGION_EXPLORATION_SCENE_TREE_FAIL failures=%d" % failures.size())
		quit(1)

func _wait_for_region() -> RegionExplorationScreen:
	for _frame in range(60):
		await process_frame
		if current_scene is RegionExplorationScreen:
			return current_scene as RegionExplorationScreen
	return null

func _wait_for_world_map() -> WorldMapScreen:
	for _frame in range(60):
		await process_frame
		if current_scene is WorldMapScreen:
			return current_scene as WorldMapScreen
	return null

func _capture_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"existed": false, "content": PackedByteArray()}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"existed": false, "content": PackedByteArray()}
	var content := file.get_buffer(file.get_length())
	file.close()
	return {"existed": true, "content": content}

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
