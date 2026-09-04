extends RefCounted

## Regression coverage for data-driven encounter enemy AI selection.
static func run() -> void:
	var manager := EncounterManager.new()
	var enemies := manager.build_enemies("TANG_ORIGIN_FIVE_ELEMENTS")
	assert(enemies.size() == 2)

	var spirit: Combatant = enemies[0]
	var action1 := manager.choose_ai_action(spirit, [], 1)
	assert(action1.id == "SPIRIT_HOLY")

	var action3 := manager.choose_ai_action(spirit, [], 3)
	assert(action3.id == "SPIRIT_ROCK")

	spirit.hp = int(spirit.max_hp * 0.3)
	var low_hp_action := manager.choose_ai_action(spirit, [], 1)
	assert(low_hp_action.id == "SPIRIT_ROCK")

	var fire_weak := Combatant.new("fire_weak", "怕火妖怪", 100, 10, 5, 8, 2, {"fire": true})
	var water_weak := Combatant.new("water_weak", "怕水妖怪", 100, 10, 5, 8, 2, {"water": true})
	var fire_action := CombatAction.new("TEST_FIRE", "火术", "fire", 20, 1, 0)
	assert(manager.choose_ai_target(spirit, [water_weak, fire_weak], fire_action) == fire_weak)

	var neutral_action := CombatAction.new("TEST_EARTH", "土击", "earth", 20, 1, 0)
	assert(manager.choose_ai_target(spirit, [water_weak, fire_weak], neutral_action) == water_weak)

	var fallback := Combatant.new("fallback", "无技能妖", 100, 12, 4, 8, 2, {})
	var fallback_action := manager.choose_ai_action(fallback, [], 4)
	assert(fallback_action.id == "NORMAL_ATTACK")
	assert(fallback_action.power == 18)

	print("ALL ENEMY AI TESTS PASSED")
