extends RefCounted

## Regression check for the shared exploration -> battle handoff used by origin routes.
static func run() -> void:
	BountyEncounterState.clear()
	assert(BountyEncounterState.start_narrative_encounter("WUKONG_ORIGIN_WATER_CAVE", "WUK-02", "WUKONG_ORIGIN"))
	var record := BountyEncounterState.get_active_record()
	assert(record.get("encounter_type", "") == "origin")
	assert(record.get("encounter_id", "") == "WUKONG_ORIGIN_WATER_CAVE")
	assert(record.get("source_chapter_id", "") == "WUK-02")
	assert(record.get("source_route_id", "") == "WUKONG_ORIGIN")
	BountyEncounterState.clear()
	assert(BountyEncounterState.get_active_record().is_empty())
