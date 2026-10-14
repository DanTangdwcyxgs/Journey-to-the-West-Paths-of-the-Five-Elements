extends SceneTree

## Exercises the production BattleUI retry button across a failed and successful bounty settlement.
class ToggleSaveNarrativeManager:
	extends NarrativeManager

	var save_succeeds: bool = false
	var save_attempts: int = 0

	func load(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		# Keep the prebuilt fixture in memory so each UI callback sees the same
		# authoritative state; successful saves still use the real serializer.
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
	_remove_file(encounter_path)
	_remove_file(resume_path)

	var narrative := ToggleSaveNarrativeManager.new()
	_record(narrative.start_new_game("WUKONG"), "fixture should initialize the narrative state")
	_record(narrative.encounter_character("TANG", []), "Tang should be recruited in the fixture")
	_record(narrative.encounter_character("WUKONG", []), "Wukong should be recruited in the fixture")
	narrative.state.current_global_timeline = 120
	narrative.state.set_current_shared_chapter("SHARED-05-GAOJIAZHUANG")
	narrative.state.set_inventory({
		"currencies": {"COIN": 55},
		"items": {"POTION": 3},
	})
	_record(BountyEncounterState.start("BOUNTY_YELLOW_FANG"), "production bounty handoff should be written")

	var packed := load("res://ui/battle_ui.tscn") as PackedScene
	_record(packed != null, "production BattleUI scene should load")
	if packed == null:
		_restore_file(save_path, save_backup)
		_restore_file(encounter_path, encounter_backup)
		_restore_file(resume_path, resume_backup)
		_finish()
		return

	var battle := packed.instantiate() as BattleUI
	_record(battle != null, "production battle scene should instantiate")
	if battle == null:
		_restore_file(save_path, save_backup)
		_restore_file(encounter_path, encounter_backup)
		_restore_file(resume_path, resume_backup)
		_finish()
		return

	battle.narrative_manager_override = narrative
	root.add_child(battle)
	current_scene = battle
	await process_frame
	_record(battle.encounter_type == "bounty", "BattleUI should restore the active bounty handoff")
	_record(battle.encounter_id == "BOUNTY_YELLOW_FANG", "BattleUI should load the Yellow Fang encounter")
	_record(battle.return_button != null, "production return/retry button should exist")
	_record(not battle.enemies.is_empty(), "production bounty battle should create an enemy")
	if battle.return_button == null or battle.enemies.is_empty():
		_restore_file(save_path, save_backup)
		_restore_file(encounter_path, encounter_backup)
		_restore_file(resume_path, resume_backup)
		_finish()
		return

	# Simulate the final combat inventory without mutating NarrativeState early.
	battle.battle_inventory.restore({
		"currencies": {"COIN": 12},
		"items": {"POTION": 1},
	})
	var narrative_before: Dictionary = narrative.serialize().duplicate(true)
	var bounty_before: Dictionary = battle.bounty_manager.to_dict().duplicate(true)
	var enemy_hp_before: int = battle.enemies[0].hp
	var turn_before: int = battle.engine.turn_number

	# Emit the real engine signal so the production signal connection enters
	# BattleUI's victory/settlement handler.
	battle.engine.combat_finished.emit("allies")
	_record(narrative.save_attempts == 1, "first settlement should attempt exactly one save")
	_record(battle.bounty_settlement_pending, "save failure should leave settlement pending")
	_record(not battle.encounter_resolved, "failed settlement must not mark the encounter resolved")
	_record(not battle.battle_result_locked, "failed settlement should unlock the result handler for retry")
	_record(battle.return_button.text == "重试结算", "the actual UI button should offer retry after save failure")
	_record(not battle.return_button.disabled, "retry button should be enabled after save failure")
	_record(battle.status_label.text.contains("保存失败"), "failure feedback should explain that settlement did not save")
	_record(narrative.serialize() == narrative_before, "failed settlement should restore the exact NarrativeState snapshot")
	_record(battle.bounty_manager.to_dict() == bounty_before, "failed settlement should restore the bounty manager snapshot")
	_record(FileAccess.file_exists(encounter_path), "failed settlement should preserve the active encounter handoff")
	_record(current_scene == battle, "failed settlement must keep the finished battle scene open")
	_record(battle.engine.turn_number == turn_before, "failed settlement must not advance or replay combat")
	_record(battle.enemies[0].hp == enemy_hp_before, "failed settlement must preserve the finished encounter state")

	# Press the actual production button. It retries settlement only; it must not
	# repeat the battle and should keep the result screen visible after commit.
	narrative.save_succeeds = true
	battle.return_button.pressed.emit()
	await process_frame
	_record(narrative.save_attempts == 2, "successful retry should make one additional save attempt")
	_record(not battle.bounty_settlement_pending, "successful retry should clear pending settlement")
	_record(battle.encounter_resolved, "successful retry should resolve the encounter")
	_record(current_scene == battle, "successful retry should keep the victory summary visible before leaving")
	_record(battle.status_label.text.contains("悬赏完成：黄牙老妖"), "successful retry should replace failure feedback with the victory summary")
	_record(battle.return_button.text == "返回地图", "committed bounty result should restore the normal continue label")
	_record(not FileAccess.file_exists(encounter_path), "successful settlement should clear the active bounty handoff")
	_record(battle.engine.turn_number == turn_before, "retry should not replay or advance the finished battle")
	_record(battle.enemies[0].hp == enemy_hp_before, "retry should not alter enemy state")

	var committed_inventory: Dictionary = narrative.state.get_inventory()
	var currencies: Dictionary = committed_inventory.get("currencies", {})
	var items: Dictionary = committed_inventory.get("items", {})
	_record(int(currencies.get("COIN", 0)) == 312, "retry should apply the 300-coin reward exactly once to post-battle inventory")
	_record(int(items.get("POTION", 0)) == 1, "retry should preserve post-battle consumable usage")
	_record(int(items.get("DEMON_FANG", 0)) == 1, "retry should grant the demon fang exactly once")
	_record(int(items.get("FANG_TALISMAN", 0)) == 1, "retry should grant the fang talisman exactly once")
	var defeated_targets: Array = narrative.state.get_journey_log().get("defeated_targets", [])
	_record(_count_occurrences(defeated_targets, "BOUNTY_YELLOW_FANG") == 1, "retry should record the defeated bounty target exactly once")
	_record(battle.bounty_manager.get_status("BOUNTY_YELLOW_FANG") == BountyManager.STATUS_DEFEATED, "successful retry should mark the bounty defeated")
	_record(narrative.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "optional bounty settlement must preserve the current Shared chapter")
	_record(narrative.state.current_global_timeline == 120, "optional bounty settlement must preserve the global chronology")

	# Leaving the committed result screen must not enter the settlement handler again.
	battle.return_button.pressed.emit()
	for _frame in range(45):
		await process_frame
		if current_scene != battle:
			break
	_record(current_scene != battle, "the regular continue action should leave the battle scene after commit")
	_record(narrative.save_attempts == 2, "leaving the victory screen must not settle or save the bounty a second time")
	_record(int(narrative.state.get_inventory().get("currencies", {}).get("COIN", 0)) == 312, "leaving the result screen must not duplicate currency rewards")
	_record(_count_occurrences(narrative.state.get_journey_log().get("defeated_targets", []), "BOUNTY_YELLOW_FANG") == 1, "leaving the result screen must not duplicate the defeated-target journal entry")

	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)
	_finish()

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

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("BATTLE_UI_BOUNTY_SETTLEMENT_RETRY_PASS")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("BATTLE_UI_BOUNTY_SETTLEMENT_RETRY_FAIL failures=%d" % failures.size())
	quit(1)
