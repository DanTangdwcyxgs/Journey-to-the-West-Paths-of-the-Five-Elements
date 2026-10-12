extends SceneTree

## Verifies the mainline Yellow Wind King uses the same atomic retry boundary as optional bounties,
## without conflating its journal entry or Ridge gate with the optional Yellow Fang objective.
class ToggleSaveNarrativeManager:
	extends NarrativeManager

	var save_succeeds: bool = false
	var save_attempts: int = 0

	func load(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		return true

	func save(path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		if not save_succeeds:
			return false
		return super.save(path)

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

	var narrative := ToggleSaveNarrativeManager.new()
	_record(narrative.start_new_game("WUKONG"), "Wukong should initialize the mainline settlement fixture")
	_record(narrative.encounter_character("TANG", []), "Tang should be recruited in the fixture")
	_record(narrative.encounter_character("WUKONG", []), "Wukong should be recruited in the fixture")
	_record(narrative.encounter_character("LONGMA", ["LONGMA-01", "LONGMA-02"]), "Longma should be recruited before the optional arc")
	narrative.state.current_global_timeline = 120
	narrative.state.set_current_shared_chapter("SHARED-05-GAOJIAZHUANG")
	narrative.state.completed_shared_chapters = [
		"SHARED-01-FIVE-ELEMENTS",
		"SHARED-02-EARLY-PILGRIMAGE",
		"SHARED-03-EAGLE-SORROW",
		"SHARED-04-EARLY-DEMON-TALES",
	]
	narrative.state.record_milestone("WUKONG_RECRUITED", 100)
	narrative.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
	narrative.state.record_milestone("YELLOW_RIDGE_ENTRY", 120)
	narrative.state.record_milestone("YELLOW_RIDGE_INTEL", 120)
	narrative.state.record_milestone("YELLOW_RIDGE_STORM", 120)
	narrative.state.record_milestone("YELLOW_WIND_GATE_OPEN", 120)
	narrative.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
	narrative.state.add_world_rumor("YELLOW_WIND_CAVE_ROOM_CAVE_MOUTH")
	narrative.state.add_world_rumor("YELLOW_WIND_CAVE_ROOM_SAND_ALTAR")
	narrative.state.add_world_rumor("YELLOW_WIND_CAVE_ROOM_SANDSTORM_HALL")
	narrative.state.journey_log["defeated_targets"].append("BOUNTY_YELLOW_FANG")
	narrative.state.set_inventory({
		"currencies": {"COIN": 55},
		"items": {"POTION": 3},
	})

	_record(BountyEncounterState.start("YELLOW_WIND_KING", "YELLOW_WIND_THRONE"), "production mainline boss handoff should be written")
	var packed := load("res://ui/battle_ui.tscn") as PackedScene
	_record(packed != null, "production BattleUI scene should load")
	if packed == null:
		await _finish(save_path, encounter_path, resume_path, save_backup, encounter_backup, resume_backup)
		return

	var battle := packed.instantiate() as BattleUI
	_record(battle != null, "production BattleUI should instantiate")
	if battle == null:
		await _finish(save_path, encounter_path, resume_path, save_backup, encounter_backup, resume_backup)
		return

	battle.narrative_manager_override = narrative
	root.add_child(battle)
	current_scene = battle
	await process_frame
	_record(battle.encounter_type == "bounty", "mainline Yellow Wind King should use the existing atomic bounty-settlement path")
	_record(battle.encounter_id == "YELLOW_WIND_KING", "production handoff must keep the mainline Yellow Wind King ID")
	_record(battle.source_stage_id == "YELLOW_WIND_THRONE", "mainline boss handoff should retain the final cave room")
	_record(battle.return_button != null and battle.return_button.text == "返回地图", "unresolved battle should not offer a continue action before victory")
	if battle.return_button == null:
		await _finish(save_path, encounter_path, resume_path, save_backup, encounter_backup, resume_backup)
		return

	battle.battle_inventory.restore({
		"currencies": {"COIN": 12},
		"items": {"POTION": 1},
	})
	var narrative_before: Dictionary = narrative.serialize().duplicate(true)
	var bounty_before: Dictionary = battle.bounty_manager.to_dict().duplicate(true)
	var enemy_hp_before: int = battle.enemies[0].hp
	var turn_before: int = battle.engine.turn_number
	var shared_chapter_before: String = narrative.state.current_shared_chapter
	var timeline_before: int = narrative.state.current_global_timeline
	var shared_history_before: Array[String] = narrative.state.completed_shared_chapters.duplicate()
	var roster_before: Array[String] = narrative.state.recruited_characters.duplicate()

	# Exercise the actual production victory signal and force its first persistence boundary to fail.
	battle.engine.combat_finished.emit("allies")
	_record(narrative.save_attempts == 1, "mainline victory should attempt exactly one atomic save")
	_record(battle.bounty_settlement_pending, "failed mainline settlement should remain pending for retry")
	_record(not battle.encounter_resolved, "failed mainline settlement must not mark the fight resolved")
	_record(not battle.battle_result_locked, "failed mainline settlement should unlock the result handler")
	_record(battle.return_button.text == "重试结算", "the production result button should offer retry after save failure")
	_record(battle.status_label.text.contains("保存失败"), "save failure should be visible to the player")
	_record(narrative.serialize() == narrative_before, "failed mainline settlement must restore the complete NarrativeState")
	_record(battle.bounty_manager.to_dict() == bounty_before, "failed mainline settlement must restore BountyManager state")
	_record("YELLOW_WIND_KING" not in narrative.state.get_journey_log().get("defeated_targets", []), "failed save must not record the mainline boss as defeated")
	_record("BOUNTY_YELLOW_FANG" in narrative.state.get_journey_log().get("defeated_targets", []), "rollback must retain the previously defeated optional Yellow Fang")
	_record("YELLOW_WIND_GATE_OPEN" in narrative.state.completed_milestones, "rollback must retain the previously committed cave gate")
	_record(not bool(YellowWindRidgeManager.new().get_stage("YELLOW_WIND_GATE", narrative).get("completed", false)), "failed mainline settlement must leave the Ridge gate incomplete")
	_record(FileAccess.file_exists(encounter_path), "failed settlement must preserve the active battle handoff")
	_record(current_scene == battle, "failed settlement must keep the production victory result in BattleUI")
	_record(battle.engine.turn_number == turn_before, "retry must not replay or advance the completed battle")
	_record(battle.enemies[0].hp == enemy_hp_before, "retry must not alter the completed battle state")

	# Press the real retry button; settlement commits once, then the save can be loaded by a fresh manager.
	narrative.save_succeeds = true
	battle.return_button.pressed.emit()
	await process_frame
	_record(narrative.save_attempts == 2, "successful retry should perform exactly one additional save")
	_record(not battle.bounty_settlement_pending and battle.encounter_resolved, "successful retry should resolve the mainline fight")
	_record(current_scene == battle, "committed result should remain visible until the player continues")
	_record(battle.status_label.text.contains("悬赏完成：黄风妖王"), "the player-facing result should name Yellow Wind King")
	_record(battle.return_button.text == "继续探索", "mainline boss return should lead back to cave exploration")
	_record(not FileAccess.file_exists(encounter_path), "successful settlement should clear the active handoff")
	_record(battle.engine.turn_number == turn_before and battle.enemies[0].hp == enemy_hp_before, "successful retry must not replay combat")

	var defeated_targets: Array = narrative.state.get_journey_log().get("defeated_targets", [])
	_record(_count_occurrences(defeated_targets, "YELLOW_WIND_KING") == 1, "mainline boss journal entry should be recorded exactly once under its own ID")
	_record(_count_occurrences(defeated_targets, "BOUNTY_YELLOW_FANG") == 1, "the earlier optional bounty journal entry should remain separate and unique")
	_record(battle.bounty_manager.get_status("YELLOW_WIND_KING") == BountyManager.STATUS_DEFEATED, "mainline bounty definition should be marked defeated after commit")
	_record("YELLOW_WIND_GATE_OPEN" in narrative.state.completed_milestones, "successful boss settlement should retain the gate milestone")
	_record(bool(YellowWindRidgeManager.new().get_stage("YELLOW_WIND_GATE", narrative).get("completed", false)), "only the mainline boss defeat should complete the Ridge gate")
	_record(narrative.state.current_shared_chapter == shared_chapter_before, "mainline side-area boss must not advance the Shared chapter")
	_record(narrative.state.current_global_timeline == timeline_before, "mainline side-area boss must not change global chronology")
	_record(narrative.state.completed_shared_chapters == shared_history_before, "mainline side-area boss must not rewrite Shared history")
	_record(narrative.state.recruited_characters == roster_before, "mainline side-area boss must not alter the canonical party roster")

	var reloaded := NarrativeManager.new()
	_record(reloaded.load(), "committed mainline boss result should survive a fresh NarrativeManager load")
	if reloaded.state != null:
		var loaded_targets: Array = reloaded.state.get_journey_log().get("defeated_targets", [])
		_record(_count_occurrences(loaded_targets, "YELLOW_WIND_KING") == 1, "reload should preserve exactly one mainline boss journal entry")
		_record(_count_occurrences(loaded_targets, "BOUNTY_YELLOW_FANG") == 1, "reload should preserve the independent optional bounty entry")
		_record(bool(YellowWindRidgeManager.new().get_stage("YELLOW_WIND_GATE", reloaded).get("completed", false)), "reloaded Ridge state should recognize the boss-gate completion")
		_record(reloaded.state.current_shared_chapter == shared_chapter_before, "reload should preserve the same Shared chapter")
		_record(reloaded.state.current_global_timeline == timeline_before, "reload should preserve the same global timeline")

	battle.return_button.pressed.emit()
	var cave := await _wait_for_cave()
	_record(cave != null, "continue after boss victory should reload the production cave scene")
	if cave != null:
		_record(cave.current_room_index == 3, "reloaded cave cursor should return to the completed Yellow Wind throne")
		_record(cave._is_boss_defeated(), "reloaded cave should recognize the persisted mainline boss defeat")
		_record(cave._has_gate_access(), "reloaded cave should retain valid gate access after the boss fight")
		var exit_button := _find_button(cave, "返回黄风岭")
		_record(exit_button != null, "completed cave should expose the return-to-ridge action")
		if exit_button != null:
			exit_button.pressed.emit()
			var ridge_screen := await _wait_for_ridge()
			_record(ridge_screen != null, "the production exit should reload Yellow Wind Ridge")
			if ridge_screen != null:
				_record(ridge_screen.ridge.is_available(ridge_screen.narrative), "reloaded Ridge should remain accessible at Black Wind North Path")
				_record(str(ridge_screen.ridge.get_current_stage(ridge_screen.narrative).get("id", "")) == "", "reloaded Ridge should consider all four stages complete")
				_record(ridge_screen.status_label.text.contains("4/4"), "reloaded Ridge UI should show all stages complete")
				_record(ridge_screen.narrative.state.current_shared_chapter == shared_chapter_before, "return to Ridge should preserve the canonical Shared chapter")
				_record(ridge_screen.narrative.state.current_global_timeline == timeline_before, "return to Ridge should preserve the fixed world chronology")

	await _finish(save_path, encounter_path, resume_path, save_backup, encounter_backup, resume_backup)

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

func _find_button(parent: Node, target_text: String) -> Button:
	for child in parent.get_children():
		var button := child as Button
		if button != null and button.text == target_text:
			return button
		var nested: Button = _find_button(child, target_text)
		if nested != null:
			return nested
	return null

func _count_occurrences(values: Array, expected: String) -> int:
	var count := 0
	for value in values:
		if str(value) == expected:
			count += 1
	return count

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

func _finish(save_path: String, encounter_path: String, resume_path: String, save_backup: Dictionary, encounter_backup: Dictionary, resume_backup: Dictionary) -> void:
	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)
	if failures.is_empty():
		print("YELLOW_WIND_KING_SETTLEMENT_RETRY_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("YELLOW_WIND_KING_SETTLEMENT_RETRY_FAIL failures=%d" % failures.size())
		quit(1)

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
