extends RefCounted

## Regression checks for the generic transient battle handoff.

static func run() -> void:
	assert(BountyEncounterState.start_encounter("normal", "YELLOW_WIND_CAVE_SAND_GUARDS", "SANDSTORM_HALL"))
	var record := BountyEncounterState.get_active_record()
	assert(record.get("encounter_type", "") == "normal")
	assert(record.get("encounter_id", "") == "YELLOW_WIND_CAVE_SAND_GUARDS")
	assert(record.get("bounty_id", "") == "")
	assert(record.get("source_stage_id", "") == "SANDSTORM_HALL")
	BountyEncounterState.clear()
	assert(BountyEncounterState.get_active_record().is_empty())
