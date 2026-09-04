extends RefCounted

## Regression checks for encounter data loading, construction, and target selection.
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

	var party:Array[Combatant] = [
		Combatant.new("tank", "前排", 120, 20, 10, 7, 2, {}),
		Combatant.new("mage", "法师", 70, 30, 4, 12, 1, {"fire": true}),
		Combatant.new("rogue", "残血", 40, 28, 5, 15, 1, {})
	]
	var fire_action := CombatAction.new("TEST_FIRE", "火", "fire", 25, 1, 0)
	var weak_target := manager.choose_ai_target(enemies[0], party, fire_action)
	assert(weak_target == party[1])

	party[1].aggro_turns = 2
	var taunt_target := manager.choose_ai_target(enemies[0], party, fire_action)
	assert(taunt_target == party[1])
	party[1].aggro_turns = 0
	party[1].hp = 60
	var low_hp_target := manager.choose_ai_target(enemies[0], party, CombatAction.new("TEST_STRIKE", "普通", "strike", 15, 1, 0))
	assert(low_hp_target == party[2])
	
	print("ALL ENCOUNTER MANAGER TESTS PASSED")
