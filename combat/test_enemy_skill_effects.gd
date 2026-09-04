extends RefCounted

## Regression coverage for data-driven enemy skill effects.
static func run() -> void:
	var manager := EncounterManager.new()
	var enemies := manager.build_enemies("YELLOW_WIND_CAVE_SAND_GUARDS")
	assert(enemies.size() == 2)

	var guard: Combatant = enemies[0]
	var sand_effect_action := manager.choose_ai_action(guard, [], 3)
	assert(sand_effect_action.id == "SAND_GUARD_WIND")
	assert(sand_effect_action.effects.get("effect", "") == "slow")
	assert(int(sand_effect_action.effects.get("effect_value", 0)) == -3)
	assert(int(sand_effect_action.effects.get("effect_duration", 0)) == 2)

	var ally := Combatant.new("target", "受击角色", 200, 20, 5, 14, 2, {})
	var actor := Combatant.new("enemy", "测试妖兵", 200, 24, 6, 10, 2, {})
	var engine := CombatEngine.new()
	engine.setup([ally], [actor])
	actor.bp = 1
	var slow_action := CombatAction.new("TEST_SLOW", "寒风", "ice", 1, 0, 0, {"effect":"slow","effect_value":-4,"effect_duration":2})
	var before_speed := ally.speed
	var result := engine.perform_action(actor, ally, slow_action)
	assert(result.get("ok", false))
	assert(ally.speed == before_speed - 4)
	assert(ally.speed_effect_turns == 2)

	ally.aggro_turns = 0
	var taunt_action := CombatAction.new("TEST_TAUNT", "挑衅", "strike", 1, 0, 0, {"effect":"taunt","effect_value":1,"effect_duration":2})
	result = engine.perform_action(actor, ally, taunt_action)
	assert(result.get("ok", false))
	assert(ally.aggro_turns == 2)

	print("ALL ENEMY SKILL EFFECT TESTS PASSED")
