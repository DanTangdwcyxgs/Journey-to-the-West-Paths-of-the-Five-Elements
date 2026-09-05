class_name EventSequenceDefinition
extends RefCounted

## Normalized executable event-sequence contract.
## A sequence is an ordered graph of typed nodes. Presentation owns rendering;
## EventRunner owns execution state and returns action requests.

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
	var node_ids := get_node_ids()
	if node_ids.is_empty():
		errors.append("sequence has no nodes")
	var seen := {}
	for node_id in node_ids:
		if seen.has(node_id):
			errors.append("duplicate node id: %s" % node_id)
		seen[node_id] = true
	var start_id := get_start_node_id()
	if start_id.is_empty() or not seen.has(start_id):
		errors.append("invalid start node: %s" % start_id)
	return {
		"valid": errors.is_empty(),
		"errors": errors,
	}

func to_dict() -> Dictionary:
	return raw.duplicate(true)
