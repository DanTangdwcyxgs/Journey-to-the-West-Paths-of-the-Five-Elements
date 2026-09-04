class_name WorldMapManager
extends RefCounted

## Data-driven exploration layer. Main-story chronology remains authoritative.
const MAP_PATH := "res://data/world/world_map.json"
const RUMOR_PATH := "res://data/world/rumors.json"

var nodes: Dictionary = {}
var rumors: Dictionary = {}

func _init() -> void:
	_load_json(MAP_PATH, "nodes", nodes)
	_load_json(RUMOR_PATH, "rumors", rumors)

func ensure_initialized(narrative: NarrativeManager) -> void:
	if narrative == null:
		return
	var world := narrative.state.get_world_state()
	if str(world.get("current_location", "")) == "":
		var first := _first_available_node(narrative)
		if first != "":
			narrative.state.add_world_node_visit(first)

func get_current_location(narrative: NarrativeManager) -> String:
	if narrative == null:
		return ""
	return str(narrative.state.get_world_state().get("current_location", ""))

func get_node(node_id: String) -> Dictionary:
	return nodes.get(node_id, {}).duplicate(true)

func get_all_nodes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in nodes.values():
		result.append(value.duplicate(true))
	result.sort_custom(func(a, b): return int(a.get("timeline", 0)) < int(b.get("timeline", 0)))
	return result

func can_visit(narrative: NarrativeManager, node_id: String) -> bool:
	if narrative == null or not nodes.has(node_id):
		return false
	var node: Dictionary = nodes[node_id]
	if narrative.state.current_global_timeline < int(node.get("timeline", 0)):
		return false
	for milestone in node.get("required_milestones", []):
		if str(milestone) not in narrative.state.completed_milestones:
			return false
	var current := get_current_location(narrative)
	if current == "" or current == node_id:
		return true
	var connections:Array = node.get("connections", [])
	return current in connections

func visit(narrative: NarrativeManager, node_id: String) -> bool:
	if not can_visit(narrative, node_id):
		return false
	narrative.state.add_world_node_visit(node_id)
	return true

func get_reachable_nodes(narrative: NarrativeManager) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node in get_all_nodes():
		if can_visit(narrative, str(node.get("id", ""))):
			result.append(node)
	return result

func get_rumors_at_current_location(narrative: NarrativeManager) -> Array[Dictionary]:
	if narrative == null:
		return []
	var location := get_current_location(narrative)
	var heard:Array = narrative.state.get_world_state().get("heard_rumors", [])
	var result: Array[Dictionary] = []
	for rumor in rumors.values():
		if str(rumor.get("node_id", "")) != location:
			continue
		if narrative.state.current_global_timeline < int(rumor.get("required_timeline", 0)):
			continue
		if str(rumor.get("id", "")) in heard:
			continue
		result.append(rumor.duplicate(true))
	return result

func hear_rumor(narrative: NarrativeManager, rumor_id: String) -> Dictionary:
	if narrative == null or not rumors.has(rumor_id):
		return {}
	var rumor: Dictionary = rumors[rumor_id]
	if str(rumor.get("node_id", "")) != get_current_location(narrative):
		return {}
	var required := int(rumor.get("required_timeline", 0))
	if narrative.state.current_global_timeline < required:
		return {}
	narrative.state.add_world_rumor(rumor_id, str(rumor.get("bounty_id", "")))
	return rumor.duplicate(true)

func get_discovered_bounty_ids(narrative: NarrativeManager) -> Array[String]:
	if narrative == null:
		return []
	var result: Array[String] = []
	for bounty_id in narrative.state.get_world_state().get("discovered_bounties", []):
		result.append(str(bounty_id))
	return result

func save(narrative: NarrativeManager) -> bool:
	return narrative != null and narrative.save()

func _first_available_node(narrative: NarrativeManager) -> String:
	for node in get_all_nodes():
		if can_visit(narrative, str(node.get("id", ""))):
			return str(node.get("id", ""))
	return ""

func _load_json(path: String, key: String, target: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("WorldMapManager failed to open %s" % path)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("WorldMapManager invalid JSON: %s" % path)
		return
	for entry in parsed.get(key, []):
		if entry is Dictionary:
			var id := str(entry.get("id", ""))
			if id != "":
				target[id] = entry.duplicate(true)
