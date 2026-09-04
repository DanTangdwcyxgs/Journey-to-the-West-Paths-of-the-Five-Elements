extends SceneTree

func _initialize() -> void:
	var engine := CombatEngine.new()
	var wukong := Combatant.new("wukong", "Sun Wukong", 220, 42, 16, 28, 2, {"fire": true, "strike": true})
	var tang := Combatant.new("tangseng", "Tang Sanzang", 180, 18, 12, 20, 3, {"holy": true})
	var demon := Combatant.new("demon", "Test Demon", 200, 30, 20, 10, 2, {"fire": true})
	engine.setup([wukong, tang], [demon])

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

	_assert_equal(engine.advance_turn(), tang, "next living actor should be Tang Sanzang")
	_assert_equal(tang.bp, 1, "Tang Sanzang gains BP at turn start")

	print("ALL COMBAT TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assert(actual == expected, "%s | expected=%s actual=%s" % [message, expected, actual])
