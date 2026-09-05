class_name NarrativeEventSession
extends RefCounted

## Orchestration layer between event runtime, battle handoff and presentation.
## It deliberately knows nothing about UI scenes.

var sequence: EventSequenceDefinition
var runner: EventRunner
var narrative_manager
var namespace_id: String = "SHARED"

func _init(definition: EventSequenceDefinition = null, manager = null, event_namespace_id: String = "SHARED") -> void:
	sequence = definition
	narrative_manager = manager
	namespace_id = event_namespace_id
	if sequence != null and narrative_manager != null:
		runner = EventRunner.new(sequence, narrative_manager, namespace_id)

func start() -> Dictionary:
	if runner == null:
		return {}
	return runner.start()

func get_action() -> Dictionary:
	if runner == null:
		return {}
	return runner.get_action()

func complete_action(result: Dictionary = {}) -> Dictionary:
	if runner == null:
		return {}
	return runner.complete_action(result)

func submit_choice(choice_id: String) -> Dictionary:
	if runner == null:
		return {}
	return runner.submit_choice(choice_id)

func resolve_battle(victory: bool) -> Dictionary:
	if runner == null:
		return {}
	return runner.resolve_battle(victory)

func is_waiting_for_battle() -> bool:
	var action := get_action()
	return runner != null and runner.is_waiting() and action.get("kind", "") == EventRunner.BATTLE

func create_battle_handoff() -> Dictionary:
	if not is_waiting_for_battle():
		return {}
	var action := get_action()
	return action.get("handoff", {}).duplicate(true)

func to_dict() -> Dictionary:
	return {
		"sequence": {} if sequence == null else sequence.to_dict(),
		"namespace": namespace_id,
		"runner": {} if runner == null else runner.to_dict(),
	}

func restore(snapshot: Dictionary, manager) -> bool:
	var sequence_data: Dictionary = snapshot.get("sequence", {})
	if sequence_data.is_empty():
		return false
	var restored_sequence := EventSequenceDefinition.new(sequence_data)
	if not restored_sequence.validate().get("valid", false):
		return false
	var restored_namespace := str(snapshot.get("namespace", "SHARED"))
	var restored_runner := EventRunner.new(restored_sequence, manager, restored_namespace)
	if not restored_runner.restore(snapshot.get("runner", {})):
		return false
	sequence = restored_sequence
	narrative_manager = manager
	namespace_id = restored_namespace
	runner = restored_runner
	return true

func start_battle_handoff() -> Dictionary:
	if not is_waiting_for_battle():
		return {}
	var handoff := create_battle_handoff()
	if handoff.is_empty():
		return {}
	var record := handoff.duplicate(true)
	record["event_resume"] = {
		"sequence": {} if sequence == null else sequence.to_dict(),
		"namespace": namespace_id,
		"runner": runner.to_dict(),
	}
	return record

static func resume_from_battle_record(record: Dictionary, manager) -> NarrativeEventSession:
	var resume: Dictionary = record.get("event_resume", {})
	if resume.is_empty():
		return null
	var session := NarrativeEventSession.new()
	if not session.restore(resume, manager):
		return null
	# A battle handoff is persisted while the runner is waiting on the battle
	# node. Once combat has already reported victory, restore the runner past
	# that node so the next presentation action is deterministic and cannot
	# re-enter the completed battle.
	if session.is_waiting_for_battle():
		if session.resolve_battle(true).is_empty():
			return null
	return session
