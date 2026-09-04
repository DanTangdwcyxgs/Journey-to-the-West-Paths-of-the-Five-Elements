extends RefCounted

## Regression checks for equipment/loadout modifiers used by SkillRuntime.

static func run() -> void:
	var target := Combatant.new("target", "目标", 200, 20, 1, 10, 4, {})
	var caster := Combatant.new("tangseng", "唐三藏", 100, 12, 10, 10, 2, {})
	caster.combat_modifiers = {"healing_multiplier": 1.25, "shield_multiplier": 1.2}
	target.hp = 20
	caster.bp = 2
	var heal := {"id":"heal", "name":"慈悲" ,"element":"HOLY", "kind":"heal", "power":0, "shield_hit":0, "bp_cost":1, "heal_power":40, "mechanic_cost":0}
	var heal_result := SkillRuntime.perform(CombatEngine.new(), caster, target, heal)
	assert(heal_result.get("ok", false))
	assert(heal_result.get("healed", 0) == 50)

	caster.bp = 2
	var shield := {"id":"shield", "name":"护行", "element":"HOLY", "kind":"shield", "power":0, "shield_hit":0, "bp_cost":1, "shield_power":30, "mechanic_cost":0}
	var shield_result := SkillRuntime.perform(CombatEngine.new(), caster, target, shield)
	assert(shield_result.get("ok", false))
	assert(target.barrier == 36)

	var attacker := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	attacker.combat_modifiers = {"fire_damage_multiplier": 1.35, "shield_damage_bonus": 1}
	var enemy := Combatant.new("enemy", "妖怪", 200, 10, 1, 8, 4, {"FIRE": true})
	var engine := CombatEngine.new()
	engine.setup([attacker], [enemy])
	attacker.bp = 1
	var fire := {"id":"fire", "name":"火眼金睛", "element":"FIRE", "kind":"damage", "power":40, "shield_hit":1, "bp_cost":1, "mechanic_cost":0}
	var fire_result := SkillRuntime.perform(engine, attacker, enemy, fire)
	assert(fire_result.get("ok", false))
	assert(enemy.shield == 2)
