class_name EventRuntime
extends RefCounted

## Shared executor for narrative event choices.
## It owns validation and effect application; the manager owns state persistence.
## Parameters are intentionally dynamic to keep this utility independent from
## concrete narrative manager global classes.

static func from_data(value):
	return EventDefinition.new(value)

static func can_present(event_value, state_owner, scope):
	if event_value == null or event_value.is_empty() or state_owner == null or not _valid_scope(scope):
		return false
	return _selected_choice(event_value, state_owner, scope) == ""

static func selected_choice(event_value, state_owner, scope):
	if event_value == null or state_owner == null or not _valid_scope(scope):
		return ""
	return _selected_choice(event_value, state_owner, scope)

static func apply_choice(event_value, state_owner, choice_value, scope):
	if event_value == null or event_value.is_empty() or state_owner == null or choice_value == "" or not _valid_scope(scope):
		return false
	if _selected_choice(event_value, state_owner, scope) != "":
		return false
	var choice: Dictionary = event_value.get_choice(choice_value)
	if choice.is_empty():
		return false
	_apply_effects(state_owner, choice.get("effects", {}))
	if scope == "ORIGIN":
		state_owner.state.record_origin_choice(event_value.get_id(), choice_value)
	else:
		state_owner.state.record_shared_choice(event_value.get_id(), choice_value)
	return true

static func _valid_scope(scope):
	return scope == "ORIGIN" or scope == "SHARED"

static func _selected_choice(event_value, state_owner, scope):
	if event_value.get_id() == "":
		return ""
	if scope == "ORIGIN":
		return state_owner.state.get_origin_choice(event_value.get_id())
	return state_owner.state.get_shared_choice(event_value.get_id())

static func _apply_effects(state_owner, effects_value):
	if not effects_value is Dictionary:
		return
	var effects: Dictionary = effects_value
	var relationships: Dictionary = effects.get("relationship_values", {})
	for key in relationships.keys():
		var relationship_id := str(key)
		if relationship_id != "":
			state_owner.state.relationship_values[relationship_id] = int(state_owner.state.relationship_values.get(relationship_id, 0)) + int(relationships[key])

	var milestones: Array = effects.get("milestones", [])
	for milestone in milestones:
		var milestone_id := str(milestone)
		if milestone_id != "" and milestone_id not in state_owner.state.completed_milestones:
			state_owner.state.completed_milestones.append(milestone_id)

	var rumors: Array = effects.get("world_rumors", [])
	for rumor in rumors:
		var rumor_id := str(rumor)
		if rumor_id != "":
			state_owner.state.add_world_rumor(rumor_id)

	var memories: Array = effects.get("memory_chapters", [])
	if not memories.is_empty():
		var memory_ids: Array[String] = []
		for memory in memories:
			memory_ids.append(str(memory))
		state_owner.state.add_memory_chapters(memory_ids)
