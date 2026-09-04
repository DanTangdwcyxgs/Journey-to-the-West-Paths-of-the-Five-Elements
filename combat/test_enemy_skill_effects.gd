extends RefCounted

## Regression coverage for data-driven enemy skill effects and conditions.
static func run() -> void:
	var manager := EncounterManager.new()
	var enemies := manager.build_enemies("YELLOW_WIND_CAVE_SAND_GUARDS")
	assert(enemies.size() == 2)

	var guard: Combatant = enemies[0]
	var sand_effect_action := manager.choose_ai_action(guard, [], 3)
	assert(sand_effect_action.id == "SAND_GUARD_WIND")
	assert(sand_effect_action.effects.get("effect", "") == "slow")
	assert(sand_effect_action.effects.get("condition", "") == "on_hit")
	assert(int(sand_effect_action.effects.get("effect_value", 0)) == -3)
	assert(int(sand_effect_action.effects.get("effect_duration", 0)) == 2)

	var ally := Combatant.new("target", "受击角色", 200, 20, 5, 14, 2, {})
	var actor := Combatant.new("enemy", "测试妖兵", 200, 24, 6, 10, 2, {})
	var engine := CombatEngine.new()
	engine.setup([ally], [actor])
	actor.bp = 1

	var slow_action := CombatAction.new("TEST_SLOW", "寒风", "ice", 1, 0, 0, {"effect":"slow","effect_value":-4,"effect_duration":2,"condition":"on_hit"})
	var before_speed := ally.speed
	var result := engine.perform_action(actor, ally, slow_action)
	assert(result.get("ok", false))
	assert(result.get("effect_applied", false))
	assert(ally.speed == before_speed - 4)
	assert(ally.speed_effect_turns == 2)

	var weaker_slow := CombatAction.new("TEST_SLOW_WEAK", "微寒", "ice", 1, 0, 0, {"effect":"slow","effect_value":-2,"effect_duration":4,"condition":"on_hit"})
	result = engine.perform_action(actor, ally, weaker_slow)
	assert(result.get("ok", false))
	assert(ally.speed == before_speed - 4)
	assert(ally.speed_effect_turns == 4)

	ally.aggro_turns = 0
	var taunt_action := CombatAction.new("TEST_TAUNT", "挑衅", "strike", 1, 0, 0, {"effect":"taunt","effect_value":1,"effect_duration":2,"condition":"on_hit"})
	result = engine.perform_action(actor, ally, taunt_action)
	assert(result.get("ok", false))
	assert(ally.aggro_turns == 2)

	var shield_actor := Combatant.new("stone_imp", "顽石小妖", 100, 14, 6, 6, 3, {})
	var shield_target := Combatant.new("ally", "玩家", 100, 20, 5, 10, 2, {})
	var shield_action := CombatAction.new("TEST_GUARD", "抱石", "earth", 1, 0, 0, {"effect":"shield","effect_value":10,"effect_target":"self","condition":"always"})
	engine.setup([shield_target], [shield_actor])
	result = engine.perform_action(shield_actor, shield_target, shield_action)
	assert(result.get("ok", false))
	assert(shield_actor.barrier == 10)
	assert(shield_target.barrier == 0)

	print("ALL ENEMY SKILL EFFECT TESTS PASSED")
