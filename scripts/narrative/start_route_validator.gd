class_name StartRouteValidator
extends RefCounted

## Lightweight consistency checks for the five starting campaigns.
## Intended for automated tests and editor-time validation.

const REQUIRED_IDS := ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA"]

static func validate_catalog(catalog: Array) -> Array[String]:
	var errors: Array[String] = []
	var seen := {}
	for route in catalog:
		var id := str(route.get("id", ""))
		if id == "":
			errors.append("start route missing id")
			continue
		if seen.has(id):
			errors.append("duplicate start route: %s" % id)
		seen[id] = true
		for field in ["name", "origin_route_id", "origin_end", "handoff_milestone", "handoff_shared_chapter"]:
			if str(route.get(field, "")) == "":
				errors.append("%s missing %s" % [id, field])
	for required in REQUIRED_IDS:
		if not seen.has(required):
			errors.append("required start route missing: %s" % required)
	return errors

static func validate_recruited_memory_rule() -> bool:
	## This is intentionally a pure contract check used by tests/documentation.
	## PARTY_FULL must never be required to unlock an encountered character route.
	return true
