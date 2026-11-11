class_name RegionContentValidator
extends RefCounted

## Validates authored region data before new exploration content is accepted.
## This is a tooling/CI contract; it does not mutate NarrativeState or runtime catalogs.

static func validate_payload(region_payload: Variant, world_map_payload: Variant) -> Array[String]:
	var errors: Array[String] = []
	if not region_payload is Dictionary:
		errors.append("Region catalog root must be an object.")
		return errors
	var region_entries: Variant = region_payload.get("regions", null)
	if not region_entries is Array:
		errors.append("Region catalog must define a regions array.")
		return errors
	if not world_map_payload is Dictionary:
		errors.append("World map root must be an object.")
		return errors
	var map_entries: Variant = world_map_payload.get("nodes", null)
	if not map_entries is Array:
		errors.append("World map must define a nodes array.")
		return errors

	var map_ids: Dictionary = {}
	for index in range(map_entries.size()):
		var node: Variant = map_entries[index]
		if not node is Dictionary:
			errors.append("World map node at index %d must be an object." % index)
			continue
		var node_data: Dictionary = node
		var node_id := _string_field(node_data, "id")
		if node_id.is_empty():
			errors.append("World map node at index %d must have a non-empty string id." % index)
			continue
		if map_ids.has(node_id):
			errors.append("Duplicate world map node id: %s." % node_id)
		map_ids[node_id] = true

	var region_ids: Dictionary = {}
	var location_ids: Dictionary = {}
	var point_ids: Dictionary = {}
	for index in range(region_entries.size()):
		var region: Variant = region_entries[index]
		if not region is Dictionary:
			errors.append("Region entry at index %d must be an object." % index)
			continue
		var region_data: Dictionary = region

		var region_id := _string_field(region_data, "id")
		if region_id.is_empty():
			errors.append("Region entry at index %d must have a non-empty string id." % index)
		elif region_ids.has(region_id):
			errors.append("Duplicate region id: %s." % region_id)
		else:
			region_ids[region_id] = true

		var location_id := _string_field(region_data, "location_id")
		if location_id.is_empty():
			errors.append("Region %s must have a non-empty string location_id." % _display_id(region_id, index))
		else:
			if not map_ids.has(location_id):
				errors.append("Region %s references unknown world map location %s." % [_display_id(region_id, index), location_id])
			if location_ids.has(location_id):
				errors.append("Multiple regions reference world map location %s." % location_id)
			else:
				location_ids[location_id] = region_id

		_require_text(region_data, "name", "Region %s" % _display_id(region_id, index), errors)
		_require_text(region_data, "description", "Region %s" % _display_id(region_id, index), errors)

		var timeline: Variant = region_data.get("required_timeline", null)
		var valid_timeline := false
		if typeof(timeline) == TYPE_INT:
			valid_timeline = int(timeline) >= 0
		elif typeof(timeline) == TYPE_FLOAT:
			var timeline_value := float(timeline)
			valid_timeline = timeline_value >= 0.0 and timeline_value == floor(timeline_value)
		if not valid_timeline:
			errors.append("Region %s must have a non-negative integer required_timeline." % _display_id(region_id, index))

		var milestones: Variant = region_data.get("required_milestones", null)
		if not milestones is Array:
			errors.append("Region %s must define required_milestones as an array." % _display_id(region_id, index))
		else:
			var region_milestones: Dictionary = {}
			for milestone in milestones:
				if typeof(milestone) != TYPE_STRING or str(milestone).strip_edges().is_empty():
					errors.append("Region %s has an empty or non-string milestone id." % _display_id(region_id, index))
					continue
				var milestone_id := str(milestone).strip_edges()
				if region_milestones.has(milestone_id):
					errors.append("Region %s repeats milestone %s." % [_display_id(region_id, index), milestone_id])
				region_milestones[milestone_id] = true

		var points: Variant = region_data.get("points", null)
		if not points is Array:
			errors.append("Region %s must define points as an array." % _display_id(region_id, index))
			continue
		if points.is_empty():
			errors.append("Region %s must define at least one point of interest." % _display_id(region_id, index))
		for point_index in range(points.size()):
			var point: Variant = points[point_index]
			if not point is Dictionary:
				errors.append("Region %s point at index %d must be an object." % [_display_id(region_id, index), point_index])
				continue
			var point_data: Dictionary = point
			var point_id := _string_field(point_data, "id")
			if point_id.is_empty():
				errors.append("Region %s point at index %d must have a non-empty string id." % [_display_id(region_id, index), point_index])
			elif point_ids.has(point_id):
				errors.append("Duplicate region point id: %s." % point_id)
			else:
				point_ids[point_id] = _display_id(region_id, index)
			var point_label := "Region %s point %s" % [_display_id(region_id, index), _display_id(point_id, point_index)]
			_require_text(point_data, "name", point_label, errors)
			_require_text(point_data, "description", point_label, errors)
			_require_text(point_data, "result_text", point_label, errors)

	return errors


static func _string_field(record: Dictionary, key: String) -> String:
	var value: Variant = record.get(key, null)
	if typeof(value) != TYPE_STRING:
		return ""
	return str(value).strip_edges()


static func _require_text(record: Dictionary, key: String, label: String, errors: Array[String]) -> void:
	if _string_field(record, key).is_empty():
		errors.append("%s must have non-empty string %s." % [label, key])


static func _display_id(value: String, index: int) -> String:
	return value if not value.is_empty() else "entry at index %d" % index
