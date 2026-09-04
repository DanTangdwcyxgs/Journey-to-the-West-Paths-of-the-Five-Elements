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
		if unit.is_alive(): turn_queue.append(unit)
	for unit in enemies:
		if unit.is_alive(): turn_queue.append(unit)
	turn_queue.sort_custom(func(a: Combatant, b: Combatant) -> bool:
		if a.speed == b.speed: return a.id < b.id
		return a.speed > b.speed
	)

func next_actor() -> Combatant:
	if turn_queue.is_empty(): rebuild_turn_queue()
	if turn_queue.is_empty(): return null
	var actor: Combatant = turn_queue.pop_front()
	if not actor.is_alive(): return next_actor()
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
	var multiplier := 1.0 + (float(action.bp_cost) * 0.35 if boosted else 0.0)
	var defense_value := maxi(target.defense, 0)
	var raw_damage := maxi(actor.attack + action.power - defense_value, 1)
	var damage_multiplier := 2.0 if target.is_broken() else 1.0
	if target.row == "back" and not target.is_broken(): damage_multiplier *= BACK_ROW_DAMAGE_MULTIPLIER
	var damage := maxi(int(round(raw_damage * multiplier * damage_multiplier)), 1)
	var dealt := target.take_damage(damage)

	if target.id == "bajie" and dealt > 0: target.add_mechanic_resource(1)

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

	var effect_result := _apply_action_effects(actor, target, action, dealt > 0)
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
		"target_barrier": target.barrier,
		"target_aggro_turns": target.aggro_turns,
		"target_speed": target.speed,
		"effect": effect_result.get("effect", ""),
		"effect_duration": effect_result.get("duration", 0),
		"effect_applied": effect_result.get("applied", false),
	}

func _apply_action_effects(actor: Combatant, target: Combatant, action: CombatAction, landed: bool) -> Dictionary:
	if action == null or action.effects.is_empty(): return {}
	var condition := str(action.effects.get("condition", "always")).to_lower()
	if condition == "on_hit" and not landed: return {"applied": false, "reason": "condition_failed"}
	if condition == "when_target_broken" and not target.is_broken(): return {"applied": false, "reason": "condition_failed"}
	if condition == "when_target_alive" and not target.is_alive(): return {"applied": false, "reason": "condition_failed"}
	var effect := str(action.effects.get("effect", "")).to_lower()
	var value := int(action.effects.get("effect_value", 0))
	var duration := maxi(int(action.effects.get("effect_duration", 0)), 0)
	var effect_target := str(action.effects.get("effect_target", action.effects.get("target", "target"))).to_lower()
	var receiver := actor if effect_target == "self" else target
	match effect:
		"slow":
			if value == 0 or duration <= 0: return {"applied": false, "reason": "invalid_effect_parameters"}
			receiver.apply_speed_delta(value, duration)
			combat_log.emit("%s 速度 %+d，持续 %d 回合。" % [receiver.display_name, value, duration])
			return {"applied": true, "effect": effect, "duration": duration}
		"taunt":
			if duration <= 0: return {"applied": false, "reason": "invalid_effect_parameters"}
			receiver.apply_taunt(duration)
			combat_log.emit("%s 被嘲讽，持续 %d 回合。" % [receiver.display_name, duration])
			return {"applied": true, "effect": effect, "duration": duration}
		"shield", "barrier":
			if value <= 0: return {"applied": false, "reason": "invalid_effect_parameters"}
			receiver.gain_barrier(value)
			combat_log.emit("%s 获得 %d 点屏障。" % [receiver.display_name, value])
			return {"applied": true, "effect": effect, "duration": duration}
		_:
			return {"applied": false, "reason": "unsupported_effect"}

func advance_turn() -> Combatant:
	var actor := next_actor()
	if actor == null: return null
	turn_number += 1
	actor.begin_turn()
	combat_log.emit("-- Turn %d: %s (BP %d) --" % [turn_number, actor.display_name, actor.bp])
	return actor

func _check_end() -> void:
	var allies_alive := false
	var enemies_alive := false
	for unit in allies: allies_alive = allies_alive or unit.is_alive()
	for unit in enemies: enemies_alive = enemies_alive or unit.is_alive()
	if not enemies_alive: combat_finished.emit("allies")
	elif not allies_alive: combat_finished.emit("enemies")
