extends SceneTree

func _initialize() -> void:
	var engine := CombatEngine.new()
	var wukong := Combatant.new("wukong", "Sun Wukong", 220, 42, 16, 28, 2, {"fire": true, "strike": true}, "front")
	var tang := Combatant.new("tangseng", "Tang Sanzang", 180, 18, 12, 20, 3, {"holy": true}, "back")
	var bajie := Combatant.new("bajie", "Zhu Bajie", 180, 24, 12, 15, 3, {}, "front")
	var demon := Combatant.new("demon", "Test Demon", 200, 30, 20, 10, 2, {"fire": true}, "front")
	engine.setup([wukong, tang, bajie], [demon])

	_assert_equal(engine.advance_turn(), wukong, "speed should determine first actor")
	_assert_equal(wukong.bp, 1, "living actor gains one BP")

	var fire := CombatAction.new("fire", "Fire", "fire", 20, 0, 0)
	var first := engine.perform_action(wukong, demon, fire)
	_assert(first.get("weakness_hit", false), "fire must hit fire weakness")
	_assert_equal(demon.shield, 1, "weakness attack reduces shield")
	var normal_damage := first.get("damage", 0)

	var second := engine.perform_action(wukong, demon, fire)
	_assert(second.get("target_broken", false), "second weakness hit should trigger Break")
	_assert_equal(demon.shield, 0, "shield reaches zero on Break")
	_assert(second.get("damage", 0) > normal_damage, "Break should amplify incoming damage")

	var blocked := engine.perform_action(tang, demon, fire)
	_assert(blocked.get("ok", false), "a living ally can attack a Broken target")

	_assert_equal(engine.advance_turn(), bajie, "next living actor should be Bajie")
	_assert_equal(bajie.bp, 1, "Bajie gains BP at turn start")

	var bajie_hit := engine.perform_action(wukong, bajie, fire)
	_assert(bajie_hit.get("ok", false), "Bajie should be a valid combat target")
	_assert(bajie_hit.get("damage", 0) > 0, "direct damage should be dealt to Bajie")
	_assert_equal(bajie.mechanic_resource, 1, "direct combat damage should grant Bajie one Rage")

	_assert_equal(engine.advance_turn(), tang, "next living actor should be Tang Sanzang")
	_assert_equal(tang.bp, 1, "Tang Sanzang gains BP at turn start")
	_assert_equal(tang.row, "back", "formation builder-compatible combatant keeps back row")

	var front_target := Combatant.new("front_target", "Front Target", 300, 1, 10, 1, 0, {}, "front")
	var back_target := Combatant.new("back_target", "Back Target", 300, 1, 10, 1, 0, {}, "back")
	var attacker := Combatant.new("attacker", "Attacker", 220, 50, 10, 30, 1, {}, "front")
	var plain := CombatAction.new("plain", "Plain Strike", "strike", 20, 0, 0)
	var front_result := engine.perform_action(attacker, front_target, plain)
	var back_result := engine.perform_action(attacker, back_target, plain)
	_assert(back_result.get("damage", 0) < front_result.get("damage", 0), "back row should reduce incoming damage")

	print("ALL COMBAT TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assert(actual == expected, "%s | expected=%s actual=%s" % [message, expected, actual])
