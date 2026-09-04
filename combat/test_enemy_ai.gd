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

	var taunt_target := Combatant.new("taunt", "嘲讽前排", 100, 10, 5, 8, 2, {})
	taunt_target.aggro_turns = 2
	var attacker := Combatant.new("attacker", "战术妖", 100, 20, 5, 8, 2, {})
	attacker.combat_modifiers["target_profile"] = "highest_attack"
	assert(manager.choose_ai_target(attacker, [water_weak, taunt_target], neutral_action) == taunt_target)
	taunt_target.aggro_turns = 0
	assert(manager.choose_ai_target(attacker, [water_weak, fire_weak], neutral_action) == fire_weak)

	var low_defender := Combatant.new("low_def", "薄甲目标", 100, 12, 2, 8, 2, {})
	var high_defender := Combatant.new("high_def", "厚甲目标", 100, 12, 12, 8, 2, {})
	attacker.combat_modifiers["target_profile"] = "lowest_defense"
	assert(manager.choose_ai_target(attacker, [high_defender, low_defender], neutral_action) == low_defender)

	var high_attack := Combatant.new("high_attack", "强攻目标", 100, 25, 6, 8, 2, {})
	var low_attack := Combatant.new("low_attack", "弱攻目标", 100, 10, 6, 8, 2, {})
	attacker.combat_modifiers["target_profile"] = "highest_attack"
	assert(manager.choose_ai_target(attacker, [low_attack, high_attack], neutral_action) == high_attack)

	var low_hp := Combatant.new("low_hp", "残血目标", 100, 12, 6, 8, 2, {})
	var full_hp := Combatant.new("full_hp", "满血目标", 100, 12, 6, 8, 2, {})
	low_hp.hp = 20
	attacker.combat_modifiers["target_profile"] = "lowest_hp"
	assert(manager.choose_ai_target(attacker, [full_hp, low_hp], neutral_action) == low_hp)

	var fallback := Combatant.new("fallback", "无技能妖", 100, 12, 4, 8, 2, {})
	var fallback_action := manager.choose_ai_action(fallback, [], 4)
	assert(fallback_action.id == "NORMAL_ATTACK")
	assert(fallback_action.power == 18)

	print("ALL ENEMY AI TESTS PASSED")
