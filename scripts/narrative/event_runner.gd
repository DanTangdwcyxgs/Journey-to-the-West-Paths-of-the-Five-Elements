class_name EventRunner
extends RefCounted

## UI-independent event sequence state machine.
## It never renders. It returns action dictionaries for presentation/systems.
## Choice effects use the existing EventRuntime; battle nodes return EncounterHandoff data.

const DIALOGUE := "dialogue"
const CHOICE := "choice"
const WAIT := "wait"
const MOVE := "move"
const BATTLE := "battle"
const REWARD := "reward"
const JUMP := "jump"
const END := "end"

var sequence: EventSequenceDefinition
var manager: NarrativeManager
var current_node_id: String = ""
var pending_action: Dictionary = {}
var status: String = "idle"
var last_error: String = ""
var namespace: String = "SHARED"

func _init(definition: EventSequenceDefinition = null, narrative_manager: NarrativeManager = null, event_namespace: String = "SHARED") -> void:
	sequence = definition
	manager = narrative_manager
	namespace = event_namespace

func start() -> Dictionary:
	last_error = ""
	pending_action = {}
	status = "idle"
	if sequence == null or sequence.is_empty() or manager == null:
		return _fail("missing sequence or narrative manager")
	var validation := sequence.validate()
	if not validation.get("valid", false):
		return _fail("invalid sequence: %s" % ", ".join(validation.get("errors", [])))
	current_node_id = sequence.get_start_node_id()
	return _present_current_node()

func get_action() -> Dictionary:
	return pending_action.duplicate(true)

func is_waiting() -> bool:
	return status == "waiting"

func is_finished() -> bool:
	return status == "finished"

func has_error() -> bool:
	return status == "error"

func get_error() -> String:
	return last_error

func complete_action(result: Dictionary = {}) -> Dictionary:
	if status != "waiting" or pending_action.is_empty():
		return _fail("no pending action")
	var kind := str(pending_action.get("kind", ""))
	if kind == CHOICE:
		return _fail("choice action requires submit_choice")
	if kind == BATTLE:
		return _fail("battle action requires resolve_battle")
	if kind == END:
		status = "finished"
		pending_action = {}
		return {"kind": END, "sequence_id": sequence.get_id()}

	var next_id := str(pending_action.get("next", ""))
	if kind == JUMP:
		next_id = str(pending_action.get("target", next_id))
	if next_id.is_empty():
		return _finish_sequence()
	return _move_to(next_id)

func submit_choice(choice_id: String) -> Dictionary:
	if status != "waiting" or pending_action.get("kind", "") != CHOICE:
		return _fail("not waiting for a choice")
	var event_id := str(pending_action.get("event_id", ""))
	if event_id.is_empty():
		return _fail("choice node missing event_id")
	var event := _load_event(event_id)
	if event == null or event.is_empty():
		return _fail("event not found: %s" % event_id)
	if not EventRuntime.can_present(event, manager, namespace):
		return _fail("event cannot be presented: %s" % event_id)
	var choice := event.get_choice(choice_id)
	if choice.is_empty():
		return _fail("choice not found: %s" % choice_id)
	if not EventRuntime.apply_choice(event, manager, choice_id, namespace):
		return _fail("choice rejected: %s" % choice_id)
	var next_id := _resolve_choice_next(pending_action, choice)
	if next_id.is_empty():
		return _finish_sequence()
	return _move_to(next_id)

func resolve_battle(victory: bool) -> Dictionary:
	if status != "waiting" or pending_action.get("kind", "") != BATTLE:
		return _fail("not waiting for a battle")
	if not victory:
		return _fail("event battle did not resolve as victory")
	var next_id := str(pending_action.get("next", ""))
	if next_id.is_empty():
		return _finish_sequence()
	return _move_to(next_id)

func to_dict() -> Dictionary:
	return {
		"sequence_id": "" if sequence == null else sequence.get_id(),
		"current_node_id": current_node_id,
		"pending_action": pending_action.duplicate(true),
		"status": status,
		"last_error": last_error,
		"namespace": namespace,
	}

func restore(snapshot: Dictionary) -> bool:
	if sequence == null or manager == null:
		return false
	var sequence_id := str(snapshot.get("sequence_id", ""))
	if sequence_id != sequence.get_id():
		return false
	var node_id := str(snapshot.get("current_node_id", ""))
	if not node_id.is_empty() and not sequence.has_node(node_id):
		return false
	current_node_id = node_id
	pending_action = snapshot.get("pending_action", {}).duplicate(true)
	status = str(snapshot.get("status", "idle"))
	last_error = str(snapshot.get("last_error", ""))
	return true

func _present_current_node() -> Dictionary:
	var node := sequence.get_node(current_node_id)
	if node.is_empty():
		return _fail("node not found: %s" % current_node_id)
	var kind := str(node.get("type", node.get("kind", ""))).to_lower()
	if kind.is_empty():
		return _fail("node missing type: %s" % current_node_id)

	match kind:
		DIALOGUE:
			return _wait_with({
				"kind": DIALOGUE,
				"node_id": current_node_id,
				"speaker": str(node.get("speaker", "")),
				"text": str(node.get("text", "")),
				"portrait": str(node.get("portrait", "")),
				"next": _node_next(node),
			})
		CHOICE:
			return _present_choice(node)
		WAIT:
			return _wait_with({
				"kind": WAIT,
				"node_id": current_node_id,
				"seconds": float(node.get("seconds", 0.0)),
				"next": _node_next(node),
			})
		MOVE:
			return _wait_with({
				"kind": MOVE,
				"node_id": current_node_id,
				"map_id": str(node.get("map_id", "")),
				"marker_id": str(node.get("marker_id", "")),
				"position": node.get("position", null),
				"next": _node_next(node),
			})
		BATTLE:
			return _present_battle(node)
		REWARD:
			return _wait_with({
				"kind": REWARD,
				"node_id": current_node_id,
				"rewards": node.get("rewards", []).duplicate(true),
				"next": _node_next(node),
			})
		JUMP:
			return _wait_with({
				"kind": JUMP,
				"node_id": current_node_id,
				"target": str(node.get("target", node.get("next", ""))),
			})
		END:
			pending_action = {"kind": END, "node_id": current_node_id}
			status = "waiting"
			return pending_action.duplicate(true)
		_:
			return _fail("unsupported node type: %s" % kind)

func _present_choice(node: Dictionary) -> Dictionary:
	var event_id := str(node.get("event_id", ""))
	if event_id.is_empty():
		return _fail("choice node missing event_id")
	var event := _load_event(event_id)
	if event == null or event.is_empty():
		return _fail("event not found: %s" % event_id)
	if not EventRuntime.can_present(event, manager, namespace):
		return _fail("event cannot be presented: %s" % event_id)
	var action := {
		"kind": CHOICE,
		"node_id": current_node_id,
		"event_id": event_id,
		"title": event.get_title(),
		"text": event.get_text(),
		"choices": event.get_choices(),
	}
	return _wait_with(action)

func _present_battle(node: Dictionary) -> Dictionary:
	var encounter_id := str(node.get("encounter_id", ""))
	if encounter_id.is_empty():
		return _fail("battle node missing encounter_id")
	var encounter_type := str(node.get("encounter_type", namespace.to_lower()))
	var route_id := str(node.get("source_route_id", ""))
	if encounter_type == "shared" and route_id.is_empty():
		route_id = "SHARED_JOURNEY"
	var handoff := EncounterHandoff.new({
		"encounter_type": encounter_type,
		"encounter_id": encounter_id,
		"source_stage_id": str(node.get("source_stage_id", "")),
		"source_chapter_id": str(node.get("source_chapter_id", "")),
		"source_route_id": route_id,
	})
	if not handoff.is_valid():
		return _fail("invalid battle handoff")
	return _wait_with({
		"kind": BATTLE,
		"node_id": current_node_id,
		"handoff": handoff.to_dict(),
		"next": _node_next(node),
	})

func _move_to(node_id: String) -> Dictionary:
	if node_id.is_empty():
		return _finish_sequence()
	if not sequence.has_node(node_id):
		return _fail("next node not found: %s" % node_id)
	current_node_id = node_id
	pending_action = {}
	status = "running"
	return _present_current_node()

func _finish_sequence() -> Dictionary:
	current_node_id = ""
	pending_action = {"kind": END, "sequence_id": sequence.get_id()}
	status = "finished"
	return pending_action.duplicate(true)

func _wait_with(action: Dictionary) -> Dictionary:
	pending_action = action.duplicate(true)
	status = "waiting"
	return pending_action.duplicate(true)

func _fail(message: String) -> Dictionary:
	last_error = message
	status = "error"
	pending_action = {}
	return {}

func _node_next(node: Dictionary) -> String:
	return str(node.get("next", ""))

func _resolve_choice_next(node_action: Dictionary, choice: Dictionary) -> String:
	var choice_next := str(choice.get("next", ""))
	if not choice_next.is_empty():
		return choice_next
	var next_map: Dictionary = node_action.get("next_map", {})
	if not next_map.is_empty():
		return str(next_map.get(str(choice.get("id", "")), ""))
	return str(sequence.get_node(current_node_id).get("next", ""))

func _load_event(event_id: String) -> EventDefinition:
	var event_manager
	if namespace == "ORIGIN":
		event_manager = OriginEventManager.new()
	else:
		event_manager = SharedEventManager.new()
	return event_manager.get_definition(event_id)
