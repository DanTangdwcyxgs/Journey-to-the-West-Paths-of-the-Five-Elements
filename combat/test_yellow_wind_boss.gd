extends SceneTree

func _initialize() -> void:
	var boss_runtime := YellowWindBoss.new()
	var boss := boss_runtime.create_boss()
	boss_runtime.begin_encounter(boss)
	_assert_equal(boss_runtime.phase, YellowWindBoss.PHASE_ONE, "boss starts in phase one")
	boss.hp = 470
	boss_runtime.after_action(boss)
	_assert_equal(boss_runtime.phase, YellowWindBoss.PHASE_TWO, "66 percent threshold enters phase two")
	_assert_equal(boss.shield, boss.max_shield, "phase two refreshes shield")
	var action := boss_runtime.choose_action(boss, [])
	_assert_equal(action.id, "sandstorm", "phase two opens with sandstorm")
	boss_runtime.apply_action_effects(action.id, boss)
	_assert_equal(boss_runtime.sandstorm_turns, 2, "sandstorm persists for two turns")

	boss.hp = 230
	boss_runtime.after_action(boss)
	_assert_equal(boss_runtime.phase, YellowWindBoss.PHASE_THREE, "33 percent threshold enters phase three")
	_assert(boss.attack > 34, "phase three raises attack")
	_assert(boss.speed > 24, "phase three raises speed")
	var phase_three_action := boss_runtime.choose_action(boss, [])
	_assert_equal(phase_three_action.id, "wind_counter", "phase three exposes counter window")
	_assert_equal(boss_runtime.counter_window, 1, "counter window is armed")

	print("ALL YELLOW WIND BOSS TESTS PASSED")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assert(actual == expected, "%s | expected=%s actual=%s" % [message, expected, actual])
