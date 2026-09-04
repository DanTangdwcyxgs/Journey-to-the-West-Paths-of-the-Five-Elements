extends SceneTree

func _initialize() -> void:
	var engine := CombatEngine.new()
	var tang := Combatant.new("tang", "唐三藏", 180, 18, 12, 20, 3, {"holy": true}, "back")
	var wukong := Combatant.new("wukong", "孙悟空", 220, 42, 16, 28, 4, {"fire": true, "strike": true}, "front")
	var demon := Combatant.new("demon", "黄风妖", 320, 30, 20, 18, 4, {"fire": true}, "front")
	engine.setup([tang, wukong], [demon])

	var heal := SkillCatalog.get_skill("TANG", "TANG_HEAL")
	var shield := SkillCatalog.get_skill("TANG", "TANG_SHIELD")
	var fire := SkillCatalog.get_skill("WUKONG", "WUK_FIRE")
	_assert(not heal.is_empty(), "Tang heal skill should load")
	_assert(not shield.is_empty(), "Tang shield skill should load")
	_assert(not fire.is_empty(), "Wukong fire skill should load")

	tang.hp = 120
	tang.bp = 2
	var heal_result := SkillRuntime.perform(engine, tang, tang, heal)
	_assert(heal_result.get("ok", false), "targeted healing should work")
	_assert_equal(tang.hp, 168, "heal should restore the configured amount")
	_assert_equal(tang.bp, 1, "heal should spend one BP")

	tang.bp = 2
	var shield_result := SkillRuntime.perform(engine, tang, wukong, shield)
	_assert(shield_result.get("ok", false), "targeted barrier should work")
	_assert_equal(wukong.barrier, 32, "shield skill should grant barrier to target")
	_assert_equal(tang.bp, 0, "shield should spend two BP")

	wukong.bp = 1
	var fire_result := SkillRuntime.perform(engine, wukong, demon, fire)
	_assert(fire_result.get("ok", false), "damage skill should delegate to combat engine")
	_assert(fire_result.get("weakness_hit", false), "fire should exploit the demon weakness")
	_assert_equal(wukong.bp, 0, "damage skill should spend one BP")

	print("ALL SKILL TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assert(actual == expected, "%s | expected=%s actual=%s" % [message, expected, actual])
