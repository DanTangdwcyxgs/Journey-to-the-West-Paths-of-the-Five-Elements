class_name YellowWindBoss
extends RefCounted

## Encounter controller for the first major boss prototype: Yellow Wind Demon.
## Phase changes are deterministic so the encounter is easy to test and tune.

const PHASE_ONE := 1
const PHASE_TWO := 2
const PHASE_THREE := 3

var phase: int = PHASE_ONE
var sandstorm_turns: int = 0
var counter_window: int = 0
var last_known_weaknesses: Dictionary = {"fire": true, "wind": true}

func create_boss() -> Combatant:
	return Combatant.new("yellow_wind", "黄风妖王", 720, 34, 22, 24, 6, {"fire": true, "wind": true}, "front")

func begin_encounter(boss: Combatant) -> void:
	phase = PHASE_ONE
	sandstorm_turns = 0
	counter_window = 0
	boss.mechanic_resource = 0

func after_action(boss: Combatant) -> Dictionary:
	if phase == PHASE_ONE and boss.hp <= int(boss.max_hp * 0.66):
		_enter_phase_two(boss)
	elif phase == PHASE_TWO and boss.hp <= int(boss.max_hp * 0.33):
		_enter_phase_three(boss)
	return {"phase": phase, "sandstorm_turns": sandstorm_turns, "counter_window": counter_window}

func on_turn_start(boss: Combatant) -> Dictionary:
	if sandstorm_turns > 0:
		sandstorm_turns -= 1
	if counter_window > 0:
		counter_window -= 1
	if boss.is_broken():
		counter_window = 0
	return {"phase": phase, "sandstorm_turns": sandstorm_turns, "counter_window": counter_window}

func choose_action(boss: Combatant, allies: Array[Combatant]) -> CombatAction:
	if phase == PHASE_TWO and sandstorm_turns == 0:
		return CombatAction.new("sandstorm", "黄风起·飞沙走石", "wind", 26, 1, 1)
	if phase == PHASE_THREE and counter_window == 0:
		counter_window = 1
		return CombatAction.new("wind_counter", "风刃回风", "wind", 38, 2, 1)
	return CombatAction.new("claw", "黄风爪", "wind", 30, 1, 0)

func apply_action_effects(action_id: String, boss: Combatant) -> void:
	match action_id:
		"sandstorm":
			sandstorm_turns = 2
		"wind_counter":
			counter_window = 1

func _enter_phase_two(boss: Combatant) -> void:
	phase = PHASE_TWO
	sandstorm_turns = 2
	boss.restore_shield()

func _enter_phase_three(boss: Combatant) -> void:
	phase = PHASE_THREE
	counter_window = 1
	boss.restore_shield()
	boss.attack += 8
	boss.speed += 4
