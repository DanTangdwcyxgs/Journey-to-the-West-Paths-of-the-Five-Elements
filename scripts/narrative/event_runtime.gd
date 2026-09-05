class_name EventRuntime
extends RefCounted

## Shared executor for narrative event choices.
## It owns validation and effect application; the manager owns state persistence.
## Parameters stay dynamic so this utility does not create global-class dependency cycles.

static func from_data(data):
	return EventDefinition.new(data)

static func can_present(event_def, manager, namespace):
	if event_def == null or event_def.is_empty() or manager == null or not _valid_namespace(namespace):
		return false
	return _selected_choice(event_def, manager, namespace) == ""

static func selected_choice(event_def, manager, namespace):
	if event_def == null or manager == null or not _valid_namespace(namespace):
		return ""
	return _selected_choice(event_def, manager, namespace)

static func apply_choice(event_def, manager, choice_id, namespace):
	if event_def == null or event_def.is_empty() or manager == null or choice_id == "" or not _valid_namespace(namespace):
		return false
	if _selected_choice(event_def, manager, namespace) != "":
		return false
	var choice: Dictionary = event_def.get_choice(choice_id)
	if choice.is_empty():
		return false
	_apply_effects(manager, choice.get("effects", {}))
	if namespace == "ORIGIN":
		manager.state.record_origin_choice(event_def.get_id(), choice_id)
	else:
		manager.state.record_shared_choice(event_def.get_id(), choice_id)
	return true

static func _valid_namespace(namespace):
	return namespace == "ORIGIN" or namespace == "SHARED"

static func _selected_choice(event_def, manager, namespace):
	if event_def.get_id() == "":
		return ""
	if namespace == "ORIGIN":
		return manager.state.get_origin_choice(event_def.get_id())
	return manager.state.get_shared_choice(event_def.get_id())

static func _apply_effects(manager, effects_value):
	if not effects_value is Dictionary:
		return
	var effects: Dictionary = effects_value
	var relationships: Dictionary = effects.get("relationship_values", {})
	for key in relationships.keys():
		var relationship_id := str(key)
		if relationship_id != "":
			manager.state.relationship_values[relationship_id] = int(manager.state.relationship_values.get(relationship_id, 0)) + int(relationships[key])

	var milestones: Array = effects.get("milestones", [])
	for milestone in milestones:
		var milestone_id := str(milestone)
		if milestone_id != "" and milestone_id not in manager.state.completed_milestones:
			manager.state.completed_milestones.append(milestone_id)

	var rumors: Array = effects.get("world_rumors", [])
	for rumor in rumors:
		var rumor_id := str(rumor)
		if rumor_id != "":
			manager.state.add_world_rumor(rumor_id)

	var memories: Array = effects.get("memory_chapters", [])
	if not memories.is_empty():
		var memory_ids: Array[String] = []
		for memory in memories:
			memory_ids.append(str(memory))
		manager.state.add_memory_chapters(memory_ids)
