extends RefCounted

## Regression coverage for authored origin choices carrying into a starting-character battle.

static func run() -> void:
	var power_choice := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(power_choice, "WUKONG", {"WUK-03":"SEEK_POWER"})
	assert(power_choice.attack == 22)

	var freedom_choice := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(freedom_choice, "WUKONG", {"WUK-08":"REJECT_BINDING"})
	assert(freedom_choice.speed == 13)
	assert(freedom_choice.base_speed == 13)

	var endure_choice := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(endure_choice, "WUKONG", {"WUK-13":"ENDURE"})
	assert(endure_choice.defense == 7)

	var combined := Combatant.new("wukong", "孙悟空", 100, 20, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(combined, "WUKONG", {
		"WUK-03":"SEEK_POWER",
		"WUK-08":"REJECT_BINDING",
		"WUK-13":"ENDURE"
	})
	assert(combined.attack == 22)
	assert(combined.speed == 13)
	assert(combined.base_speed == 13)
	assert(combined.defense == 7)

	var tang := Combatant.new("tangseng", "唐三藏", 100, 10, 5, 8, 2, {})
	CombatPartyBuilder._apply_origin_choices(tang, "TANG", {"TANG-04":"SERVE_PEOPLE"})
	assert(is_equal_approx(float(tang.combat_modifiers.get("healing_multiplier", 1.0)), 1.15))

	var longma := Combatant.new("longma", "白龙马", 100, 14, 5, 12, 2, {})
	CombatPartyBuilder._apply_origin_choices(longma, "LONGMA", {"LONGMA-02":"RESIST_FATE"})
	assert(longma.speed == 14)
	assert(longma.base_speed == 14)
