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
	return get_entry_block_reason(narrative, region_id).is_empty()


## Returns a player-facing reason when a region is locked, or an empty string when available.
## Keep this as the single source of truth for both the gate and its presentation.
func get_entry_block_reason(narrative: NarrativeManager, region_id: String) -> String:
	if narrative == null or not regions.has(region_id):
		return "当前没有可进入的区域探索。"
	var region: Dictionary = regions[region_id]
	var current_location := str(narrative.state.get_world_state().get("current_location", ""))
	if current_location != str(region.get("location_id", "")):
		return "请先前往%s，再进入区域探索。" % str(region.get("name", region_id))
	var required_timeline := int(region.get("required_timeline", 0))
	if narrative.state.current_global_timeline < required_timeline:
		return "区域尚未开放：需要旅途推进至 T%03d（当前 T%03d）。" % [
			required_timeline,
			narrative.state.current_global_timeline
		]
	for milestone in region.get("required_milestones", []):
		var milestone_id := str(milestone)
		if milestone_id not in narrative.state.completed_milestones:
			return "区域尚未开放：%s。" % _milestone_requirement_label(milestone_id)
	return ""


func _milestone_requirement_label(milestone_id: String) -> String:
	var labels := {
		"WUKONG_RECRUITED": "需要先让孙悟空加入取经队伍",
		"BAI_LONGMA_RECRUITED": "需要先让白龙马加入取经队伍",
		"ZHU_BAJIE_RECRUITED": "需要先让猪八戒加入取经队伍",
		"SHA_WUJING_RECRUITED": "需要先让沙悟净加入取经队伍",
		"PARTY_FULL": "需要先集结完整的五人队伍"
	}
	return str(labels.get(milestone_id, "需要先完成必要的旅途事件"))

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

## Returns a read-only journal projection of discovered clues across every region.
## Undiscovered points are deliberately omitted so the journal does not reveal hidden content.
func get_discovered_notes(narrative: NarrativeManager) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if narrative == null:
		return result
	var discovered_ids := get_discovered_point_ids(narrative)
	if discovered_ids.is_empty():
		return result
	for region_value in regions.values():
		if not region_value is Dictionary:
			continue
		var region: Dictionary = region_value
		var region_id := str(region.get("id", ""))
		for point in get_points(region_id):
			var point_id := str(point.get("id", ""))
			if point_id == "" or point_id not in discovered_ids:
				continue
			var note := point.duplicate(true)
			note["region_id"] = region_id
			note["region_name"] = str(region.get("name", region_id))
			result.append(note)
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
