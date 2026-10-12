extends SceneTree

## Production cave -> normal encounter -> cave -> Yellow Wind King -> cave.
## Saves, encounter handoffs and resume context are restored after the smoke.
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
	_record(fixture.start_new_game("WUKONG"), "Wukong should initialize the cave round-trip fixture")
	_record(fixture.encounter_character("TANG", []), "Tang should be present in the fixture party")
	_record(fixture.encounter_character("WUKONG", []), "Wukong should be present in the fixture party")
	var memories: Array[String] = ["LONGMA-01", "LONGMA-02"]
	_record(fixture.encounter_character("LONGMA", memories), "Longma should be recruited before Yellow Wind exploration")
	fixture.state.mark_route_complete("WUKONG")
	fixture.state.record_milestone("WUKONG_RECRUITED", 100)
	fixture.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
	fixture.state.record_milestone("YELLOW_RIDGE_ENTRY", 120)
	fixture.state.record_milestone("YELLOW_RIDGE_INTEL", 120)
	fixture.state.record_milestone("YELLOW_RIDGE_STORM", 120)
	fixture.state.record_milestone("YELLOW_WIND_GATE_OPEN", 120)
	fixture.state.current_global_timeline = 120
	fixture.state.set_current_shared_chapter("SHARED-05-GAOJIAZHUANG")
	for chapter_id in ["SHARED-01-FIVE-ELEMENTS", "SHARED-02-EARLY-PILGRIMAGE", "SHARED-03-EAGLE-SORROW", "SHARED-04-EARLY-DEMON-TALES"]:
		if chapter_id not in fixture.state.completed_shared_chapters:
			fixture.state.completed_shared_chapters.append(chapter_id)
	fixture.state.set_inventory({"currencies": {"COIN": 0}, "items": {}})
	fixture.state.journey_log["defeated_targets"].append("BOUNTY_YELLOW_FANG")
	fixture.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
	fixture.state.add_world_rumor(YellowWindCaveScreen.PROGRESS_PREFIX + "CAVE_MOUTH")
	fixture.state.add_world_rumor(YellowWindCaveScreen.PROGRESS_PREFIX + "SAND_ALTAR")
	_record(fixture.save(), "open cave fixture should save before entering the real scene")

	var shared_chapter_before := fixture.state.current_shared_chapter
	var timeline_before := fixture.state.current_global_timeline
	var completed_shared_before: Array[String] = fixture.state.completed_shared_chapters.duplicate()
	var roster_before: Array[String] = fixture.state.recruited_characters.duplicate()

	var bootstrap := Control.new()
	bootstrap.name = "YellowWindCaveBattleRoundtripBootstrap"
	root.add_child(bootstrap)
	current_scene = bootstrap
	var scene_error: Error = change_scene_to_file("res://ui/yellow_wind_cave.tscn")
	_record(scene_error == OK, "production cave scene should open")
	var cave := await _wait_for_cave()
	_record(cave != null, "saved cave gate should enter the production YellowWindCaveScreen")
	if cave != null:
		_record(cave.current_room_index == 2, "saved CAVE_MOUTH and SAND_ALTAR progress should resume at SANDSTORM_HALL")
		_record(cave._has_gate_access(), "the saved gate milestone should authorize cave entry")
		_record(not cave._is_boss_defeated(), "an already-defeated optional Yellow Fang bounty must not mark the mainline Yellow Wind King as defeated")

		var normal_button := _find_button(cave.action_box, "迎击风沙妖兵")
		_record(normal_button != null, "SANDSTORM_HALL should expose the production normal-encounter button")
		if normal_button != null:
			normal_button.emit_signal("pressed")
			var normal_battle := await _wait_for_battle()
			_record(normal_battle != null, "normal encounter button should transition into the production BattleUI")
			if normal_battle != null:
				_record(normal_battle.encounter_type == "normal", "the cave encounter should use the normal-combat path")
				_record(normal_battle.encounter_id == "YELLOW_WIND_CAVE_SAND_GUARDS", "the canonical Sand Guard encounter should be used")
				_record(normal_battle.source_stage_id == "SANDSTORM_HALL", "normal battle handoff should retain its source room")
				normal_battle.call_deferred("_on_combat_finished", "allies")
				await process_frame
				await process_frame
				_record(normal_battle.encounter_resolved, "production normal-battle victory should resolve")
				_record(normal_battle.return_button != null and normal_battle.return_button.text == "继续探索", "normal victory should offer Continue Exploration")

				var after_normal := NarrativeManager.new()
				_record(after_normal.load(), "normal encounter should leave a loadable narrative save")
				if after_normal.state != null:
					var rumors: Array = after_normal.state.get_world_state().get("heard_rumors", [])
					_record((YellowWindCaveScreen.PROGRESS_PREFIX + "SANDSTORM_HALL") in rumors, "normal victory should persist the completed SANDSTORM_HALL marker")
					_record(after_normal.state.current_shared_chapter == shared_chapter_before, "optional normal battle must preserve the Shared chapter")
					_record(after_normal.state.current_global_timeline == timeline_before, "optional normal battle must preserve global chronology")
					_record(after_normal.state.completed_shared_chapters == completed_shared_before, "optional normal battle must not complete extra Shared chapters")
					_record(after_normal.state.recruited_characters == roster_before, "optional normal battle must not alter the recruited roster")

				normal_battle.return_button.emit_signal("pressed")
				cave = await _wait_for_cave()
				_record(cave != null, "Continue Exploration should return to the production cave scene")
				if cave != null:
					_record(cave.current_room_index == 3, "normal victory should resume at YELLOW_WIND_THRONE")
					_record(not cave._is_boss_defeated(), "optional bounty victory must not mark the mainline Yellow Wind King defeated")
					_record(_find_button(cave.action_box, "进入黄风妖王战场") != null, "the mainline boss must remain challengeable after the optional bounty was defeated first")
					_record(str(cave.rooms[cave.current_room_index].get("id", "")) == "YELLOW_WIND_THRONE", "cave room cursor should point at the canonical boss room")

					var boss_button := _find_button(cave.action_box, "进入黄风妖王战场")
					_record(boss_button != null, "the boss room should expose the production Yellow Wind King button")
					if boss_button != null:
						boss_button.emit_signal("pressed")
						var boss_battle := await _wait_for_battle()
						_record(boss_battle != null, "boss gate should transition into production BattleUI")
						if boss_battle != null:
							_record(boss_battle.encounter_type == "bounty", "Yellow Wind King should use the bounty resolution path")
							_record(boss_battle.encounter_id == "YELLOW_WIND_KING", "boss handoff should keep the canonical bounty ID")
							_record(boss_battle.source_stage_id == "YELLOW_WIND_THRONE", "boss handoff should retain the cave room return target")
							boss_battle.call_deferred("_on_combat_finished", "allies")
							await process_frame
							await process_frame
							_record(boss_battle.encounter_resolved, "production bounty victory callback should resolve Yellow Wind King")
							_record(boss_battle.status_label != null and boss_battle.status_label.text.find("悬赏完成") >= 0, "boss victory should present bounty completion feedback")
							_record(boss_battle.return_button != null and boss_battle.return_button.text == "继续探索", "boss victory should return to the cave exit rather than the WorldMap")

							var after_boss := NarrativeManager.new()
							_record(after_boss.load(), "boss victory should leave a loadable narrative save")
							if after_boss.state != null:
								_record("YELLOW_WIND_KING" in after_boss.state.get_journey_log().get("defeated_targets", []), "mainline Yellow Wind King defeat should persist under its own battle journal ID")
								_record("YELLOW_WIND_GATE_OPEN" in after_boss.state.completed_milestones, "boss victory should retain the cave's opened-gate milestone")
								_record(after_boss.state.current_shared_chapter == shared_chapter_before, "boss victory must not advance the Shared chapter")
								_record(after_boss.state.current_global_timeline == timeline_before, "boss victory must not advance global chronology")
								_record(after_boss.state.completed_shared_chapters == completed_shared_before, "boss victory must not alter the completed Shared chapter history")
								_record(after_boss.state.recruited_characters == roster_before, "boss victory must not alter the canonical roster")

							boss_battle.return_button.emit_signal("pressed")
							cave = await _wait_for_cave()
							_record(cave != null, "Continue Exploration should return to the cave after boss victory")
							if cave != null:
								_record(cave.current_room_index == 3, "boss victory should restore the final cave room cursor")
								_record(cave._is_boss_defeated(), "cave should recognize the persisted boss defeat")
								_record(cave.detail_label.text.find("黄风妖王已经败退") >= 0, "final cave room should communicate that the exit is safe")
								_record(_find_button(cave.action_box, "进入黄风妖王战场") == null, "a defeated Yellow Wind King should not be challengeable again")
								_record(cave._has_gate_access(), "saved gate remains valid on the cave exit after the boss is defeated")

								var back_button := _find_button_by_text(cave, "返回黄风岭")
								_record(back_button != null, "the cave should expose its production exit back to Yellow Wind Ridge")
								if back_button != null:
									back_button.emit_signal("pressed")
									var ridge := await _wait_for_ridge()
									_record(ridge != null, "cave exit should return to Yellow Wind Ridge")
									if ridge != null:
										_record(ridge.ridge.is_available(ridge.narrative), "the opened side route should remain accessible at Black Wind North Path")
										_record(str(ridge.ridge.get_current_stage(ridge.narrative).get("id", "")) == "", "defeating the boss should complete the gate rather than reopen the challenge")
										_record(ridge.status_label.text.find("4/4") >= 0, "ridge progress should show all stages complete after the boss defeat")

	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("YELLOW_WIND_CAVE_BATTLE_ROUNDTRIP_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("YELLOW_WIND_CAVE_BATTLE_ROUNDTRIP_FAIL failures=%d" % failures.size())
		quit(1)

func _wait_for_cave() -> YellowWindCaveScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is YellowWindCaveScreen:
			return current_scene as YellowWindCaveScreen
	return null

func _wait_for_ridge() -> YellowWindRidgeScreen:
	for _frame in range(45):
		await process_frame
		if current_scene is YellowWindRidgeScreen:
			return current_scene as YellowWindRidgeScreen
	return null

func _wait_for_battle() -> BattleUI:
	for _frame in range(45):
		await process_frame
		if current_scene is BattleUI:
			return current_scene as BattleUI
	return null

func _find_button(parent: Node, target_text: String) -> Button:
	for child in parent.get_children():
		var button := child as Button
		if button != null and button.text == target_text:
			return button
		var nested: Button = _find_button(child, target_text)
		if nested != null:
			return nested
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
