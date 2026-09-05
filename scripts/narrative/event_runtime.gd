class_name EventRuntime
extends RefCounted

## Shared executor for narrative event choices.
## It owns validation and effect application; NarrativeState owns persistence.

static func from_data(data: Dictionary) -> EventDefinition:
	return EventDefinition.new(data)

static func can_present(event: EventDefinition, manager: NarrativeManager) -> bool:
	if event == null or event.is_empty() or manager == null:
		return false
	return _choice_for(event, manager) == ""

static func selected_choice(event: EventDefinition, manager: NarrativeManager) -> String:
	if event == null or manager == null:
		return ""
	return _choice_for(event, manager)

static func apply_choice(event: EventDefinition, manager: NarrativeManager, choice_id: String, namespace: String) -> bool:
	if event == null or event.is_empty() or manager == null or choice_id == "" or namespace == "":
		return false
	if _choice_for(event, manager) != "":
		return false
	var choice := event.get_choice(choice_id)
	if choice.is_empty():
		return false
	_apply_effects(manager, choice.get("effects", {}))
	if namespace == "ORIGIN":
		manager.state.record_origin_choice(event.get_id(), choice_id)
	elif namespace == "SHARED":
		manager.state.record_shared_choice(event.get_id(), choice_id)
	else:
		return false
	return true

static func _choice_for(event: EventDefinition, manager: NarrativeManager) -> String:
	if event.get_id() == "":
		return ""
	for prefix in ["ORIGIN", "SHARED"]:
		var value := ""
		if prefix == "ORIGIN":
			value = manager.state.get_origin_choice(event.get_id())
		else:
			value = manager.state.get_shared_choice(event.get_id())
		if value != "":
			return value
	return ""

static func _apply_effects(manager: NarrativeManager, effects_value: Variant) -> void:
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
