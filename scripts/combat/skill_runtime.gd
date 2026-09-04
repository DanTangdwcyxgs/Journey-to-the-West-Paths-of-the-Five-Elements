class_name SkillRuntime
extends RefCounted

## Executes data-driven skill side effects on CombatEngine/Combatant state.

static func perform(engine: CombatEngine, actor: Combatant, target: Combatant, skill: Dictionary, boosted: bool = false) -> Dictionary:
	if actor == null or target == null or skill.is_empty():
		return {"ok": false, "reason": "invalid_skill"}
	var action := SkillCatalog.build_action(skill)
	var kind := str(skill.get("kind", "damage"))
	match kind:
		"damage", "break_burst", "slow", "taunt":
			var result := engine.perform_action(actor, target, action, boosted)
			if not result.get("ok", false):
				return result
			if kind == "slow":
				target.apply_speed_delta(int(skill.get("speed_delta", 0)), int(skill.get("duration", 1)))
				result["effect"] = "slow"
				result["effect_duration"] = int(skill.get("duration", 1))
			if kind == "taunt":
				target.aggro_turns = maxi(target.aggro_turns, int(skill.get("aggro_turns", 1)))
				result["effect"] = "taunt"
			return result
		"heal":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			var before := actor.hp
			actor.heal(int(skill.get("heal_power", 0)))
			return {"ok": true, "damage": 0, "healed": actor.hp - before, "target_hp": actor.hp}
		"shield":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			actor.gain_barrier(int(skill.get("shield_power", 0)))
			return {"ok": true, "damage": 0, "barrier": actor.barrier}
		"self_buff":
			if actor.bp < action.bp_cost:
			return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			actor.attack += int(skill.get("attack_bonus", 0))
			actor.defense += int(skill.get("defense_bonus", 0))
			return {"ok": true, "damage": 0, "attack": actor.attack, "defense": actor.defense}
	return {"ok": false, "reason": "unsupported_skill_kind"}
