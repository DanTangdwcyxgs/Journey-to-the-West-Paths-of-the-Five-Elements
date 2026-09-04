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

	var fallback := Combatant.new("fallback", "无技能妖", 100, 12, 4, 8, 2, {})
	var fallback_action := manager.choose_ai_action(fallback, [], 4)
	assert(fallback_action.id == "NORMAL_ATTACK")
	assert(fallback_action.power == 18)

	print("ALL ENEMY AI TESTS PASSED")
