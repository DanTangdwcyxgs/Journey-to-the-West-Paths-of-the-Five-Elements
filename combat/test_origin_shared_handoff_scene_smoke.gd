extends SceneTree

## Production end-to-end smoke for later-start Origins:
## saved handoff -> production Journey/MOVE -> recruitment choice -> BattleUI victory
## -> atomic settlement -> resumed dialogue/END -> production WorldMap travel.
## Every user:// file touched by the test is backed up and restored.

const CASES := [
	{
		"character": "LONGMA",
		"chapter": "SHARED-03-EAGLE-SORROW",
		"sequence": "SHARED-03-EAGLE-SORROW-SEQUENCE",
		"location": "EAGLE_SORROW",
		"handoff_gate_node": "EAGLE_SORROW",
		"choice_id": "SAVE_THE_DRAGON",
		"encounter_id": "SHARED_EAGLE_SORROW",
		"expected_recruit": "LONGMA",
		"next_chapter": "SHARED-04-EARLY-DEMON-TALES",
		"map_destination": "BLACK_WIND_NORTH_PATH",
		"advance_shared_before_map": true
	},
	{
		"character": "BAJIE",
		"chapter": "SHARED-05-GAOJIAZHUANG",
		"sequence": "SHARED-05-GAOJIAZHUANG-SEQUENCE",
		"location": "GAOJIAZHUANG",
		"handoff_gate_node": "BLACK_WIND_NORTH_PATH",
		"choice_id": "OFFER_REDEMPTION",
		"encounter_id": "SHARED_GAOJIAZHUANG",
		"expected_recruit": "BAJIE",
		"next_chapter": "SHARED-06-FOUR-PERSON-JOURNEY",
		"map_destination": "BLACK_WIND_NORTH_PATH",
		"advance_shared_before_map": false
	},
	{
		"character": "WUJING",
		"chapter": "SHARED-07-FLOWING-SANDS",
		"sequence": "SHARED-07-FLOWING-SANDS-SEQUENCE",
		"location": "FLOWING_SANDS",
		"handoff_gate_node": "GAOJIAZHUANG",
		"choice_id": "ACCEPT_WUJING",
		"encounter_id": "SHARED_FLOWING_SANDS",
		"expected_recruit": "WUJING",
		"next_chapter": "SHARED-08-PARTY-FULL",
		"map_destination": "DRAGON_BONE_SANCTUM",
		"advance_shared_before_map": true
	}
]

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

	var completed_cases := 0
	for case_variant in CASES:
		var spec: Dictionary = case_variant
		var character := str(spec["character"])
		var chapter_id := str(spec["chapter"])
		var encounter_id := str(spec["encounter_id"])
		var fixture := _prepare_handoff(character)
		_record(fixture != null, "%s Origin should finish and produce a Shared handoff save" % character)
		if fixture == null:
			break
		_record(fixture.state.current_shared_chapter == chapter_id, "%s handoff should target %s" % [character, chapter_id])
		_record(fixture.save(), "%s handoff fixture should persist before MainMenu Continue" % character)

		var menu_scene := load("res://ui/main_menu.tscn") as PackedScene
		_record(menu_scene != null, "production MainMenu scene should load")
		var menu: MainMenu = menu_scene.instantiate() as MainMenu if menu_scene != null else null
		_record(menu != null, "production MainMenu should instantiate")
		if menu == null:
			break
		root.add_child(menu)
		current_scene = menu
		await process_frame
		_record(not menu.continue_button.disabled, "%s Continue should be enabled for the saved handoff" % character)
		if menu.continue_button.disabled:
			break
		menu.continue_button.emit_signal("pressed")

		var journey := await _wait_for_journey()
		_record(journey != null, "%s MainMenu Continue should load production Journey" % character)
		if journey == null:
			break
		_record(journey.narrative.state.starting_character == character, "%s Journey should preserve its starting-character identity" % character)
		_record(journey.narrative.state.current_shared_chapter == chapter_id, "%s Journey should resume at %s" % [character, chapter_id])

		journey.call("_advance_primary")
		_record(journey.event_session != null, "%s Journey should start its first Shared EventSequence" % character)
		if journey.event_session == null:
			break
		_record(journey.event_session.sequence.get_id() == str(spec["sequence"]), "%s should load the expected production sequence" % character)
		var first_action: Dictionary = journey.event_session.get_action()
		_record(str(first_action.get("kind", "")) == EventRunner.DIALOGUE, "%s Shared sequence should begin with canonical dialogue" % character)
		if str(first_action.get("kind", "")) != EventRunner.DIALOGUE:
			break

		journey.call("_reveal_dialogue_immediately")
		journey.call("_advance_primary")
		var move_action: Dictionary = journey.event_session.get_action()
		_record(str(move_action.get("kind", "")) == EventRunner.MOVE, "%s Shared sequence should reach its first canonical MOVE" % character)
		if str(move_action.get("kind", "")) != EventRunner.MOVE:
			break
		_record(str(move_action.get("marker_id", "")) == str(spec["location"]), "%s MOVE should target its canonical story location" % character)

		journey.call("_advance_primary")
		var moved := false
		for _frame in range(120):
			await process_frame
			if current_scene != journey:
				break
			var world_state: Dictionary = journey.narrative.state.get_world_state()
			if str(world_state.get("current_location", "")) == str(spec["location"]) and not journey.event_transition_pending:
				moved = true
				break
		_record(moved, "%s production MOVE should commit its story-established map location" % character)
		if not moved:
			break
		var moved_world: Dictionary = journey.narrative.state.get_world_state()
		_record(str(moved_world.get("current_location", "")) == str(spec["location"]), "%s current location should match the canonical MOVE" % character)
		_record(str(spec["location"]) in moved_world.get("visited_nodes", []), "%s MOVE should persist the visited-node fact" % character)
		_record(str(journey.event_session.get_action().get("kind", "")) == EventRunner.CHOICE, "%s EventSequence should resume at its recruitment choice after MOVE" % character)
		_record(journey.narrative.state.current_shared_chapter == chapter_id, "%s MOVE alone must not complete its Shared chapter" % character)
		var reloaded_move := NarrativeManager.new()
		_record(reloaded_move.load(), "%s MOVE should leave a loadable save" % character)
		if reloaded_move.state != null:
			_record(reloaded_move.state.get_world_state().get("current_location", "") == str(spec["location"]), "%s story location should persist after reload" % character)
			_record(reloaded_move.state.current_shared_chapter == chapter_id, "%s story MOVE must preserve the current Shared chapter" % character)

		var prebattle_map := WorldMapManager.new()
		_record(prebattle_map.can_visit(journey.narrative, str(spec["handoff_gate_node"])), "%s should satisfy its route-appropriate handoff WorldMap gate" % character)

		var battle := await _drive_journey_into_battle(journey, spec)
		_record(battle != null, "%s recruitment choice should enter the production BattleUI" % character)
		if battle == null:
			break
		_record(battle.encounter_type == "shared", "%s recruitment scene should preserve shared encounter type" % character)
		_record(battle.encounter_id == encounter_id, "%s recruitment should launch canonical encounter %s" % [character, encounter_id])

		var pre_battle_record := BountyEncounterState.get_active_record()
		_record(str(pre_battle_record.get("source_chapter_id", "")) == chapter_id, "%s battle handoff should preserve its source chapter" % character)
		_record(str(pre_battle_record.get("encounter_id", "")) == encounter_id, "%s battle handoff should preserve its encounter ID" % character)
		_record(not pre_battle_record.get("event_resume", {}).is_empty(), "%s battle handoff should preserve the pending EventSession snapshot" % character)

		battle.call_deferred("_on_combat_finished", "allies")
		await process_frame
		await process_frame
		_record(battle.encounter_resolved, "%s production BattleUI victory should resolve" % character)
		_record(battle.status_label != null and battle.status_label.text.find("共享章节完成") >= 0, "%s victory UI should show shared chapter completion" % character)
		_record(battle.status_label != null and battle.status_label.text.find("奖励：") >= 0, "%s victory UI should show rewards" % character)
		_record(battle.return_button != null and battle.return_button.text == "继续旅途", "%s victory UI should expose Continue Journey" % character)
		if not battle.encounter_resolved or battle.return_button == null:
			break

		var committed := NarrativeManager.new()
		_record(committed.load(), "%s victory should persist a loadable narrative" % character)
		if committed.state == null:
			break
		_record(committed.state.current_shared_chapter == str(spec["next_chapter"]), "%s victory should advance to %s" % [character, str(spec["next_chapter"])])
		_record(committed.state.recruited_characters.count(str(spec["expected_recruit"])) == 1, "%s victory should recruit exactly one %s" % [character, str(spec["expected_recruit"])])
		_record(chapter_id in committed.state.completed_shared_chapters, "%s source chapter should be recorded as completed" % character)
		_record(str(committed.state.get_world_state().get("current_location", "")) == str(spec["location"]), "%s battle settlement should preserve its story-established map location" % character)
		var timeline_after_battle := committed.state.current_global_timeline

		# A stale second victory callback must be rejected without changing any saved fact.
		var committed_before_duplicate := committed.serialize().duplicate(true)
		var encounter_manager := EncounterManager.new()
		var encounter_definition: Dictionary = encounter_manager.get_definition(encounter_id)
		_record(not encounter_definition.is_empty(), "%s encounter definition should remain available for duplicate-settlement guard" % character)
		var duplicate_result := BattleResolutionService.resolve_narrative_victory(
			committed,
			"shared",
			encounter_id,
			str(pre_battle_record.get("source_stage_id", "")),
			chapter_id,
			str(pre_battle_record.get("source_route_id", "SHARED_JOURNEY")),
			str(encounter_definition.get("name", encounter_id)),
			encounter_definition.get("rewards", []),
			encounter_definition.get("world_effects", []),
			encounter_manager
		)
		_record(duplicate_result.is_empty(), "%s duplicate/stale victory settlement should be rejected" % character)
		_record(committed.serialize() == committed_before_duplicate, "%s stale settlement must not duplicate rewards, recruitment, timeline, or chapter progress" % character)

		battle.return_button.emit_signal("pressed")
		var resumed_journey := await _wait_for_journey()
		if resumed_journey == null:
			_record(false, "%s Continue Journey should restore production Journey" % character)
			break
		_record(resumed_journey.event_session != null, "%s Journey should restore EventSession after battle" % character)
		if resumed_journey.event_session == null:
			break
		var resumed_action: Dictionary = resumed_journey.event_session.get_action()
		_record(str(resumed_action.get("kind", "")) == EventRunner.DIALOGUE, "%s EventSession should resume at post-battle dialogue" % character)
		_record(not str(resumed_action.get("text", "")).is_empty(), "%s post-battle dialogue should contain text" % character)

		var ended := await _drive_resumed_session_to_end(resumed_journey, chapter_id)
		_record(ended, "%s resumed post-battle session should reach END through Journey UI" % character)
		_record(resumed_journey.event_session == null, "%s END should close the active EventSession" % character)
		_record(resumed_journey.phase_label != null and resumed_journey.phase_label.text.find("战后剧情完成") >= 0, "%s END should show post-battle completion feedback" % character)
		_record(not FileAccess.file_exists(encounter_path), "%s END should clear the active encounter handoff" % character)
		_record(not FileAccess.file_exists(resume_path), "%s END should clear the pending resume record" % character)

		var persisted_after_end := NarrativeManager.new()
		_record(persisted_after_end.load(), "%s END should leave a loadable save" % character)
		if persisted_after_end.state == null:
			break
		_record(persisted_after_end.state.current_shared_chapter == str(spec["next_chapter"]), "%s END must not advance the chapter a second time" % character)
		_record(str(spec["expected_recruit"]) in persisted_after_end.state.recruited_characters, "%s recruit should persist after END" % character)
		_record(persisted_after_end.state.recruited_characters.count(str(spec["expected_recruit"])) == 1, "%s roster should not contain a duplicate recruit" % character)
		_record(chapter_id in persisted_after_end.state.completed_shared_chapters, "%s should remain recorded as completed after END" % character)
		_record(persisted_after_end.state.current_global_timeline == timeline_after_battle, "%s END should not advance the canonical timeline twice" % character)
		_record(str(persisted_after_end.state.get_world_state().get("current_location", "")) == str(spec["location"]), "%s END should preserve the story location" % character)

		# Reach the next map destination only after its real timeline/milestone gates are met.
		if character == "LONGMA":
			_record(not WorldMapManager.new().can_visit(resumed_journey.narrative, "BLACK_WIND_NORTH_PATH"), "Longma's T110 post-recruitment save must not enter the T120 North Path early")
			_record(not resumed_journey.primary_button.disabled, "Shared-04 should expose an enabled Journey continue control (phase=%s)" % resumed_journey.phase_label.text)
			_record(resumed_journey.narrative.state.current_shared_chapter == "SHARED-04-EARLY-DEMON-TALES", "Longma battle should hand off to Shared-04 before the next map gate")
			_record(SharedJourneyManager.can_enter("SHARED-04-EARLY-DEMON-TALES", resumed_journey.narrative.state), "Shared-04 should satisfy its canonical prerequisite/recruitment gates")
			resumed_journey.primary_button.emit_signal("pressed")
			await process_frame
			await process_frame
			_record(resumed_journey.narrative.state.current_shared_chapter == "SHARED-05-GAOJIAZHUANG", "completing the non-combat Shared-04 step should advance to Gaojiazhuang (phase=%s, button=%s, disabled=%s)" % [resumed_journey.phase_label.text, resumed_journey.primary_button.text, str(resumed_journey.primary_button.disabled)])
			_record(resumed_journey.narrative.state.current_global_timeline == 120, "Shared-04 should advance the timeline to T120 (current=%d)" % resumed_journey.narrative.state.current_global_timeline)
		elif character == "WUJING":
			_record(not WorldMapManager.new().can_visit(resumed_journey.narrative, "DRAGON_BONE_SANCTUM"), "Dragon Bone Sanctum must remain locked before the T170 mainline milestone")
			_record(_press_shared_choice(resumed_journey, "PARTY_FULL", "SWEAR_TOGETHER"), "Wujing's next production Journey step should expose the canonical Party Full choice")
			await process_frame
			resumed_journey.primary_button.emit_signal("pressed")
			await process_frame
			_record(resumed_journey.narrative.state.current_shared_chapter == "SHARED-09-FULL-PILGRIMAGE", "Party Full choice should complete Shared-08 and unlock the final shared pilgrimage chapter")
			resumed_journey.primary_button.emit_signal("pressed")
			await process_frame
			_record(resumed_journey.narrative.state.current_global_timeline == 170, "Shared-09 should advance the timeline to T170 without changing the recruited roster")

		# Load the actual production WorldMap UI from the persisted save.
		var roster_before_travel: Array = resumed_journey.narrative.state.recruited_characters.duplicate()
		var chapter_before_travel := resumed_journey.narrative.state.current_shared_chapter
		var timeline_before_travel := resumed_journey.narrative.state.current_global_timeline
		resumed_journey.world_button.emit_signal("pressed")
		var world_map := await _wait_for_world_map()
		_record(world_map != null, "%s Journey Map control should open production WorldMap" % character)
		if world_map == null:
			break
		var destination_id := str(spec["map_destination"])
		var destination: Dictionary = world_map.world.get_node(destination_id)
		var destination_name := str(destination.get("name", destination_id))
		var destination_index := _find_node(world_map, destination_name)
		_record(destination_index >= 0, "%s WorldMap should display the route-appropriate reachable destination %s" % [character, destination_name])
		if destination_index < 0:
			break
		world_map.node_list.select(destination_index)
		world_map.call("_on_node_selected", destination_index)
		_record(not world_map.travel_button.disabled, "%s WorldMap should enable travel to %s" % [character, destination_id])
		world_map.travel_button.emit_signal("pressed")
		await process_frame
		_record(str(world_map.narrative.state.get_world_state().get("current_location", "")) == destination_id, "%s production WorldMap travel should commit destination %s" % [character, destination_id])
		_record(destination_id in world_map.narrative.state.get_world_state().get("visited_nodes", []), "%s destination should be recorded in visited nodes" % character)
		_record(world_map.narrative.state.current_shared_chapter == chapter_before_travel, "%s optional map travel must not advance the Shared chapter" % character)
		_record(world_map.narrative.state.current_global_timeline == timeline_before_travel, "%s optional map travel must not advance the global timeline" % character)
		_record(world_map.narrative.state.recruited_characters == roster_before_travel, "%s optional map travel must not mutate the party roster" % character)
		var map_reload := NarrativeManager.new()
		_record(map_reload.load(), "%s WorldMap travel should persist a loadable save" % character)
		if map_reload.state != null:
			_record(str(map_reload.state.get_world_state().get("current_location", "")) == destination_id, "%s map location should persist after reload" % character)
			_record(map_reload.state.current_shared_chapter == chapter_before_travel, "%s map reload should preserve the chapter pointer" % character)
			_record(map_reload.state.current_global_timeline == timeline_before_travel, "%s map reload should preserve the global timeline" % character)
			_record(map_reload.state.recruited_characters == roster_before_travel, "%s map reload should preserve the recruited roster" % character)

		completed_cases += 1
		var active_scene: Node = current_scene
		current_scene = null
		if is_instance_valid(active_scene):
			active_scene.free()
		await process_frame

	var active_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(active_scene):
		active_scene.free()
	await process_frame
	_restore_file(save_path, save_backup)
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty() and completed_cases == CASES.size():
		print("ORIGIN_SHARED_HANDOFF_FULL_FLOW_PASS cases=%d" % completed_cases)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		if completed_cases != CASES.size():
			push_error("ORIGIN_SHARED_HANDOFF_FULL_FLOW_INCOMPLETE cases=%d/%d" % [completed_cases, CASES.size()])
		print("ORIGIN_SHARED_HANDOFF_FULL_FLOW_FAIL failures=%d" % failures.size())
		quit(1)

func _prepare_handoff(character_id: String) -> NarrativeManager:
	var narrative := NarrativeManager.new()
	if not narrative.start_new_game(character_id):
		_record(false, "%s Origin should initialize" % character_id)
		return null
	var guard := 0
	while not narrative.origin_routes.is_complete(narrative, character_id):
		guard += 1
		if guard >= 64:
			_record(false, "%s Origin should complete within the chapter guard" % character_id)
			return null
		if narrative.complete_origin_chapter(character_id).is_empty():
			_record(false, "%s Origin chapter progression should remain valid" % character_id)
			return null
	if not narrative.handoff_origin_to_shared(character_id):
		_record(false, "%s Origin should reconcile into Shared Journey" % character_id)
		return null
	return narrative

func _drive_journey_into_battle(journey: JourneyScreen, spec: Dictionary) -> BattleUI:
	for _step in range(64):
		await process_frame
		if current_scene is BattleUI:
			return current_scene as BattleUI
		if current_scene != journey or journey.event_session == null:
			return null
		var action: Dictionary = journey.event_session.get_action()
		match str(action.get("kind", "")):
			EventRunner.DIALOGUE:
				if journey.dialogue_revealing:
					journey.call("_reveal_dialogue_immediately")
				else:
					journey.primary_button.emit_signal("pressed")
			EventRunner.CHOICE:
				if not _press_event_choice(journey, action, str(spec["choice_id"])):
					_record(false, "%s canonical recruitment choice button should exist" % str(spec["chapter"]))
					return null
			EventRunner.WAIT, EventRunner.MOVE:
				var kind := str(action.get("kind", ""))
				var seconds := maxf(float(action.get("seconds", 0.0)), 0.35) + 0.12
				journey.primary_button.emit_signal("pressed")
				await create_timer(seconds).timeout
				if kind == EventRunner.MOVE:
					_record(str(journey.narrative.state.get_world_state().get("current_location", "")) == str(spec["location"]), "%s pre-battle story MOVE should retain its canonical destination" % str(spec["character"]))
			EventRunner.BATTLE:
				journey.primary_button.emit_signal("pressed")
			_:
				_record(false, "%s recruitment sequence reached an unexpected action: %s" % [str(spec["character"]), str(action.get("kind", ""))])
				return null
	return null

func _press_event_choice(journey: JourneyScreen, action: Dictionary, choice_id: String) -> bool:
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

func _press_shared_choice(journey: JourneyScreen, event_id: String, choice_id: String) -> bool:
	var event := SharedEventManager.new().get_event(event_id)
	var selected_label := ""
	for choice in event.get("choices", []):
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

func _drive_resumed_session_to_end(journey: JourneyScreen, chapter_id: String) -> bool:
	for _step in range(32):
		await process_frame
		if journey.event_session == null:
			return true
		var action: Dictionary = journey.event_session.get_action()
		match str(action.get("kind", "")):
			EventRunner.DIALOGUE:
				journey.primary_button.emit_signal("pressed")
			EventRunner.END:
				journey.primary_button.emit_signal("pressed")
			EventRunner.WAIT, EventRunner.MOVE:
				var seconds := maxf(float(action.get("seconds", 0.0)), 0.35) + 0.12
				journey.primary_button.emit_signal("pressed")
				await create_timer(seconds).timeout
			_:
				_record(false, "%s resumed session reached unexpected action before END: %s" % [chapter_id, str(action.get("kind", ""))])
				return false
	return journey.event_session == null

func _find_node(world_map: WorldMapScreen, label: String) -> int:
	for index in range(world_map.node_list.get_item_count()):
		if world_map.node_list.get_item_text(index).find(label) >= 0:
			return index
	return -1

func _wait_for_world_map() -> WorldMapScreen:
	for _frame in range(60):
		await process_frame
		if current_scene is WorldMapScreen:
			return current_scene as WorldMapScreen
	return null

func _wait_for_journey() -> JourneyScreen:
	for _frame in range(60):
		await process_frame
		if current_scene is JourneyScreen:
			return current_scene as JourneyScreen
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
