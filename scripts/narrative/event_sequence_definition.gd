class_name EventSequenceDefinition
extends RefCounted

## Normalized executable event-sequence contract.
## A sequence is an ordered graph of typed nodes. Presentation owns rendering;
## EventRunner owns execution state and returns action requests.

const SUPPORTED_TYPES := ["dialogue", "choice", "wait", "move", "battle", "reward", "jump", "end"]

var raw: Dictionary = {}

func _init(data: Dictionary = {}) -> void:
	raw = data.duplicate(true)

func get_id() -> String:
	return str(raw.get("id", raw.get("sequence_id", "")))

func get_start_node_id() -> String:
	var explicit_start := str(raw.get("start", raw.get("start_node", "")))
	if not explicit_start.is_empty():
		return explicit_start
	var nodes := get_nodes()
	if nodes.is_empty():
		return ""
	return str(nodes[0].get("id", ""))

func get_nodes() -> Array:
	return raw.get("nodes", []).duplicate(true)

func get_node(node_id: String) -> Dictionary:
	for node in get_nodes():
		if node is Dictionary and str(node.get("id", "")) == node_id:
			return node.duplicate(true)
	return {}

func has_node(node_id: String) -> bool:
	return not get_node(node_id).is_empty()

func get_node_ids() -> Array[String]:
	var result: Array[String] = []
	for node in get_nodes():
		if node is Dictionary:
			var node_id := str(node.get("id", ""))
			if not node_id.is_empty():
				result.append(node_id)
	return result

func get_version() -> int:
	return int(raw.get("schema_version", 1))

func is_empty() -> bool:
	return get_id().is_empty() or get_nodes().is_empty()

func validate() -> Dictionary:
	var errors: Array[String] = []
	if get_id().is_empty():
		errors.append("missing sequence id")
	var nodes := get_nodes()
	var node_ids := get_node_ids()
	if nodes.is_empty():
		errors.append("sequence has no nodes")
	var seen := {}
	for node in nodes:
		if not node is Dictionary:
			errors.append("node is not an object")
			continue
		var node_id := str(node.get("id", ""))
		if node_id.is_empty():
			errors.append("node missing id")
			continue
		if seen.has(node_id):
			errors.append("duplicate node id: %s" % node_id)
		seen[node_id] = true
		var kind := str(node.get("type", node.get("kind", ""))).to_lower()
		if kind not in SUPPORTED_TYPES:
			errors.append("unsupported node type %s: %s" % [kind, node_id])
			continue
		for target in _get_targets(node, kind):
			if target != "" and target not in node_ids:
				errors.append("missing target %s from node %s" % [target, node_id])
	var start_id := get_start_node_id()
	if start_id.is_empty() or not seen.has(start_id):
		errors.append("invalid start node: %s" % start_id)
	return {
		"valid": errors.is_empty(),
		"errors": errors,
	}

func to_dict() -> Dictionary:
	return raw.duplicate(true)

func _get_targets(node: Dictionary, kind: String) -> Array[String]:
	var targets: Array[String] = []
	var next_id := str(node.get("next", ""))
	if kind != "end" and not next_id.is_empty():
		targets.append(next_id)
	if kind == "jump":
		var target := str(node.get("target", next_id))
		if target != "":
			targets.append(target)
	if kind == "choice":
		var next_map: Dictionary = node.get("next_map", {})
		for key in next_map.keys():
			var target_id := str(next_map[key])
			if target_id != "":
				targets.append(target_id)
	return targets
