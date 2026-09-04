extends RefCounted

## Content integrity checks for authored origin-route combat references.
static func run() -> void:
	var chapters_file := FileAccess.open("res://data/narrative/origin_chapters.json", FileAccess.READ)
	var encounters_file := FileAccess.open("res://data/combat/encounters.json", FileAccess.READ)
	assert(chapters_file != null)
	assert(encounters_file != null)
	var chapters = JSON.parse_string(chapters_file.get_as_text())
	var encounters = JSON.parse_string(encounters_file.get_as_text())
	assert(chapters is Dictionary)
	assert(encounters is Dictionary)
	var encounter_ids := {}
	for encounter in encounters.get("encounters", []):
		assert(encounter is Dictionary)
		var encounter_id := str(encounter.get("id", ""))
		assert(encounter_id != "")
		encounter_ids[encounter_id] = true
	for route in chapters.get("routes", {}).values():
		assert(route is Dictionary)
		for chapter in route.get("chapters", []):
			assert(chapter is Dictionary)
			var encounter_id := str(chapter.get("encounter_id", ""))
			if encounter_id != "":
				assert(encounter_ids.has(encounter_id))
