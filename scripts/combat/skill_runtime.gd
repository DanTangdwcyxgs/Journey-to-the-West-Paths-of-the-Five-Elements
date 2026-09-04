class_name SkillRuntime
extends RefCounted

## Executes data-driven skill side effects on CombatEngine/Combatant state.

static func perform(engine: CombatEngine, actor: Combatant, target: Combatant, skill: Dictionary, boosted: bool = false) -> Dictionary:
	if actor == null or target == null or skill.is_empty():
		return {"ok": false, "reason": "invalid_skill"}
	var action := SkillCatalog.build_action(skill)
	var mechanic_cost := int(skill.get("mechanic_cost", 0))
	if actor.mechanic_resource < mechanic_cost:
		return {"ok": false, "reason": "not_enough_mechanic_resource"}
	var kind := str(skill.get("kind", "damage"))
	match kind:
		"damage", "break_burst", "slow", "taunt":
			var result := engine.perform_action(actor, target, action, boosted)
			if not result.get("ok", false):
				return result
			_consume_and_gain(actor, target, kind, mechanic_cost, skill)
			if kind == "slow":
				target.apply_speed_delta(int(skill.get("speed_delta", 0)), int(skill.get("duration", 1)))
				result["effect"] = "slow"
				result["effect_duration"] = int(skill.get("duration", 1))
			if kind == "taunt":
				target.aggro_turns = maxi(target.aggro_turns, int(skill.get("aggro_turns", 1)))
				result["effect"] = "taunt"
			result["mechanic_resource"] = actor.mechanic_resource
			return result
		"heal":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			var before := target.hp
			target.heal(int(skill.get("heal_power", 0)))
			_consume_and_gain(actor, target, kind, mechanic_cost, skill)
			return {"ok": true, "damage": 0, "healed": target.hp - before, "target_hp": target.hp, "mechanic_resource": actor.mechanic_resource}
		"shield":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			var shield_amount := int(skill.get("shield_power", 0))
			if actor.id == "tangseng" and mechanic_cost == 1:
				shield_amount += 8
			target.gain_barrier(shield_amount)
			_consume_and_gain(actor, target, kind, mechanic_cost, skill)
			return {"ok": true, "damage": 0, "barrier": target.barrier, "mechanic_resource": actor.mechanic_resource}
		"self_buff":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			actor.attack += int(skill.get("attack_bonus", 0))
			actor.defense += int(skill.get("defense_bonus", 0))
			_consume_and_gain(actor, target, kind, mechanic_cost, skill)
			return {"ok": true, "damage": 0, "attack": actor.attack, "defense": actor.defense, "mechanic_resource": actor.mechanic_resource}
	return {"ok": false, "reason": "unsupported_skill_kind"}

static func _consume_and_gain(actor: Combatant, target: Combatant, kind: String, mechanic_cost: int, skill: Dictionary) -> void:
	if mechanic_cost > 0:
		actor.spend_mechanic_resource(mechanic_cost)
	var explicit_gain := int(skill.get("mechanic_gain", 0))
	if explicit_gain > 0:
		actor.add_mechanic_resource(explicit_gain)
		return
	match actor.id:
		"wukong":
			if target.is_broken() or kind == "break_burst":
				actor.add_mechanic_resource(1)
		"bajie":
			if kind == "taunt":
				actor.add_mechanic_resource(1)
		"wujing":
			if kind == "slow":
				actor.add_mechanic_resource(1)
		"longma":
			if kind == "damage" and str(target.row) == "back":
				actor.add_mechanic_resource(1)
