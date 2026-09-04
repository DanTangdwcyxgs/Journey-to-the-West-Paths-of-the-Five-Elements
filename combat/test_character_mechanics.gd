extends SceneTree

func _initialize() -> void:
	var party := PartyManager.new()
	party.initialize_from_recruited(["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"])
	var allies := CombatPartyBuilder.build_active_party(party)
	_assert_equal(allies.size(), 5, "five active profiles should build")

	var wukong: Combatant = _find(allies, "wukong")
	var tang: Combatant = _find(allies, "tangseng")
	var bajie: Combatant = _find(allies, "bajie")
	_assert_equal(wukong.mechanic_max, 3, "Wukong mechanic cap")
	_assert_equal(tang.mechanic_max, 3, "Tang mechanic cap")
	_assert_equal(bajie.mechanic_max, 5, "Bajie mechanic cap")

	var engine := CombatEngine.new()
	var dummy := Combatant.new("dummy", "Dummy", 400, 1, 10, 1, 2, {"fire": true})
	engine.setup(allies, [dummy])
	wukong.mechanic_resource = 1
	var clone := SkillCatalog.get_skill("WUKONG", "WUK_CLONES")
	var clone_result := SkillRuntime.perform(engine, wukong, dummy, clone)
	_assert(clone_result.get("ok", false), "Wukong clone skill should execute with resource")
	_assert_equal(wukong.mechanic_resource, 0, "clone consumes one Wukong resource")

	tang.mechanic_resource = 1
	tang.bp = 2
	var ally_target: Combatant = _find(allies, "bajie")
	var shield_skill := SkillCatalog.get_skill("TANG", "TANG_SHIELD")
	var shield_result := SkillRuntime.perform(engine, tang, ally_target, shield_skill)
	_assert(shield_result.get("ok", false), "Tang shield should execute on an ally")
	_assert(ally_target.barrier > 32, "Mercy-empowered shield should exceed base barrier")
	_assert_equal(tang.mechanic_resource, 0, "Tang shield consumes Mercy")

	print("ALL CHARACTER MECHANIC TESTS PASSED")
	quit(0)

func _find(units: Array[Combatant], id: String) -> Combatant:
	for unit in units:
		if unit.id == id:
			return unit
	return null

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assert(actual == expected, "%s | expected=%s actual=%s" % [message, expected, actual])
