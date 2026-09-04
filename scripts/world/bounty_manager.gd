class_name BountyManager
extends RefCounted

## Runtime manager for optional "悬赏妖王" encounters.
## Bounties are world objectives: discover -> prepare -> challenge/retreat -> resolve.

const STATUS_UNKNOWN := "UNKNOWN"
const STATUS_DISCOVERED := "DISCOVERED"
const STATUS_DEFEATED := "DEFEATED"

var definitions: Dictionary = {}
var statuses: Dictionary = {}
var intelligence: Dictionary = {}

func load_definitions(payload: Dictionary) -> void:
	definitions.clear()
	statuses.clear()
	intelligence.clear()
	for bounty in payload.get("bounties", []):
		if bounty is Dictionary and bounty.has("id"):
			var id := str(bounty["id"])
			definitions[id] = bounty
			statuses[id] = STATUS_UNKNOWN
			intelligence[id] = []

func has_bounty(bounty_id: String) -> bool:
	return definitions.has(bounty_id)

func get_definition(bounty_id: String) -> Dictionary:
	return definitions.get(bounty_id, {}).duplicate(true)

func discover(bounty_id: String, evidence_tag: String = "") -> bool:
	if not definitions.has(bounty_id):
		return false
	if statuses.get(bounty_id, STATUS_UNKNOWN) == STATUS_DEFEATED:
		return false
	statuses[bounty_id] = STATUS_DISCOVERED
	_add_intelligence(bounty_id, evidence_tag)
	return true

func mark_retreat(bounty_id: String) -> bool:
	if not definitions.has(bounty_id):
		return false
	if statuses.get(bounty_id, STATUS_UNKNOWN) == STATUS_DEFEATED:
		return false
	var memory := str(definitions[bounty_id].get("retreat_memory", ""))
	_add_intelligence(bounty_id, memory)
	if statuses[bounty_id] == STATUS_UNKNOWN:
		statuses[bounty_id] = STATUS_DISCOVERED
	return true

func defeat(bounty_id: String) -> Dictionary:
	if not definitions.has(bounty_id):
		return {}
	if statuses.get(bounty_id, STATUS_UNKNOWN) == STATUS_DEFEATED:
		return {}
	statuses[bounty_id] = STATUS_DEFEATED
	var definition: Dictionary = definitions[bounty_id]
	return {
		"bounty_id": bounty_id,
		"rewards": definition.get("rewards", []),
		"world_effects": definition.get("world_effects_on_defeat", []),
		"memory_hooks": definition.get("memory_hooks", []),
	}

func get_status(bounty_id: String) -> String:
	return str(statuses.get(bounty_id, STATUS_UNKNOWN))

func get_intelligence(bounty_id: String) -> Array[String]:
	return intelligence.get(bounty_id, []).duplicate()

func to_dict() -> Dictionary:
	return {
		"statuses": statuses.duplicate(true),
		"intelligence": intelligence.duplicate(true),
	}

func restore(data: Dictionary) -> void:
	var saved_statuses = data.get("statuses", {})
	var saved_intelligence = data.get("intelligence", {})
	for id in definitions.keys():
		statuses[id] = str(saved_statuses.get(id, STATUS_UNKNOWN))
		var raw_intel = saved_intelligence.get(id, [])
		intelligence[id] = []
		if raw_intel is Array:
			for entry in raw_intel:
				intelligence[id].append(str(entry))

func _add_intelligence(bounty_id: String, value: String) -> void:
	if value == "":
		return
	if not intelligence.has(bounty_id):
		intelligence[bounty_id] = []
	if value not in intelligence[bounty_id]:
		intelligence[bounty_id].append(value)
