class_name RegionExplorationManager
extends RefCounted

## Data-driven, optional points of interest inside a visited WorldMap location.
## Discoveries are narrative world facts; this manager does not save or advance the story.

const REGION_PATH := "res://data/world/regions.json"

var regions: Dictionary = {}

func _init() -> void:
	_load_json()

func get_region(region_id: String) -> Dictionary:
	return regions.get(region_id, {}).duplicate(true)

func get_region_for_location(location_id: String) -> Dictionary:
	if location_id == "":
		return {}
	for value in regions.values():
		var region: Dictionary = value
		if str(region.get("location_id", "")) == location_id:
			return region.duplicate(true)
	return {}

func can_enter(narrative: NarrativeManager, region_id: String) -> bool:
	if narrative == null or not regions.has(region_id):
		return false
	var region: Dictionary = regions[region_id]
	if str(narrative.state.get_world_state().get("current_location", "")) != str(region.get("location_id", "")):
		return false
	if narrative.state.current_global_timeline < int(region.get("required_timeline", 0)):
		return false
	for milestone in region.get("required_milestones", []):
		if str(milestone) not in narrative.state.completed_milestones:
			return false
	return true

func get_points(region_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var region := get_region(region_id)
	for value in region.get("points", []):
		if value is Dictionary:
			result.append(value.duplicate(true))
	return result

func get_point(region_id: String, point_id: String) -> Dictionary:
	for point in get_points(region_id):
		if str(point.get("id", "")) == point_id:
			return point
	return {}

func get_discovered_point_ids(narrative: NarrativeManager) -> Array[String]:
	var result: Array[String] = []
	if narrative == null:
		return result
	for point_id in narrative.state.get_world_state().get("discovered_region_points", []):
		result.append(str(point_id))
	return result

func is_discovered(narrative: NarrativeManager, point_id: String) -> bool:
	return point_id in get_discovered_point_ids(narrative)

func discover_point(narrative: NarrativeManager, region_id: String, point_id: String) -> Dictionary:
	if not can_enter(narrative, region_id):
		return {}
	var point := get_point(region_id, point_id)
	if point.is_empty():
		return {}
	if is_discovered(narrative, point_id):
		return {}
	if not narrative.state.record_region_point_discovered(point_id):
		return {}
	return point

func _load_json() -> void:
	var file := FileAccess.open(REGION_PATH, FileAccess.READ)
	if file == null:
		push_error("RegionExplorationManager failed to open %s" % REGION_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("RegionExplorationManager invalid JSON: %s" % REGION_PATH)
		return
	for entry in parsed.get("regions", []):
		if not entry is Dictionary:
			continue
		var id := str(entry.get("id", ""))
		var location_id := str(entry.get("location_id", ""))
		if id == "" or location_id == "" or regions.has(id):
			push_error("RegionExplorationManager invalid or duplicate region id: %s" % id)
			continue
		regions[id] = entry.duplicate(true)
