extends SceneTree

## A failed save at the story MOVE commit boundary must restore world state and
## leave the MOVE action retryable, rather than continuing to the next dialogue.
class SaveFailingNarrativeManager:
	extends NarrativeManager

	var save_attempts: int = 0

	func save(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		save_attempts += 1
		return false

	func load(_path: String = NarrativeSave.SAVE_PATH) -> bool:
		return true

func _initialize() -> void:
	await _run_smoke()

func _run_smoke() -> void:
	var encounter_path: String = BountyEncounterState.PATH
	var resume_path: String = BountyEncounterState.RESUME_PATH
	var encounter_backup := _capture_file(encounter_path)
	var resume_backup := _capture_file(resume_path)
	_remove_file(encounter_path)
	_remove_file(resume_path)

	var manager := SaveFailingNarrativeManager.new()
	_record(manager.start_new_game("WUKONG"), "Wukong test narrative should initialize")
	manager.encounter_character("TANG")
	manager.encounter_character("WUKONG")
	manager.state.mark_route_complete("WUKONG")
	manager.state.record_milestone("WUKONG_RECRUITED", 100)
	manager.state.current_global_timeline = 120
	manager.state.set_current_shared_chapter("SHARED-04-EARLY-DEMON-TALES")
	manager.state.add_world_node_visit("FIVE_ELEMENTS_MOUNTAIN")

	var journey := JourneyScreen.new()
	journey.narrative = manager
	root.add_child(journey)
	current_scene = journey
	await process_frame

	var definition: EventSequenceDefinition = EventSequenceManager.get_definition("SHARED-04-EARLY-DEMON-TALES-SEQUENCE")
	_record(definition != null, "production Shared-04 EventSequence should load")
	if definition != null:
		var session := NarrativeEventSession.new(definition, manager, "SHARED")
		var action := session.start()
		_record(str(action.get("kind", "")) == EventRunner.DIALOGUE, "Shared-04 should begin with departure dialogue")
		action = session.complete_action()
		_record(str(action.get("kind", "")) == EventRunner.MOVE, "Shared-04 should next emit the canonical MOVE action")

		journey.event_session = session
		journey.call("_handle_event_action", action)
		var before_move: Dictionary = manager.serialize().duplicate(true)
		journey.call("_start_event_transition", action)
		for _frame in range(90):
			await process_frame
			if not journey.event_transition_pending:
				break

		_record(manager.save_attempts == 1, "MOVE should attempt exactly one save before advancing the event cursor")
		_record(manager.serialize() == before_move, "failed movement save should restore the complete NarrativeState snapshot")
		_record(manager.state.get_world_state().get("current_location", "") == "FIVE_ELEMENTS_MOUNTAIN", "failed MOVE save must restore the previous current location")
		_record(session.get_action().get("kind", "") == EventRunner.MOVE, "failed MOVE save must leave the EventSession on the MOVE action")
		_record(not journey.event_transition_pending, "failed movement save should release the transition lock")
		_record(not journey.primary_button.disabled, "player should be able to retry the same MOVE")
		_record(journey.primary_button.text == "重试移动", "retry control should be explicit after movement save failure")
		_record(journey.phase_label.text.find("保存失败") >= 0, "failed movement persistence should be communicated to the player")

	var final_scene: Node = current_scene
	current_scene = null
	if is_instance_valid(final_scene):
		final_scene.free()
	await process_frame
	_restore_file(encounter_path, encounter_backup)
	_restore_file(resume_path, resume_backup)

	if failures.is_empty():
		print("STORY_MOVE_SAVE_FAILURE_ROLLBACK_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("STORY_MOVE_SAVE_FAILURE_ROLLBACK_FAIL failures=%d" % failures.size())
		quit(1)

var failures: Array[String] = []

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
