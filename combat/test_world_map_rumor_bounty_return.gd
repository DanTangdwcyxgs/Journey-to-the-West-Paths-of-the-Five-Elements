extends SceneTree

## Production WorldMap -> rumor -> optional bounty -> WorldMap -> Journey -> Shared-05.
## The bounty must not advance the fixed Shared Journey chronology.
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
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the optional-bounty fixture")
	fixture.encounter_character("TANG")
	fixture.encounter_character("WUKONG")
	var longma_memories: Array[String] = ["LONGMA-01", "LONGMA-02"]
	_record(fixture.encounter_character("LONGMA", longma_memories), "canonical starting state should already include recruited Longma")
	fixture.state.mark_route_complete("WUKONG")
	fixture.state.record_milestone("WUKONG_RECRUITED", 100)
	fixture.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
	fixture.state.current_global_timeline = 120
	fixture.state.set_current_shared_chapter("SHARED-05-GAOJIAZHUANG")
	for chapter_id in ["SHARED-01-FIVE-ELEMENTS", "SHARED-02-EARLY-PILGRIMAGE", "SHARED-03-EAGLE-SORROW", "SHARED-04-EARLY-DEMON-TALES"]:
		if chapter_id not in fixture.state.completed_shared_chapters:
			fixture.state.completed_shared_chapters.append(chapter_id)
	fixture.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
	fixture.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
	_record(fixture.save(), "world-map starting location should be persisted")

	var saved_shared_chapter := fixture.state.current_shared_chapter
	var saved_timeline := fixture.state.current_global_timeline
	var saved_completed := fixture.state.completed_shared_chapters.duplicate()
	var saved_roster := fixture.state.recruited_characters.duplicate()

	var map_scene := load("res://ui/world_map.tscn") as PackedScene
	_record(map_scene != null, "production WorldMap scene should load")
	var world_map: WorldMapScreen = map_scene.instantiate() as WorldMapScreen if map_scene != null else null
	_record(world_map != null, "production WorldMap scene should instantiate")
	if world_map != null:
		root.add_child(world_map)
		current_scene = world_map
		await process_frame
		_record(world_map.status_label.text.find("黑风山北道") >= 0, "optional exploration should start on the saved North Path")

		var eagle_index := _find_node(world_map, "鹰愁涧")
		_record(eagle_index >= 0, "Eagle Sorrow should be a connected node from Black Wind North Path")
		if eagle_index >= 0:
			world_map.node_list.select(eagle_index)
			world_map.call("_on_node_selected", eagle_index)
			world_map.travel_button.emit_signal("pressed")
			await process_frame
			_record(world_map.narrative.state.get_world_state().get("current_location", "") == "EAGLE_SORROW", "player should travel to Eagle Sorrow using the real map control")

		_record(world_map.rumor_list.get_item_count() > 0, "Eagle Sorrow should expose the Yellow Fang rumor")
		if world_map.rumor_list.get_item_count() > 0:
			world_map.rumor_list.select(0)
			world_map.rumor_button.emit_signal("pressed")
			await process_frame
			_record("BOUNTY_YELLOW_FANG" in world_map.narrative.state.get_world_state().get("discovered_bounties", []), "hearing the rumor should persist discovery of Yellow Fang")
		_record(not world_map.bounty_button.disabled, "discovered Yellow Fang should become challengeable at Eagle Sorrow")
		_record(world_map.bounty_label.text.find("黄牙老妖") >= 0, "WorldMap should show the player-facing bounty name rather than its internal ID")
		_record(world_map.bounty_label.text.find("不推进西游主线") >= 0, "WorldMap should explicitly mark bounties as optional and separate from mainline progression")

		var narrative_before_bounty: Dictionary = world_map.narrative.serialize().duplicate(true)
		world_map.bounty_button.emit_signal("pressed")
		var battle: BattleUI = await _wait_for_battle()
		_record(battle != null, "WorldMap bounty action should enter the production BattleUI")
		if battle != null:
			_record(battle.encounter_type == "bounty", "the optional fight should use the bounty resolution path")
			_record(battle.encounter_id == "BOUNTY_YELLOW_FANG", "the canonical Yellow Fang bounty ID should survive the handoff")
			battle.call_deferred("_on_combat_finished", "allies")
			await process_frame
			await process_frame
			_record(battle.encounter_resolved, "production bounty victory callback should resolve the optional fight")
			_record(battle.status_label.text.find("悬赏完成") >= 0, "victory feedback should identify the optional bounty")
			_record(battle.return_button.text == "返回地图", "optional bounty should expose the WorldMap return control")

			var after_battle := NarrativeManager.new()
			_record(after_battle.load(), "bounty result should leave a loadable narrative save")
			if after_battle.state != null:
				_record(after_battle.state.current_shared_chapter == saved_shared_chapter, "bounty victory must not advance the Shared chapter")
				_record(after_battle.state.current_global_timeline == saved_timeline, "bounty victory must not advance the global timeline")
				_record(after_battle.state.completed_shared_chapters == saved_completed, "bounty victory must not add a completed Shared chapter")
				_record(after_battle.state.recruited_characters == saved_roster, "bounty victory must not recruit or remove story characters")
				_record("BOUNTY_YELLOW_FANG" in after_battle.state.journey_log.get("defeated_targets", []), "bounty victory should persist a defeated-target journal record")

			battle.return_button.emit_signal("pressed")
			var returned_map: WorldMapScreen = await _wait_for_world_map()
			_record(returned_map != null, "bounty return button should restore the production WorldMap scene")
			if returned_map != null:
				_record(returned_map.status_label.text.find("鹰愁涧") >= 0, "returning from bounty should preserve the exploration location")
				_record(returned_map.bounty_button.disabled, "defeated Yellow Fang should no longer be challengeable")
				_record("BOUNTY_YELLOW_FANG" in returned_map.narrative.state.get_world_state().get("discovered_bounties", []), "rumor discovery should remain recorded after battle return")
				_record(not FileAccess.file_exists(encounter_path), "resolved bounty should clear the active encounter handoff")
				_record(not FileAccess.file_exists(resume_path), "resolved bounty should not leave pending EventSession resume data")

				var return_to_journey := _find_button_by_text(returned_map, "返回行程")
				_record(return_to_journey != null, "production WorldMap should offer Return to Journey")
				if return_to_journey != null:
					return_to_journey.emit_signal("pressed")
					var resumed_journey: JourneyScreen = await _wait_for_journey()
					_record(resumed_journey != null, "Return to Journey should load the production Journey scene")
					if resumed_journey != null:
						_record(resumed_journey.narrative.state.current_shared_chapter == saved_shared_chapter, "returning from optional exploration should resume Shared-05 rather than restart Shared-04")
						_record(resumed_journey.narrative.state.current_global_timeline == saved_timeline, "returning to Journey should preserve the canonical timeline after the bounty")
						_record(resumed_journey.narrative.state.completed_shared_chapters == saved_completed, "returning to Journey should preserve completed Shared-01 through Shared-04")
						_record(resumed_journey.narrative.state.recruited_characters == saved_roster, "returning to Journey should preserve the recruited roster")
						_record(str(resumed_journey.narrative.state.get_world_state().get("current_location", "")) == "EAGLE_SORROW", "Journey should load from the actual optional-exploration return location")

						resumed_journey.primary_button.emit_signal("pressed")
						await process_frame
						_record(resumed_journey.event_session != null, "Journey Continue should start the next canonical Shared sequence")
						if resumed_journey.event_session != null:
							_record(resumed_journey.event_session.sequence.get_id() == "SHARED-05-GAOJIAZHUANG-SEQUENCE", "the next story beat after the bounty should be Shared-05, not Shared-04")
							_record(str(resumed_journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "Shared-05 should begin with the Gaojiazhuang arrival dialogue")
							if resumed_journey.dialogue_revealing:
								resumed_journey.call("_reveal_dialogue_immediately")
							resumed_journey.primary_button.emit_signal("pressed")
							await process_frame
							_record(str(resumed_journey.event_session.get_action().get("kind", "")) == EventRunner.MOVE, "Shared-05 should next move the story location to Gaojiazhuang")
							if str(resumed_journey.event_session.get_action().get("kind", "")) == EventRunner.MOVE:
								_record(str(resumed_journey.event_session.get_action().get("marker_id", "")) == "GAOJIAZHUANG", "Shared-05 story move should target the canonical Gaojiazhuang map marker")
								resumed_journey.primary_button.emit_signal("pressed")
								await create_timer(0.6).timeout
								await process_frame
								_record(current_scene == resumed_journey, "Shared-05 story MOVE should remain in Journey, not switch to another scene")
								_record(str(resumed_journey.narrative.state.get_world_state().get("current_location", "")) == "GAOJIAZHUANG", "canonical Shared-05 MOVE should override the optional detour location")
								_record(str(resumed_journey.event_session.get_action().get("kind", "")) == EventRunner.CHOICE, "Shared-05 should continue from its arrival move to the recruitment choice")
								var post_arrival_save := NarrativeManager.new()
								_record(post_arrival_save.load(), "post-return Shared-05 MOVE should leave a loadable save")
								if post_arrival_save.state != null:
									_record(post_arrival_save.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "Shared-05 move save should preserve the current chapter")
									_record(post_arrival_save.state.current_global_timeline == saved_timeline, "Shared-05 arrival move should not prematurely advance its timeline milestone")
									_record(str(post_arrival_save.state.get_world_state().get("current_location", "")) == "GAOJIAZHUANG", "Gaojiazhuang arrival should persist after reload")
									_record(post_arrival_save.state.completed_shared_chapters == saved_completed, "Shared-05 arrival should not retroactively alter completed chapter history")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("WORLDMAP_RUMOR_BOUNTY_RETURN_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("WORLDMAP_RUMOR_BOUNTY_RETURN_FAIL failures=%d" % failures.size())
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

func _wait_for_journey() -> JourneyScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is JourneyScreen:
			return current_scene as JourneyScreen
	return null

func _find_button_by_text(parent: Node, target_text: String) -> Button:
	for child in parent.get_children():
		var button := child as Button
		if button != null and button.text == target_text:
			return button
		var nested: Button = _find_button_by_text(child, target_text)
		if nested != null:
			return nested
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
