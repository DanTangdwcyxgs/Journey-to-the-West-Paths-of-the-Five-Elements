extends RefCounted

## Regression check for the data-driven LONGMA_SHIFT action.

static func run() -> void:
	var actor := Combatant.new("longma", "白龙马", 120, 20, 10, 12, 2, {})
	var target := Combatant.new("enemy", "妖怪", 100, 10, 5, 8, 2, {})
	actor.mechanic_resource = 1
	var engine := CombatEngine.new()
	engine.setup([actor], [target])
	var shift := {"id":"LONGMA_SHIFT","name":"龙形变","element":"water","power":0,"shield_hit":0,"bp_cost":0,"kind":"form_shift","mechanic_cost":1}
	var result := SkillRuntime.perform(engine, actor, target, shift)
	assert(result.get("ok", false))
	assert(result.get("form", "") == "eagle")
	assert(actor.mechanic_resource == 0)
	assert(actor.longma_form == "eagle")
