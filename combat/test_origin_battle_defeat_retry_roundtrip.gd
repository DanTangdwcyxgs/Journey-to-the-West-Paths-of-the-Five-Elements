extends SceneTree

## Production roundtrip regression: a pre-battle choice survives defeat, return,
## and retry; the failed BATTLE node must not be mistaken for a victory.
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
	_record(fixture.start_new_game("LONGMA"), "Longma route should initialize")
	_record(not fixture.complete_origin_chapter("LONGMA").is_empty(), "LONGMA-01 should complete before the test battle")
	_record(str(fixture.origin_routes.get_current_chapter(fixture, "LONGMA").get("id", "")) == "LONGMA-02", "fixture should stop at the choice-plus-battle chapter")
	_record(fixture.save(), "Longma battle fixture should save before MainMenu opens")

	var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
	_record(menu_scene != null, "production MainMenu scene should load")
	var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
	_record(menu != null, "production MainMenu should instantiate")
	if menu == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return
	root.add_child(menu)
	current_scene = menu
	await process_frame
	_record(not menu.continue_button.disabled, "MainMenu should offer Continue for the Longma fixture")
	menu.continue_button.emit_signal("pressed")
	var journey := await _wait_for_journey()
	_record(journey != null, "MainMenu Continue should enter the production Journey")
	if journey == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return

	journey.primary_button.emit_signal("pressed")
	await process_frame
	_record(journey.event_session != null, "Journey Continue should start LONGMA-02-SEQUENCE")
	if journey.event_session == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return
	_record(journey.event_session.sequence.get_id() == "LONGMA-02-SEQUENCE", "Journey should load the canonical Longma origin sequence")
	_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "Longma sequence should begin with its trial dialogue")
	journey.call("_reveal_dialogue_immediately")
	journey.primary_button.emit_signal("pressed")
	await process_frame
	var choice_action: Dictionary = journey.event_session.get_action()
	_record(str(choice_action.get("kind", "")) == EventRunner.CHOICE, "Longma sequence should reach its canonical responsibility choice")
	var choice_id := "ACCEPT_PUNISHMENT"
	_record(_press_choice(journey, choice_action, choice_id), "Longma responsibility choice should be visible and actionable")
	await process_frame
	_record(journey.narrative.state.get_origin_choice("LONGMA-02") == choice_id, "the chosen stance should persist before battle")
	_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.BATTLE, "the selected stance should advance directly to the encounter handoff")

	var first_battle := await _wait_for_battle()
	_record(first_battle != null, "Longma EventSequence should enter the production BattleUI")
	if first_battle == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return
	_record(first_battle.encounter_type == "origin", "Longma trial should use the Origin battle path")
	_record(first_battle.encounter_id == "LONGMA_ORIGIN_SEA_CLIFF", "Longma trial should launch the canonical Sea Cliff encounter")
	var handoff_before_defeat := BountyEncounterState.get_active_record()
	_record(not handoff_before_defeat.get("event_resume", {}).is_empty(), "battle handoff should keep the EventSession snapshot")
	first_battle.call("_on_combat_finished", "enemies")
	await process_frame
	_record(first_battle.status_label.text.find("战斗失败") >= 0, "defeat should show player-facing failure feedback")
	var failed_handoff := BountyEncounterState.get_active_record()
	_record(bool(failed_handoff.get("battle_failed", false)), "defeat should persist an explicit failed-battle marker")
	_record(not failed_handoff.get("event_resume", {}).is_empty(), "defeat should preserve the pre-battle EventSession snapshot")
	var failed_save := NarrativeManager.new()
	_record(failed_save.load(), "defeat should leave a loadable narrative save")
	if failed_save.state != null:
		_record(failed_save.state.get_origin_choice("LONGMA-02") == choice_id, "defeat should preserve the already-selected stance")
		_record(str(failed_save.origin_routes.get_current_chapter(failed_save, "LONGMA").get("id", "")) == "LONGMA-02", "defeat must not advance the Origin chapter")
		_record("LONGMA-02" not in failed_save.state.completed_chapters, "defeat must not mark the recruitment chapter complete")

	first_battle.return_button.emit_signal("pressed")
	var retry_journey := await _wait_for_journey()
	_record(retry_journey != null, "returning after defeat should restore the production Journey")
	if retry_journey == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return
	_record(retry_journey.event_session != null, "Journey should restore the failed EventSession")
	if retry_journey.event_session == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return
	var retry_action: Dictionary = retry_journey.event_session.get_action()
	_record(str(retry_action.get("kind", "")) == EventRunner.BATTLE, "defeat should restore the exact pending BATTLE node, not post-battle dialogue")
	_record(retry_journey.narrative.state.get_origin_choice("LONGMA-02") == choice_id, "restoring the failed battle must not replay or erase the selected stance")
	var retry_record := BountyEncounterState.get_active_record()
	_record(bool(retry_record.get("battle_failed", false)), "the retry point should remain persisted if the player quits before retrying")
	_record(retry_journey.primary_button.text == "进入战斗", "Journey should expose a direct retry action at the pending BATTLE node")

	retry_journey.primary_button.emit_signal("pressed")
	var second_battle := await _wait_for_battle()
	_record(second_battle != null, "pressing the pending BATTLE action should relaunch the same production encounter")
	if second_battle == null:
		await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)
		return
	_record(second_battle.encounter_id == "LONGMA_ORIGIN_SEA_CLIFF", "retry should retain the original encounter ID")
	_record(second_battle.encounter_type == "origin", "retry should retain the Origin battle resolution path")
	var retry_handoff := BountyEncounterState.get_active_record()
	_record(not bool(retry_handoff.get("battle_failed", false)), "a fresh retry handoff should clear the previous failure marker")
	_record(not retry_handoff.get("event_resume", {}).is_empty(), "retry should preserve the EventSession snapshot at its BATTLE node")

	second_battle.call("_on_combat_finished", "allies")
	await process_frame
	await process_frame
	_record(second_battle.encounter_resolved, "successful retry should use the atomic narrative victory settlement")
	_record(second_battle.return_button.text == "继续旅途", "successful retry should expose Continue Journey")
	var victory_save := NarrativeManager.new()
	_record(victory_save.load(), "successful retry should persist a loadable narrative")
	if victory_save.state != null:
		_record(str(victory_save.origin_routes.get_current_chapter(victory_save, "LONGMA").get("id", "")) == "LONGMA-03", "successful retry should complete LONGMA-02 exactly once")
		_record("LONGMA-02" in victory_save.state.completed_chapters, "successful retry should record the Longma chapter completion")
		_record(victory_save.state.get_origin_choice("LONGMA-02") == choice_id, "successful retry should preserve the original player choice")

	second_battle.return_button.emit_signal("pressed")
	var post_battle_journey := await _wait_for_journey()
	_record(post_battle_journey != null, "victory continuation should restore Journey after the retry")
	if post_battle_journey != null:
		_record(post_battle_journey.event_session != null, "victory continuation should restore the post-battle EventSession")
		if post_battle_journey.event_session != null:
			_record(str(post_battle_journey.event_session.get_action().get("kind", "")) == EventRunner.DIALOGUE, "successful retry should resume at the canonical after-battle dialogue, not the BATTLE node")
			post_battle_journey.call("_reveal_dialogue_immediately")
			post_battle_journey.primary_button.emit_signal("pressed")
			await process_frame
			_record(str(post_battle_journey.event_session.get_action().get("kind", "")) == EventRunner.END, "post-battle dialogue should advance to END")
			post_battle_journey.primary_button.emit_signal("pressed")
			await process_frame
			_record(post_battle_journey.event_session == null, "post-battle END should close the EventSession")
		_record(str(post_battle_journey.origin.get_current_chapter(post_battle_journey.narrative, "LONGMA").get("id", "")) == "LONGMA-03", "post-battle END must not complete or advance the Origin chapter twice")
		_record(not FileAccess.file_exists(encounter_path), "terminal END should clear the active encounter handoff")
		_record(not FileAccess.file_exists(resume_path), "terminal END should clear the pending resume file")

	await _finish(save_path, save_backup, encounter_path, encounter_backup, resume_path, resume_backup)

func _press_choice(journey: OriginSequenceJourneyScreen, action: Dictionary, choice_id: String) -> bool:
	var selected_label := ""
	for choice in action.get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			selected_label = str(choice.get("label", choice_id))
			break
	if selected_label.is_empty():
		return false
	for child in journey.choice_box.get_children():
		var button := child as Button
		if button != null and button.text == selected_label:
			button.emit_signal("pressed")
			return true
	return false

func _wait_for_journey() -> OriginSequenceJourneyScreen:
	for _frame in range(60):
		await process_frame
		if current_scene is OriginSequenceJourneyScreen:
			return current_scene as OriginSequenceJourneyScreen
	return null

func _wait_for_battle() -> BattleUI:
	for _frame in range(60):
		await process_frame
		if current_scene is BattleUI:
			return current_scene as BattleUI
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

func _finish(save_path: String, save_backup: Dictionary, encounter_path: String, encounter_backup: Dictionary, resume_path: String, resume_backup: Dictionary) -> void:
	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)
	if failures.is_empty():
		print("ORIGIN_BATTLE_DEFEAT_RETRY_ROUNDTRIP_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("ORIGIN_BATTLE_DEFEAT_RETRY_ROUNDTRIP_FAIL failures=%d" % failures.size())
		quit(1)

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
