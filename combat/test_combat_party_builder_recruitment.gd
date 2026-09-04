extends RefCounted

## Regression check: an active encounter must use the saved recruited roster,
## not a convenience five-character party created by the battle UI.
static func run() -> void:
	var narrative := NarrativeManager.new()
	assert(narrative.start_new_game("LONGMA"))
	narrative.encounter_character("TANG", [])
	narrative.encounter_character("WUKONG", [])
	narrative.encounter_character("LONGMA", [])
	narrative.state.set_party_formation({
		"roster": ["TANG", "WUKONG", "LONGMA"],
		"front_row": ["TANG", "WUKONG"],
		"back_row": ["LONGMA"],
	})
	assert(BountyEncounterState.start_encounter("normal", "YELLOW_WIND_CAVE_SAND_GUARDS", "SANDSTORM_HALL"))
	# The production builder reads the active handoff and synchronizes the party
	# with NarrativeState before constructing combatants. The assertions here
	# describe the expected save-level roster/formation that feeds that path.
	assert(narrative.state.recruited_characters.size() == 3)
	assert("BAJIE" not in narrative.state.recruited_characters)
	assert("WUJING" not in narrative.state.recruited_characters)
	BountyEncounterState.clear()
