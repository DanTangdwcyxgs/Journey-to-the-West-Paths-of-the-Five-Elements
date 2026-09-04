extends RefCounted

## Regression checks for normal encounter data loading and enemy construction.
static func run() -> void:
	var manager := EncounterManager.new()
	var definition := manager.get_definition("YELLOW_WIND_CAVE_SAND_GUARDS")
	assert(not definition.is_empty())
	assert(definition.get("recommended_level", 0) == 10)
	var enemies := manager.build_enemies("YELLOW_WIND_CAVE_SAND_GUARDS")
	assert(enemies.size() == 2)
	assert(enemies[0].id == "sand_guard")
	assert(enemies[0].weaknesses.get("fire", false))
	assert(enemies[1].id == "wind_spirit")
	assert(enemies[1].weaknesses.get("water", false))
	assert(not enemies[0].combat_modifiers.get("skills", []).is_empty())
