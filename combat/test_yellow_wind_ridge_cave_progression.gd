extends SceneTree

class ToggleSaveNarrativeManager:
	extends NarrativeManager

	var save_succeeds: bool = false
	var save_attempts: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		return save_succeeds

class IsolatedYellowWindRidgeScreen:
	extends YellowWindRidgeScreen

	var injected_narrative: NarrativeManager
	var cave_transition_requested: bool = false

	func _ready() -> void:
		narrative = injected_narrative
		ridge = YellowWindRidgeManager.new()
		_build_ui()
		_refresh()

	func _change_to_cave() -> void:
		cave_transition_requested = true

class IsolatedYellowWindCaveScreen:
	extends YellowWindCaveScreen

	var injected_narrative: NarrativeManager

	func _ready() -> void:
		narrative = injected_narrative
		_load_data()
		current_room_index = _recover_room_index()
		_build_ui()
		_refresh()

var failures: Array[String] = []

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var manager := ToggleSaveNarrativeManager.new()
	_record(manager.start_new_game("WUKONG"), "Wukong should initialize the Yellow Wind fixture")
	manager.encounter_character("TANG", [])
	manager.encounter_character("WUKONG", [])
	var memories: Array[String] = ["LONGMA-01", "LONGMA-02"]
	_record(manager.encounter_character("LONGMA", memories), "Longma should be recruited for the post-Shared-04 exploration fixture")
	manager.state.record_milestone("WUKONG_RECRUITED", 100)
	manager.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
	manager.state.current_global_timeline = 120
	manager.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
	var ridge_manager := YellowWindRidgeManager.new()

	_record(ridge_manager.is_available(manager), "Yellow Wind Ridge should unlock at T120 after Longma recruitment on Black Wind North Path")
	var saved_state := manager.serialize().duplicate(true)
	manager.state.add_world_node_visit("EAGLE_SORROW")
	_record(not ridge_manager.is_available(manager), "Yellow Wind Ridge should not be entered from a different current map location")
	manager.restore_snapshot(saved_state)

	var ridge := IsolatedYellowWindRidgeScreen.new()
	ridge.injected_narrative = manager
	root.add_child(ridge)
	current_scene = ridge
	await process_frame

	_record(ridge.selected_stage_id == "RIDGE_ENTRY", "new ridge visits should begin at RIDGE_ENTRY")
	_record(str(ridge.ridge.get_current_stage(manager).get("id", "")) == "RIDGE_ENTRY", "RIDGE_ENTRY should be the only actionable stage initially")
	ridge.call("_on_stage_selected", 3)
	_record(ridge.selected_stage_id == "RIDGE_ENTRY", "selecting the future cave gate must not skip earlier stages")
	_record(ridge.status_label.text.find("请先完成当前阶段") >= 0, "future stage selection should explain why it is locked")

	var entry_before: Dictionary = manager.serialize().duplicate(true)
	var entry_button := _find_button(ridge.action_box, "跟随商旅脚印")
	_record(entry_button != null, "RIDGE_ENTRY should expose its caravan choice")
	if entry_button != null:
		entry_button.emit_signal("pressed")
		await process_frame
		_record(manager.save_attempts == 1, "RIDGE_ENTRY should attempt a save after choosing")
		_record(manager.serialize() == entry_before, "RIDGE_ENTRY save failure should roll back milestone and rumor state")
		_record(str(ridge.ridge.get_current_stage(manager).get("id", "")) == "RIDGE_ENTRY", "failed RIDGE_ENTRY save should keep the same choice retryable")
		_record(ridge.status_label.text.find("保存失败") >= 0, "RIDGE_ENTRY save failure should be visible")
		manager.save_succeeds = true
		await process_frame
		var retry_entry := _find_button(ridge.action_box, "跟随商旅脚印")
		_record(retry_entry != null, "RIDGE_ENTRY choice should remain visible for retry")
		if retry_entry != null:
			retry_entry.emit_signal("pressed")
			await process_frame
		_record(str(ridge.ridge.get_current_stage(manager).get("id", "")) == "ABANDONED_INN", "successful first-stage save should unlock the abandoned inn")

	manager.save_succeeds = false
	var inn_before: Dictionary = manager.serialize().duplicate(true)
	var inn_button := _find_button(ridge.action_box, "调查并记录情报")
	_record(inn_button != null, "ABANDONED_INN should expose its inspect action")
	if inn_button != null:
		inn_button.emit_signal("pressed")
		await process_frame
		_record(manager.serialize() == inn_before, "abandoned inn save failure should roll back the milestone and rumor")
		_record(str(ridge.ridge.get_current_stage(manager).get("id", "")) == "ABANDONED_INN", "failed inn save should leave that stage current and retryable")
		manager.save_succeeds = true
		await process_frame
		var retry_inn := _find_button(ridge.action_box, "调查并记录情报")
		if retry_inn != null:
			retry_inn.emit_signal("pressed")
			await process_frame
		_record(str(ridge.ridge.get_current_stage(manager).get("id", "")) == "SANDSTORM_PASS", "successful inn completion should unlock the storm pass")

	manager.save_succeeds = true
	var storm_choice := _find_button(ridge.action_box, "顶着沙暴前进")
	_record(storm_choice != null, "SANDSTORM_PASS should expose its choices")
	if storm_choice != null:
		storm_choice.emit_signal("pressed")
		await process_frame
	_record(str(ridge.ridge.get_current_stage(manager).get("id", "")) == "YELLOW_WIND_GATE", "only the first three completed stages should unlock the cave gate")

	manager.save_succeeds = false
	var before_gate: Dictionary = manager.serialize().duplicate(true)
	var gate_button := _find_button(ridge.action_box, "进入黄风洞 · 灰盒地城")
	_record(gate_button != null, "the current ridge gate should expose the cave entry button")
	if gate_button != null:
		gate_button.emit_signal("pressed")
		await process_frame
		_record(manager.serialize() == before_gate, "failed gate save should roll back YELLOW_WIND_GATE_OPEN")
		_record(not ridge.cave_transition_requested, "failed gate save must not enter the cave")
		_record(ridge.status_label.text.find("保存失败") >= 0, "failed gate save should be visible")
		manager.save_succeeds = true
		await process_frame
		var retry_gate := _find_button(ridge.action_box, "进入黄风洞 · 灰盒地城")
		if retry_gate != null:
			retry_gate.emit_signal("pressed")
			await process_frame
		_record("YELLOW_WIND_GATE_OPEN" in manager.state.completed_milestones, "successful gate save should persist cave access")
		_record(ridge.cave_transition_requested, "successful gate save should transition to the cave")

	var denied_manager := NarrativeManager.new()
	_record(denied_manager.start_new_game("WUKONG"), "unauthorized cave test should initialize")
	denied_manager.state.add_world_node_visit("BLACK_WIND_NORTH_PATH")
	denied_manager.state.current_global_timeline = 120
	denied_manager.state.record_milestone("BAI_LONGMA_RECRUITED", 110)
	var denied_cave := YellowWindCaveScreen.new()
	denied_cave.narrative = denied_manager
	_record(not bool(denied_cave.call("_has_gate_access")), "direct cave entry must be denied before the ridge gate opens")
	denied_cave.free()

	var cave := IsolatedYellowWindCaveScreen.new()
	cave.injected_narrative = manager
	ridge.queue_free()
	await process_frame
	root.add_child(cave)
	current_scene = cave
	await process_frame
	_record(cave._has_gate_access(), "the production cave gate check should accept the saved ridge unlock")
	_record(cave.current_room_index == 0, "new cave visits should start at CAVE_MOUTH")

	manager.save_succeeds = false
	var mouth_before: Dictionary = manager.serialize().duplicate(true)
	var explore_button := _find_button(cave.action_box, "搜索并继续前进")
	_record(explore_button != null, "CAVE_MOUTH should expose the search action")
	if explore_button != null:
		explore_button.emit_signal("pressed")
		await process_frame
		_record(manager.serialize() == mouth_before, "failed CAVE_MOUTH save should roll back room progress")
		_record(cave.current_room_index == 0, "failed CAVE_MOUTH save should keep the same room current")
		_record(cave.status_label.text.find("保存失败") >= 0, "failed cave room save should be visible")
		manager.save_succeeds = true
		await process_frame
		var retry_mouth := _find_button(cave.action_box, "搜索并继续前进")
		if retry_mouth != null:
			retry_mouth.emit_signal("pressed")
			await process_frame
		_record(cave.current_room_index == 1, "successful room save should advance to SAND_ALTAR")
		_record((YellowWindCaveScreen.PROGRESS_PREFIX + "CAVE_MOUTH") in manager.state.get_world_state().get("heard_rumors", []), "CAVE_MOUTH completion should persist in exploration history")

	manager.save_succeeds = false
	var altar_before: Dictionary = manager.serialize().duplicate(true)
	var talisman_choice := _find_button(cave.action_box, "以火试符")
	_record(talisman_choice != null, "SAND_ALTAR should expose its fire choice")
	if talisman_choice != null:
		talisman_choice.emit_signal("pressed")
		await process_frame
		_record(manager.serialize() == altar_before, "failed SAND_ALTAR choice save should roll back both room and choice markers")
		_record(cave.current_room_index == 1, "failed altar save should leave SAND_ALTAR current")
		manager.save_succeeds = true
		await process_frame
		var retry_talisman := _find_button(cave.action_box, "以火试符")
		if retry_talisman != null:
			retry_talisman.emit_signal("pressed")
			await process_frame
		_record(cave.current_room_index == 2, "successful altar choice should advance to SANDSTORM_HALL")
		_record(("YELLOW_WIND_CAVE_CHOICE_BURN_TALISMAN" in manager.state.get_world_state().get("heard_rumors", [])), "successful altar choice should persist its chosen outcome")
		_record((YellowWindCaveScreen.PROGRESS_PREFIX + "SAND_ALTAR") in manager.state.get_world_state().get("heard_rumors", []), "successful altar choice should persist room completion")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame
	if failures.is_empty():
		print("YELLOW_WIND_RIDGE_CAVE_PROGRESSION_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("YELLOW_WIND_RIDGE_CAVE_PROGRESSION_FAIL failures=%d" % failures.size())
		quit(1)

func _find_button(parent: Node, target_text: String) -> Button:
	for child in parent.get_children():
		var button := child as Button
		if button != null and button.text == target_text:
			return button
		var nested: Button = _find_button(child, target_text)
		if nested != null:
			return nested
	return null

func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
