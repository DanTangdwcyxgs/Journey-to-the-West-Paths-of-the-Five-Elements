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

	var second := engine.perform_action(wukong, demon, fire)
	_assert(demon.is_broken(), "second weakness hit should trigger Break")
	_assert_equal(demon.shield, 0, "shield reaches zero on Break")

	var incoming := CombatAction.new("hit", "Hit", "strike", 1, 0, 0)
	var hp_before := demon.hp
	var boosted := engine.perform_action(wukong, demon, incoming)
	_assert(boosted.get("damage", 0) > (hp_before - demon.hp - 1), "Broken target should take amplified damage")

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
