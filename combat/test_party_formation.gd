extends RefCounted

## Regression coverage for persistent 3-front / 2-back formation and combat row mapping.
static func run() -> void:
	var party := PartyManager.new()
	party.initialize_from_saved_state(
		["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"],
		{"roster":["TANG","WUKONG","BAJIE","WUJING","LONGMA"],"front_row":["TANG","BAJIE","LONGMA"],"back_row":["WUKONG","WUJING"]}
	)
	assert(party.roster == ["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"])
	assert(party.front_row == ["TANG", "BAJIE", "LONGMA"])
	assert(party.back_row == ["WUKONG", "WUJING"])

	var combatants := CombatPartyBuilder.build_active_party(party)
	assert(combatants.size() == 5)
	assert(combatants[0].id == "tang" and combatants[0].row == "front")
	assert(combatants[1].id == "bajie" and combatants[1].row == "front")
	assert(combatants[2].id == "longma" and combatants[2].row == "front")
	assert(combatants[3].id == "wukong" and combatants[3].row == "back")
	assert(combatants[4].id == "wujing" and combatants[4].row == "back")

	assert(party.swap_positions("TANG", "WUKONG"))
	assert(party.front_row == ["WUKONG", "BAJIE", "LONGMA"])
	assert(party.back_row == ["TANG", "WUJING"])
	print("PARTY FORMATION TEST PASSED")
