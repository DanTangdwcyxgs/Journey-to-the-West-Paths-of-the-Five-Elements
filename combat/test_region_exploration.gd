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
var current_stage := "initialization"
var test_finished := false
var watchdog_backups: Dictionary = {}

func _initialize() -> void:
	var watchdog := create_timer(45.0)
	watchdog.timeout.connect(_on_watchdog_timeout)
	await _run_smoke()

func _on_watchdog_timeout() -> void:
	if test_finished:
		return
	push_error("REGION_EXPLORATION_TEST_TIMEOUT stage=%s" % current_stage)
	for path_value in watchdog_backups.keys():
		_restore_file(str(path_value), watchdog_backups[path_value])
	quit(124)

func _run_smoke() -> void:
	current_stage = "start"
	print("REGION_EXPLORATION_STAGE 00 start")
	var save_path: String = NarrativeSave.SAVE_PATH
	var encounter_path: String = BountyEncounterState.PATH
	var resume_path: String = BountyEncounterState.RESUME_PATH
	var save_backup := _capture_file(save_path)
	var encounter_backup := _capture_file(encounter_path)
	var resume_backup := _capture_file(resume_path)
	watchdog_backups = {
		save_path: save_backup,
		encounter_path: encounter_backup,
		resume_path: resume_backup
	}
	_remove_file(save_path)
	_remove_file(encounter_path)
	_remove_file(resume_path)

	var region_manager := RegionExplorationManager.new()
	var definition := region_manager.get_region("EAGLE_SORROW")
	_record(not definition.is_empty(), "Eagle Sorrow should have a data-driven region definition")
	_record(region_manager.get_points("EAGLE_SORROW").size() == 3, "Eagle Sorrow should define three interactive points of interest")
	var mountain_definition := region_manager.get_region("FIVE_ELEMENTS_MOUNTAIN")
	_record(not mountain_definition.is_empty(), "Five Elements Mountain should have a data-driven region definition")
	_record(region_manager.get_points("FIVE_ELEMENTS_MOUNTAIN").size() == 3, "Five Elements Mountain should define three interactive points of interest")

	var fixture := NarrativeManager.new()
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the region exploration fixture")
	_record(fixture.encounter_character("TANG"), "Tang should be present in the canonical shared-party fixture")
	_record(fixture.encounter_character("WUKONG"), "Wukong should be present before the first shared journey region")
	fixture.state.record_milestone("WUKONG_RECRUITED", 100)
	fixture.state.mark_route_complete("WUKONG")
	fixture.state.current_global_timeline = 105
	fixture.state.set_current_shared_chapter("SHARED-03-EAGLE-SORROW")
	fixture.state.completed_chapters = [
		"WUKONG-ORIGIN",
		"SHARED-01-FIVE-ELEMENTS",
		"SHARED-02-EARLY-PILGRIMAGE"
	]
	fixture.state.completed_shared_chapters = [
		"SHARED-01-FIVE-ELEMENTS",
		"SHARED-02-EARLY-PILGRIMAGE"
	]
	fixture.state.add_world_node_visit("EAGLE_SORROW")
	_record(region_manager.can_enter(fixture, "EAGLE_SORROW"), "the optional Eagle Sorrow region should be available at timeline 105")
	var early_timeline := NarrativeManager.new()
	early_timeline.state = NarrativeState.from_dict(fixture.serialize())
	early_timeline.state.current_global_timeline = 104
	_record(not region_manager.can_enter(early_timeline, "EAGLE_SORROW"), "region entry must respect its timeline gate")
	var wrong_location := NarrativeManager.new()
	wrong_location.state = NarrativeState.from_dict(fixture.serialize())
	wrong_location.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")
	_record(not region_manager.can_enter(wrong_location, "EAGLE_SORROW"), "region entry must be bound to the current WorldMap location")
	_record(region_manager.can_enter(wrong_location, "FIVE_ELEMENTS_MOUNTAIN"), "Five Elements Mountain should be available at its own current location")
	var mountain_early := NarrativeManager.new()
	mountain_early.state = NarrativeState.from_dict(fixture.serialize())
	mountain_early.state.current_global_timeline = 99
	mountain_early.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")
	_record(not region_manager.can_enter(mountain_early, "FIVE_ELEMENTS_MOUNTAIN"), "Five Elements Mountain should respect its own timeline gate")
	var mountain_no_milestone := NarrativeManager.new()
	mountain_no_milestone.state = NarrativeState.from_dict(fixture.serialize())
	mountain_no_milestone.state.completed_milestones.erase("WUKONG_RECRUITED")
	mountain_no_milestone.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")
	_record(not region_manager.can_enter(mountain_no_milestone, "FIVE_ELEMENTS_MOUNTAIN"), "Five Elements Mountain should require the Wukong recruitment milestone")
	_record(fixture.save(), "the starting region state should be persisted")
	current_stage = "fixture_saved"
	print("REGION_EXPLORATION_STAGE 01 fixture_saved")

	var expected_chapter := fixture.state.current_shared_chapter
	var expected_timeline: int = fixture.state.current_global_timeline
	var expected_completed := fixture.state.completed_shared_chapters.duplicate(true)
	var expected_completed_chapters := fixture.state.completed_chapters.duplicate(true)
	var expected_roster := fixture.state.recruited_characters.duplicate(true)

	var map_scene := load("res://ui/world_map.tscn") as PackedScene
	_record(map_scene != null, "production WorldMap scene should load")
	var world_map: WorldMapScreen = map_scene.instantiate() as WorldMapScreen if map_scene != null else null
	_record(world_map != null, "production WorldMap scene should instantiate")
	if world_map != null:
		root.add_child(world_map)
		current_scene = world_map
		await process_frame
		current_stage = "world_map_ready"
		print("REGION_EXPLORATION_STAGE 02 world_map_ready")
		_record(world_map.region_button != null and world_map.region_button.visible, "WorldMap should show the region entry at Eagle Sorrow")
		_record(world_map.region_button != null and not world_map.region_button.disabled, "WorldMap region entry should be enabled after the timeline and location checks")
		if world_map.region_button != null:
			world_map.region_button.emit_signal("pressed")
			var region_screen: RegionExplorationScreen = await _wait_for_region()
			current_stage = "first_region_scene_wait_finished"
			print("REGION_EXPLORATION_STAGE 03 region_scene_wait_finished")
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
				_record(region_screen.narrative.state.completed_chapters == expected_completed_chapters, "region exploration must preserve completed chapter history")
				_record(region_screen.narrative.state.recruited_characters == expected_roster, "region exploration must not change recruited characters")

				current_stage = "first_point_saved"
				print("REGION_EXPLORATION_STAGE 04 first_point_saved")
				var reloaded := NarrativeManager.new()
				_record(reloaded.load(), "the region discovery should leave a loadable save")
				_record(first_point_id in reloaded.state.get_world_state().get("discovered_region_points", []), "the discovered point should survive a fresh NarrativeManager load")
				_record(region_screen.point_list.get_item_text(0).find("✓") >= 0, "the region list should reflect the committed discovery")
				_record(region_screen.inspect_button.disabled, "a committed point should no longer be repeatable")

				region_screen.return_button.emit_signal("pressed")
				world_map = await _wait_for_world_map()
				current_stage = "world_map_returned"
				print("REGION_EXPLORATION_STAGE 05 world_map_returned")
				_record(world_map != null, "the production Return to World Map control should work")
				if world_map != null:
					_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "returning should preserve the current WorldMap location")
					_record(world_map.region_button.visible and not world_map.region_button.disabled, "the same region should remain available after returning")
					world_map.region_button.emit_signal("pressed")
					var reopened: RegionExplorationScreen = await _wait_for_region()
					current_stage = "region_reopened"
					print("REGION_EXPLORATION_STAGE 06 region_reopened")
					_record(reopened != null, "the region should be reopenable after scene transition")
					if reopened != null:
						_record(reopened.point_list.get_item_text(0).find("✓") >= 0, "a discovery should remain visible after leaving and re-entering the region")
						reopened.return_button.emit_signal("pressed")
						world_map = await _wait_for_world_map()
						_record(world_map != null, "the player should be able to leave the region a second time")
						if world_map != null:
							var mountain_index := _find_node_by_label(world_map, "五行山")
							_record(mountain_index >= 0, "Five Elements Mountain should be reachable from Eagle Sorrow")
							if mountain_index >= 0:
								world_map.call("_on_node_selected", mountain_index)
								world_map.travel_button.emit_signal("pressed")
								await process_frame
								current_stage = "arrived_five_elements_mountain"
								print("REGION_EXPLORATION_STAGE 10 arrived_five_elements_mountain")
								_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "FIVE_ELEMENTS_MOUNTAIN", "production WorldMap travel should reach Five Elements Mountain")
								_record(world_map.region_button.visible and not world_map.region_button.disabled, "Five Elements Mountain region entry should appear and pass its gates")
								world_map.region_button.emit_signal("pressed")
								var mountain_screen: RegionExplorationScreen = await _wait_for_region()
								current_stage = "five_elements_region_opened"
								print("REGION_EXPLORATION_STAGE 11 five_elements_region_opened")
								_record(mountain_screen != null, "the same production region scene should open at Five Elements Mountain")
								if mountain_screen != null:
									_record(mountain_screen.region_id == "FIVE_ELEMENTS_MOUNTAIN", "region scene should resolve the mountain definition by current location")
									_record(mountain_screen.point_list.get_item_count() == 3, "Five Elements Mountain screen should render all three authored points")
									var mountain_point_id := str(mountain_screen.point_list.get_item_metadata(0))
									mountain_screen.point_list.select(0)
									mountain_screen.call("_on_point_selected", 0)
									mountain_screen.inspect_button.emit_signal("pressed")
									await process_frame
									_record(mountain_point_id in mountain_screen.narrative.state.get_world_state().get("discovered_region_points", []), "mountain point inspection should persist its discovery")
									_record(mountain_screen.narrative.state.current_shared_chapter == expected_chapter, "mountain exploration must preserve the canonical Shared chapter")
									_record(mountain_screen.narrative.state.current_global_timeline == expected_timeline, "mountain exploration must not advance global timeline")
									_record(mountain_screen.narrative.state.completed_shared_chapters == expected_completed, "mountain exploration must preserve completed Shared history")
									_record(mountain_screen.narrative.state.completed_chapters == expected_completed_chapters, "mountain exploration must preserve completed chapter history")
									_record(mountain_screen.narrative.state.recruited_characters == expected_roster, "mountain exploration must not change the recruited roster")
									var mountain_reloaded := NarrativeManager.new()
									_record(mountain_reloaded.load(), "mountain exploration should leave a loadable save")
									_record(mountain_point_id in mountain_reloaded.state.get_world_state().get("discovered_region_points", []), "mountain point discovery should persist across a fresh load")
									mountain_screen.return_button.emit_signal("pressed")
									world_map = await _wait_for_world_map()
									_record(world_map != null, "returning from Five Elements Mountain should reopen WorldMap")
									if world_map != null:
										_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "FIVE_ELEMENTS_MOUNTAIN", "returning from mountain exploration should preserve its map location")
										var eagle_index := _find_node_by_label(world_map, "鹰愁涧")
										_record(eagle_index >= 0, "Eagle Sorrow should remain reachable from Five Elements Mountain")
										if eagle_index >= 0:
											world_map.call("_on_node_selected", eagle_index)
											world_map.travel_button.emit_signal("pressed")
											await process_frame
											_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "the test should return to Eagle Sorrow before the save-failure rollback fixture")

	# Black Wind is the next coherent Shared Journey region after Longma's recruitment.
	# Use a separate post-recruitment fixture, then restore the exact pre-test save.
	if world_map != null:
		var baseline_for_black_wind := NarrativeManager.new()
		_record(baseline_for_black_wind.load(), "the pre-Black-Wind state should load")
		var black_wind_region_manager := RegionExplorationManager.new()
		var black_wind_definition := black_wind_region_manager.get_region("BLACK_WIND_NORTH_PATH")
		_record(not black_wind_definition.is_empty(), "Black Wind North Path should have a data-driven region definition")
		_record(black_wind_region_manager.get_points("BLACK_WIND_NORTH_PATH").size() == 3, "Black Wind North Path should define three authored points")

		var black_wind_timeline_locked := NarrativeManager.new()
		black_wind_timeline_locked.state = NarrativeState.from_dict(baseline_for_black_wind.serialize())
		black_wind_timeline_locked.state.current_global_timeline = 119
		black_wind_timeline_locked.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
		black_wind_timeline_locked.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
		_record(not black_wind_region_manager.can_enter(black_wind_timeline_locked, "BLACK_WIND_NORTH_PATH"), "Black Wind entry must respect the timeline 120 gate")

		var black_wind_milestone_locked := NarrativeManager.new()
		black_wind_milestone_locked.state = NarrativeState.from_dict(baseline_for_black_wind.serialize())
		black_wind_milestone_locked.state.current_global_timeline = 120
		black_wind_milestone_locked.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
		_record(not black_wind_region_manager.can_enter(black_wind_milestone_locked, "BLACK_WIND_NORTH_PATH"), "Black Wind entry must require Longma recruitment")

		# Simulate the already-recruited Longma at the next canonical chapter without
		# altering the fixture used by the earlier timeline-105 regressions.
		world_map.narrative.state.current_global_timeline = 120
		world_map.narrative.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
		world_map.narrative.encounter_character("LONGMA")
		world_map.narrative.state.set_current_shared_chapter("SHARED-04-EARLY-DEMON-TALES")
		world_map.narrative.state.completed_chapters.append("SHARED-03-EAGLE-SORROW")
		world_map.narrative.state.completed_shared_chapters.append("SHARED-03-EAGLE-SORROW")
		_record(world_map.narrative.save(), "the post-Longma fixture should be persisted before testing Black Wind entry")
		world_map.call("_refresh")
		await process_frame

		var black_wind_index := _find_node_by_label(world_map, "黑风山北道")
		_record(black_wind_index >= 0, "Black Wind North Path should be reachable after Longma recruitment")
		if black_wind_index >= 0:
			world_map.call("_on_node_selected", black_wind_index)
			world_map.travel_button.emit_signal("pressed")
			await process_frame
			_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "BLACK_WIND_NORTH_PATH", "production WorldMap travel should reach Black Wind North Path")
			_record(world_map.region_button.visible and not world_map.region_button.disabled, "Black Wind region entry should appear only after its timeline and milestone gates pass")
			world_map.region_button.emit_signal("pressed")
			var black_wind_screen: RegionExplorationScreen = await _wait_for_region()
			_record(black_wind_screen != null, "the production WorldMap button should open the Black Wind region")
			if black_wind_screen != null:
				_record(black_wind_screen.region_id == "BLACK_WIND_NORTH_PATH", "region screen should resolve the Black Wind definition from the current location")
				_record(black_wind_screen.point_list.get_item_count() == 3, "Black Wind region should render all three authored points")
				var black_wind_point_id := str(black_wind_screen.point_list.get_item_metadata(0))
				var black_wind_chapter_before := black_wind_screen.narrative.state.current_shared_chapter
				var black_wind_timeline_before: int = black_wind_screen.narrative.state.current_global_timeline
				var black_wind_completed_before := black_wind_screen.narrative.state.completed_shared_chapters.duplicate(true)
				var black_wind_chapters_before := black_wind_screen.narrative.state.completed_chapters.duplicate(true)
				var black_wind_roster_before := black_wind_screen.narrative.state.recruited_characters.duplicate(true)
				black_wind_screen.point_list.select(0)
				black_wind_screen.call("_on_point_selected", 0)
				_record(not black_wind_screen.inspect_button.disabled, "an undiscovered Black Wind point should be inspectable")
				black_wind_screen.inspect_button.emit_signal("pressed")
				await process_frame
				_record(black_wind_point_id in black_wind_screen.narrative.state.get_world_state().get("discovered_region_points", []), "Black Wind point inspection should record its discovery")
				_record(black_wind_screen.narrative.state.current_shared_chapter == black_wind_chapter_before, "Black Wind exploration must preserve the canonical Shared chapter pointer")
				_record(black_wind_screen.narrative.state.current_global_timeline == black_wind_timeline_before, "Black Wind exploration must not advance the global timeline")
				_record(black_wind_screen.narrative.state.completed_shared_chapters == black_wind_completed_before, "Black Wind exploration must preserve completed Shared history")
				_record(black_wind_screen.narrative.state.completed_chapters == black_wind_chapters_before, "Black Wind exploration must preserve completed chapter history")
				_record(black_wind_screen.narrative.state.recruited_characters == black_wind_roster_before, "Black Wind exploration must preserve the recruited roster")
				var black_wind_reloaded := NarrativeManager.new()
				_record(black_wind_reloaded.load(), "Black Wind discovery should leave a loadable save")
				_record(black_wind_point_id in black_wind_reloaded.state.get_world_state().get("discovered_region_points", []), "Black Wind discovery should survive fresh NarrativeManager load")

				black_wind_screen.return_button.emit_signal("pressed")
				world_map = await _wait_for_world_map()
				_record(world_map != null, "returning from Black Wind should reopen WorldMap")
				if world_map != null:
					_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "BLACK_WIND_NORTH_PATH", "returning should preserve the Black Wind map location")
					var return_eagle_index := _find_node_by_label(world_map, "鹰愁涧")
					_record(return_eagle_index >= 0, "Eagle Sorrow should remain reachable after optional Black Wind exploration")
					if return_eagle_index >= 0:
						world_map.call("_on_node_selected", return_eagle_index)
						world_map.travel_button.emit_signal("pressed")
						await process_frame
						_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "the regression should return to Eagle Sorrow after Black Wind exploration")

		# Restore the pre-Black-Wind save so the existing rollback test still checks
		# the original timeline-105 Eagle Sorrow fixture exactly.
		if current_scene is WorldMapScreen:
			world_map = current_scene as WorldMapScreen
			world_map.narrative.restore_snapshot(baseline_for_black_wind.serialize())
			_record(world_map.narrative.save(), "the original region-test save should be restored after Black Wind regression")
			world_map.call("_refresh")


	var persisted := NarrativeManager.new()
	_record(persisted.load(), "the successful production region pass should remain loadable for the rollback case")
	current_stage = "persisted_reload"
	print("REGION_EXPLORATION_STAGE 07 persisted_reload")
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
	current_stage = "isolated_ready"
	print("REGION_EXPLORATION_STAGE 08 isolated_ready")
	_record(isolated.region_id == "EAGLE_SORROW", "the injected screen should initialize against the same current region")
	_record(isolated.point_list != null, "the injected screen should build its point list")
	if isolated.point_list != null:
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
			_record(failing_manager.state.completed_shared_chapters == expected_completed, "the retry must preserve completed Shared history")
			_record(failing_manager.state.recruited_characters == expected_roster, "the retry must preserve the recruited roster")
			_record(failing_manager.state.current_global_timeline == expected_timeline, "the retry must preserve the global timeline")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame

	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)
	current_stage = "cleanup_complete"
	print("REGION_EXPLORATION_STAGE 09 cleanup_complete")

	test_finished = true
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

func _find_node_by_label(world_map: WorldMapScreen, label: String) -> int:
	if world_map == null or world_map.node_list == null:
		return -1
	for index in range(world_map.node_list.get_item_count()):
		if world_map.node_list.get_item_text(index).find(label) >= 0:
			return index
	return -1

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
