class_name WorldActionService
extends RefCounted

## Canonical executor for non-combat world actions emitted by EventRunner.
## It records persistent world facts without touching presentation scenes.

static func apply_move(manager, action: Dictionary) -> Dictionary:
	if manager == null or action.is_empty():
		return {}
	var map_id := str(action.get("map_id", ""))
	var marker_id := str(action.get("marker_id", ""))
	var location := marker_id
	if location.is_empty():
		location = map_id
	if location.is_empty():
		return {}
	manager.state.add_world_node_visit(location)
	return {
		"location": location,
		"map_id": map_id,
		"marker_id": marker_id,
		"world_state": manager.state.get_world_state(),
	}

static func complete_wait(action: Dictionary) -> Dictionary:
	if action.is_empty():
		return {}
	var seconds := maxf(float(action.get("seconds", 0.0)), 0.0)
	return {"seconds": seconds}
