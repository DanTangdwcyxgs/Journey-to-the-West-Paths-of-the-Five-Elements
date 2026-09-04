class_name CombatPartyBuilder
extends RefCounted

## Converts the narrative party formation into Combatant instances.
## This keeps combat construction separate from the narrative save format.
const PROFILE_PATH := "res://data/combat/party_profiles.json"
const MECHANIC_PATH := "res://data/combat/character_mechanics.json"

static func build_active_party(party: PartyManager) -> Array[Combatant]:
	# Battle scenes may arrive with a transient encounter handoff after the UI has
	# already created a convenience party object. Restore the actual roster + saved
	# formation when available. Origin battles are special: the starting character
	# is playable before formal recruitment at the route convergence.
	_sync_active_encounter_party(party)
	var origin_character := _get_origin_battle_character()
	var origin_choices: Dictionary = {}
	if origin_character != "":
		var narrative := NarrativeManager.new()
		if narrative.load():
			origin_choices = narrative.state.origin_choices.duplicate(true)
		party.initialize_from_recruited([origin_character])
	var profiles := _load_profiles()
	var mechanics := _load_mechanics()
	var result: Array[Combatant] = []
	for character_id in party.get_active_order():
		var profile: Dictionary = profiles.get(character_id, {})
		if profile.is_empty():
			continue
		var mechanic: Dictionary = mechanics.get(character_id, {})
		var row := "front" if character_id in party.front_row else "back"
		var unit := _build_combatant(character_id, profile, mechanic, row)
		if origin_character != "":
			_apply_origin_choices(unit, origin_character, origin_choices)
		result.append(unit)
	return result

static func _sync_active_encounter_party(party: PartyManager) -> void:
	if party == null:
		return
	var handoff := BountyEncounterState.get_active_record()
	if handoff.is_empty():
		return
	var narrative := NarrativeManager.new()
	if narrative.load() and not narrative.state.recruited_characters.is_empty():
		party.initialize_from_saved_state(narrative.state.recruited_characters, narrative.state.get_party_formation())

static func _get_origin_battle_character() -> String:
	var handoff := BountyEncounterState.get_active_record()
	if str(handoff.get("encounter_type", "")) != "origin":
		return ""
	var narrative := NarrativeManager.new()
	if not narrative.load():
		return ""
	var starting_character := str(narrative.state.starting_character)
	return starting_character if starting_character in NarrativeState.CHARACTER_IDS else ""

static func _apply_origin_choices(unit: Combatant, origin_character: String, choices: Dictionary) -> void:
	if unit == null or unit.id != origin_character.to_lower():
		return
	var event_manager := OriginEventManager.new()
	for chapter_id in choices.keys():
		var choice_id := str(choices[chapter_id])
		var effects := event_manager.get_choice_effects(str(chapter_id), choice_id)
		if effects.is_empty():
			continue
		var traits: Dictionary = effects.get("combat_modifiers", {})
		unit.attack += int(traits.get("attack_bonus", 0))
		unit.defense += int(traits.get("defense_bonus", 0))
		var speed_bonus := int(traits.get("speed_bonus", 0))
		unit.speed += speed_bonus
		unit.base_speed += speed_bonus
		for key in ["healing_multiplier", "shield_multiplier", "control_multiplier", "shield_damage_bonus", "aggro_multiplier"]:
			if traits.has(key):
				unit.combat_modifiers[key] = float(traits[key])
		unit.combat_modifiers["origin_choice_%s" % chapter_id] = choice_id

static func _build_combatant(character_id: String, profile: Dictionary, mechanic: Dictionary, row: String) -> Combatant:
	var modifier: Dictionary = profile.get("%s_modifier" % row, {})
	var defense_value := int(round(int(profile.get("defense", 1)) * float(modifier.get("defense", 1.0))))
	var speed_value := int(round(int(profile.get("speed", 1)) * float(modifier.get("speed", 1.0))))
	var unit := Combatant.new(
		character_id.to_lower(),
		str(profile.get("display_name", character_id)),
		int(profile.get("max_hp", 1)),
		int(profile.get("attack", 1)),
		defense_value,
		speed_value,
		int(profile.get("shield", 1)),
		profile.get("weaknesses", {}).duplicate(true),
		row
	)
	unit.mechanic_max = maxi(int(mechanic.get("max", 3)), 1)
	unit.mechanic_resource = 0
	return unit

static func _load_profiles() -> Dictionary:
	return _load_json(PROFILE_PATH).get("characters", {})

static func _load_mechanics() -> Dictionary:
	return _load_json(MECHANIC_PATH).get("mechanics", {})

static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
