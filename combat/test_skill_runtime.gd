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

	var bajie := Combatant.new("bajie", "猪八戒", 180, 24, 12, 15, 3, {}, "front")
	var bajie_enemy := Combatant.new("bajie_enemy", "妖怪", 220, 20, 5, 8, 2, {}, "front")
	var bajie_engine := CombatEngine.new()
	bajie_engine.setup([bajie], [bajie_enemy])
	bajie.bp = 2
	bajie.mechanic_resource = 3
	var eat := SkillCatalog.get_skill("BAJIE", "BAJIE_EAT")
	var eat_result := SkillRuntime.perform(bajie_engine, bajie, bajie, eat)
	_assert(eat_result.get("ok", false), "Bajie rage skill should execute")
	_assert_equal(bajie.attack, 36, "Rage should amplify Bajie's attack buff")
	_assert_equal(bajie.defense, 23, "Rage should amplify Bajie's defense buff")
	_assert_equal(bajie.mechanic_resource, 1, "Rage skill should spend its configured resource cost")

	var wujing := Combatant.new("wujing", "沙悟净", 180, 22, 10, 12, 3, {}, "front")
	var wujing_enemy := Combatant.new("wujing_enemy", "妖怪", 220, 20, 5, 8, 3, {}, "front")
	var wujing_engine := CombatEngine.new()
	wujing_engine.setup([wujing], [wujing_enemy])
	var slow := SkillCatalog.get_skill("WUJING", "WUJING_SLOW")
	wujing.bp = 4
	wujing.mechanic_resource = 0
	var first_slow := SkillRuntime.perform(wujing_engine, wujing, wujing_enemy, slow)
	_assert(first_slow.get("ok", false), "first Tide slow should execute")
	_assert_equal(wujing.mechanic_resource, 1, "first control should build Tide")
	_assert_equal(first_slow.get("effect_duration", 0), 2, "first slow uses base duration")

	wujing_enemy.speed = 20
	var second_slow := SkillRuntime.perform(wujing_engine, wujing, wujing_enemy, slow)
	_assert(second_slow.get("ok", false), "second Tide slow should execute")
	_assert_equal(wujing.mechanic_resource, 0, "stored Tide should be consumed")
	_assert_equal(second_slow.get("effect_duration", 0), 3, "stored Tide should extend control duration")

	print("ALL SKILL TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assert(actual == expected, "%s | expected=%s actual=%s" % [message, expected, actual])
