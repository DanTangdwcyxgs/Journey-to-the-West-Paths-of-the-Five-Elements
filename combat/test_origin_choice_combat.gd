extends RefCounted

## Regression coverage for authored origin choices carrying into a starting-character battle.

static func run() -> void:
	var power_choice := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(power_choice, {"WUK-03":"SEEK_POWER"})
	assert(power_choice.attack == 22)

	var freedom_choice := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(freedom_choice, {"WUK-08":"REJECT_BINDING"})
	assert(freedom_choice.speed == 13)
	assert(freedom_choice.base_speed == 13)

	var endure_choice := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(endure_choice, {"WUK-13":"ENDURE"})
	assert(endure_choice.defense == 7)

	var combined := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(combined, {
		"WUK-03":"SEEK_POWER",
		"WUK-08":"REJECT_BINDING",
		"WUK-13":"ENDURE"
	})
	assert(combined.attack == 22)
	assert(combined.speed == 13)
	assert(combined.base_speed == 13)
	assert(combined.defense == 7)
