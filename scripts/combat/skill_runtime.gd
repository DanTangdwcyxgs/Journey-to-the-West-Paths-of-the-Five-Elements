class_name SkillRuntime
extends RefCounted

## Executes data-driven skill side effects on CombatEngine/Combatant state.
## Loadout effects are applied here so the same combat formulas work for every battle entry point.

static func perform(engine: CombatEngine, actor: Combatant, target: Combatant, skill: Dictionary, boosted: bool = false) -> Dictionary:
	if actor == null or target == null or skill.is_empty():
		return {"ok": false, "reason": "invalid_skill"}
	var action := _build_modified_action(skill, actor)
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
				var duration := _scaled_duration(int(skill.get("duration", 1)), actor, "control_multiplier")
				target.apply_speed_delta(int(skill.get("speed_delta", 0)), duration)
				result["effect"] = "slow"
				result["effect_duration"] = duration
			if kind == "taunt":
				var taunt_duration := _scaled_duration(int(skill.get("aggro_turns", 1)), actor, "control_multiplier")
				target.aggro_turns = maxi(target.aggro_turns, taunt_duration)
				result["effect"] = "taunt"
				result["effect_duration"] = taunt_duration
				result["aggro_multiplier"] = float(actor.combat_modifiers.get("aggro_multiplier", 1.0))
			result["mechanic_resource"] = actor.mechanic_resource
			return result
		"heal":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			var before := target.hp
			var heal_power := _scaled_amount(int(skill.get("heal_power", 0)), actor, "healing_multiplier")
			target.heal(heal_power)
			_consume_and_gain(actor, target, kind, mechanic_cost, skill)
			return {"ok": true, "damage": 0, "healed": target.hp - before, "target_hp": target.hp, "mechanic_resource": actor.mechanic_resource}
		"shield":
			if actor.bp < action.bp_cost:
				return {"ok": false, "reason": "not_enough_bp"}
			actor.bp -= action.bp_cost
			var shield_amount := _scaled_amount(int(skill.get("shield_power", 0)), actor, "shield_multiplier")
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
		"form_shift":
			if actor.id != "longma":
				return {"ok": false, "reason": "form_shift_only_for_longma"}
			var form_manager := LongmaFormManager.new()
			var form := form_manager.shift(actor)
			if form.is_empty():
				return {"ok": false, "reason": "form_shift_failed"}
			return {"ok": true, "damage": 0, "form": str(form.get("id", "horse")), "form_name": str(form.get("name", "")), "form_duration": form_manager.duration, "mechanic_resource": actor.mechanic_resource}
	return {"ok": false, "reason": "unsupported_skill_kind"}

static func _build_modified_action(skill: Dictionary, actor: Combatant) -> CombatAction:
	var base := SkillCatalog.build_action(skill)
	var power := base.power
	var shield_hit := base.shield_hit
	var elemental_key := "%s_damage_multiplier" % base.element.to_lower()
	if actor.combat_modifiers.has(elemental_key):
		power = maxi(int(round(power * float(actor.combat_modifiers[elemental_key]))), 1)
	if actor.combat_modifiers.has("shield_damage_bonus"):
		shield_hit += int(actor.combat_modifiers["shield_damage_bonus"])
	return CombatAction.new(base.id, base.display_name, base.element, power, shield_hit, base.bp_cost)

static func _scaled_amount(amount: int, actor: Combatant, modifier_id: String) -> int:
	return maxi(int(round(amount * float(actor.combat_modifiers.get(modifier_id, 1.0)))), 0)

static func _scaled_duration(duration: int, actor: Combatant, modifier_id: String) -> int:
	return maxi(int(ceil(float(duration) * float(actor.combat_modifiers.get(modifier_id, 1.0)))), duration)

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
