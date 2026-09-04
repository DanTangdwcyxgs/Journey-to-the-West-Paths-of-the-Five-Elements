class_name CombatEngine
extends RefCounted

signal combat_log(message: String)
signal combat_finished(winner: String)

const BACK_ROW_DAMAGE_MULTIPLIER := 0.85

var allies: Array[Combatant] = []
var enemies: Array[Combatant] = []
var turn_number: int = 0
var turn_queue: Array[Combatant] = []

func setup(p_allies: Array[Combatant], p_enemies: Array[Combatant]) -> void:
	allies = p_allies
	enemies = p_enemies
	turn_number = 0
	turn_queue.clear()

func rebuild_turn_queue() -> void:
	turn_queue.clear()
	for unit in allies:
		if unit.is_alive():
			turn_queue.append(unit)
	for unit in enemies:
		if unit.is_alive():
			turn_queue.append(unit)
	turn_queue.sort_custom(func(a: Combatant, b: Combatant) -> bool:
		if a.speed == b.speed:
			return a.id < b.id
		return a.speed > b.speed
	)

func next_actor() -> Combatant:
	if turn_queue.is_empty():
		rebuild_turn_queue()
	if turn_queue.is_empty():
		return null
	var actor: Combatant = turn_queue.pop_front()
	if not actor.is_alive():
		return next_actor()
	return actor

func perform_action(actor: Combatant, target: Combatant, action: CombatAction, boosted: bool = false) -> Dictionary:
	if actor == null or target == null or not actor.is_alive() or not target.is_alive():
		return {"ok": false, "reason": "invalid_actor_or_target"}
	if actor.is_broken():
		combat_log.emit("%s is Broken and cannot act." % actor.display_name)
		return {"ok": false, "reason": "broken_actor"}
	if action.bp_cost > actor.bp:
		return {"ok": false, "reason": "not_enough_bp"}

	actor.bp -= action.bp_cost
	var multiplier := 1.0
	if boosted:
		multiplier += float(action.bp_cost) * 0.35

	var defense_value := maxi(target.defense, 0)
	var raw_damage := maxi(actor.attack + action.power - defense_value, 1)
	var damage_multiplier := 2.0 if target.is_broken() else 1.0
	if target.row == "back" and not target.is_broken():
		damage_multiplier *= BACK_ROW_DAMAGE_MULTIPLIER
	var damage := maxi(int(round(raw_damage * multiplier * damage_multiplier)), 1)
	var dealt := target.take_damage(damage)

	# Bajie's Rage is earned when he actually absorbs incoming combat damage.
	# Keep this here rather than in Combatant.take_damage so self-inflicted or
	# non-combat state changes cannot accidentally generate Rage.
	if target.id == "bajie" and dealt > 0:
		target.add_mechanic_resource(1)

	var weakness_hit := false
	if target.weaknesses.get(action.element, false):
		weakness_hit = true
		target.shield = maxi(target.shield - action.shield_hit - 1, 0)
		combat_log.emit("Weakness hit! %s shield -> %d/%d" % [target.display_name, target.shield, target.max_shield])
		if target.shield == 0 and not target.is_broken():
			target.broken_turns = 2
			combat_log.emit("BREAK! %s is Broken." % target.display_name)
	else:
		target.shield = maxi(target.shield - action.shield_hit, 0)

	combat_log.emit("%s uses %s on %s for %d damage." % [actor.display_name, action.display_name, target.display_name, dealt])
	_check_end()
	return {
		"ok": true,
		"damage": dealt,
		"weakness_hit": weakness_hit,
		"target_broken": target.is_broken(),
		"target_hp": target.hp,
		"target_shield": target.shield,
		"target_mechanic_resource": target.mechanic_resource,
	}

func advance_turn() -> Combatant:
	var actor := next_actor()
	if actor == null:
		return null
	turn_number += 1
	actor.begin_turn()
	combat_log.emit("-- Turn %d: %s (BP %d) --" % [turn_number, actor.display_name, actor.bp])
	return actor

func _check_end() -> void:
	var allies_alive := false
	var enemies_alive := false
	for unit in allies:
		allies_alive = allies_alive or unit.is_alive()
	for unit in enemies:
		enemies_alive = enemies_alive or unit.is_alive()
	if not enemies_alive:
		combat_finished.emit("allies")
	elif not allies_alive:
		combat_finished.emit("enemies")
