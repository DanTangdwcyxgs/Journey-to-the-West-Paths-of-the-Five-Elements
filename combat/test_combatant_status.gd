extends RefCounted

## Regression checks for the readable temporary combat status layer.

static func run() -> void:
	var unit := Combatant.new("test", "测试", 100, 20, 10, 10, 2, {})
	assert(unit.get_status_summary() == "无状态")
	unit.gain_barrier(20)
	assert("护盾 +20" in unit.get_status_summary())
	unit.apply_speed_delta(-5, 2)
	unit.aggro_turns = 1
	assert("速度 -5 2T" in unit.get_status_summary())
	assert("嘲讽 1T" in unit.get_status_summary())
	unit.broken_turns = 2
	assert("Break 2T" in unit.get_status_summary())
	unit.barrier = 0
	unit.aggro_turns = 0
	unit.speed_delta = 0
	unit.speed_effect_turns = 0
	unit.broken_turns = 0
	assert(unit.get_status_summary() == "无状态")
