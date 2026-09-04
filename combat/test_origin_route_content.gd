extends RefCounted

static func run() -> void:
	var chapters_file := FileAccess.open("res://data/narrative/origin_chapters.json", FileAccess.READ)
	var encounters_file := FileAccess.open("res://data/combat/encounters.json", FileAccess.READ)
	var events_file := FileAccess.open("res://data/narrative/origin_events.json", FileAccess.READ)
	assert(chapters_file != null)
	assert(encounters_file != null)
	assert(events_file != null)

	var chapters_data = JSON.parse_string(chapters_file.get_as_text())
	var encounters_data = JSON.parse_string(encounters_file.get_as_text())
	var events_data = JSON.parse_string(events_file.get_as_text())
	assert(chapters_data is Dictionary)
	assert(encounters_data is Dictionary)
	assert(events_data is Dictionary)

	var encounter_ids := {}
	for encounter in encounters_data.get("encounters", []):
		encounter_ids[str(encounter.get("id", ""))] = true
	for route_id in ["WUKONG", "TANG", "LONGMA", "BAJIE", "WUJING"]:
		var route: Dictionary = chapters_data.get("routes", {}).get(route_id, {})
		assert(not route.is_empty())
		for chapter in route.get("chapters", []):
			var encounter_id := str(chapter.get("encounter_id", ""))
			if encounter_id != "":
				assert(encounter_ids.has(encounter_id))

	for chapter_id in ["TANG-04", "TANG-07", "LONGMA-02", "LONGMA-04", "BAJIE-02", "BAJIE-06", "WUJING-02", "WUJING-06"]:
		var event: Dictionary = events_data.get("events", {}).get(chapter_id, {})
		assert(not event.is_empty())
		assert(event.get("choices", []).size() >= 2)
		for choice in event.get("choices", []):
			assert(choice.get("effects", {}).has("combat_modifiers"))
