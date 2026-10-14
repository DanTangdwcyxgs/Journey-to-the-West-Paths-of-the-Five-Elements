extends RefCounted

## Content contract tests for the data-driven region catalog.

static func run_all() -> Dictionary:
	var failures: Array[String] = []
	var region_payload: Variant = _read_json("res://data/world/regions.json")
	var map_payload: Variant = _read_json("res://data/world/world_map.json")
	_expect(region_payload is Dictionary, "production region catalog should parse as a JSON object", failures)
	_expect(map_payload is Dictionary, "production world map should parse as a JSON object", failures)
	if not region_payload is Dictionary or not map_payload is Dictionary:
		return {"passed": false, "message": " | ".join(failures)}

	var production_errors := RegionContentValidator.validate_payload(region_payload, map_payload)
	_expect(production_errors.is_empty(), "production region catalog should satisfy the content contract: %s" % " | ".join(production_errors), failures)

	var valid_regions := _valid_region_payload()
	var valid_map := _valid_map_payload()
	_expect(RegionContentValidator.validate_payload(valid_regions, valid_map).is_empty(), "a minimal valid region catalog should pass", failures)

	var unknown_location := _valid_region_payload()
	unknown_location["regions"][0]["location_id"] = "MISSING_MAP_NODE"
	var unknown_location_errors := RegionContentValidator.validate_payload(unknown_location, valid_map)
	_expect(_has_error(unknown_location_errors, "unknown world map location"), "unknown map locations should be rejected", failures)

	var duplicate_location := _valid_region_payload()
	duplicate_location["regions"].append(_make_region("SECOND_REGION", "TEST_NODE", "SECOND_POINT"))
	var duplicate_location_errors := RegionContentValidator.validate_payload(duplicate_location, valid_map)
	_expect(_has_error(duplicate_location_errors, "Multiple regions reference world map location"), "ambiguous one-location-to-region mappings should be rejected", failures)

	var two_node_map := _valid_map_payload()
	two_node_map["nodes"].append({"id": "SECOND_NODE"})
	var duplicate_point_regions := _valid_region_payload()
	duplicate_point_regions["regions"].append(_make_region("SECOND_REGION", "SECOND_NODE", "TEST_POINT"))
	var duplicate_point_errors := RegionContentValidator.validate_payload(duplicate_point_regions, two_node_map)
	_expect(_has_error(duplicate_point_errors, "Duplicate region point id"), "discovery point IDs must be globally unique across regions because they are persisted without region scope", failures)

	var missing_feedback := _valid_region_payload()
	missing_feedback["regions"][0]["points"][0].erase("result_text")
	var missing_feedback_errors := RegionContentValidator.validate_payload(missing_feedback, valid_map)
	_expect(_has_error(missing_feedback_errors, "result_text"), "points without player-facing discovery feedback should be rejected", failures)

	var bad_timeline := _valid_region_payload()
	bad_timeline["regions"][0]["required_timeline"] = -1
	var bad_timeline_errors := RegionContentValidator.validate_payload(bad_timeline, valid_map)
	_expect(_has_error(bad_timeline_errors, "non-negative integer required_timeline"), "negative timeline gates should be rejected", failures)

	var empty_points := _valid_region_payload()
	empty_points["regions"][0]["points"] = []
	var empty_points_errors := RegionContentValidator.validate_payload(empty_points, valid_map)
	_expect(_has_error(empty_points_errors, "at least one point of interest"), "regions without points of interest should be rejected", failures)

	return {"passed": failures.is_empty(), "message": " | ".join(failures)}


static func _valid_region_payload() -> Dictionary:
	return {
		"regions": [
			_make_region("TEST_REGION", "TEST_NODE", "TEST_POINT")
		]
	}


static func _valid_map_payload() -> Dictionary:
	return {
		"nodes": [
			{"id": "TEST_NODE"}
		]
	}


static func _make_region(region_id: String, location_id: String, point_id: String) -> Dictionary:
	return {
		"id": region_id,
		"location_id": location_id,
		"name": "Test region",
		"description": "A test region.",
		"required_timeline": 0,
		"required_milestones": [],
		"points": [
			{
				"id": point_id,
				"name": "Test clue",
				"description": "A clue to inspect.",
				"result_text": "The clue was recorded."
			}
		]
	}


static func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed


static func _has_error(errors: Array[String], needle: String) -> bool:
	for error_text in errors:
		if error_text.contains(needle):
			return true
	return false


static func _expect(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
