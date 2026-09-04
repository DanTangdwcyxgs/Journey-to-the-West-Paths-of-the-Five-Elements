extends RefCounted

## Regression coverage for character-specific resource generation and spending.

static func run() -> void:
	var engine := CombatEngine.new()
	var tang := Combatant.new("tangseng", "唐三藏", 120, 16, 8, 10, 2, {}, "back")
	var ally := Combatant.new("wukong", "孙悟空", 120, 20, 6, 12, 2, {}, "front")
	engine.setup([tang, ally], [])
	tang.hp = 80
	tang.bp = 1
	var heal := SkillCatalog.get_skill("TANG", "TANG_HEAL")
	var heal_result := SkillRuntime.perform(engine, tang, tang, heal)
	assert(heal_result.get("ok", false))
	assert(tang.mechanic_resource == 1)
	tang.begin_turn()
	assert(tang.mechanic_resource == 1)

	var shield := SkillCatalog.get_skill("TANG", "TANG_SHIELD")
	tang.bp = 2
	var shield_result := SkillRuntime.perform(engine, tang, ally, shield)
	assert(shield_result.get("ok", false))
	assert(tang.mechanic_resource == 0)
	assert(ally.barrier > 0)

	var longma := Combatant.new("longma", "白龙马", 120, 20, 8, 12, 2, {}, "front")
	longma.mechanic_resource = 1
	var form_manager := LongmaFormManager.new()
	var form := form_manager.shift(longma)
	assert(form.get("id", "") == "eagle")
	assert(longma.mechanic_resource == 0)
	longma.begin_turn()
	assert(longma.mechanic_resource == 0)
