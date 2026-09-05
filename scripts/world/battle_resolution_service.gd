class_name BattleResolutionService
extends RefCounted

## Single commit boundary for a victorious narrative battle.
## Preflight happens before mutation; failures restore the pre-resolution snapshot.

static func resolve_narrative_victory(manager: NarrativeManager, encounter_type: String, encounter_id: String, source_stage_id: String, source_chapter_id: String, source_route_id: String, target_name: String, rewards: Array, world_effects: Array, encounter_manager: EncounterManager) -> Dictionary:
	if manager == null or encounter_manager == null or encounter_id == "":
		return {}
	var definition := encounter_manager.get_definition(encounter_id)
	if definition.is_empty() or not _validate_source(manager, encounter_type, source_chapter_id, source_route_id):
		return {}
	var snapshot := manager.serialize().duplicate(true)
	var reward_result := BattleRewardService.preview_rewards(manager.state.get_inventory(), rewards)
	if reward_result.is_empty():
		return {}
	manager.state.set_inventory(reward_result.get("inventory", {}))
	manager.record_battle_result(encounter_id, target_name, "VICTORY", rewards, world_effects)
	if encounter_type == "normal":
		if not source_stage_id.is_empty():
			manager.state.add_world_rumor("YELLOW_WIND_CAVE_ROOM_" + source_stage_id)
	elif encounter_type == "origin":
		var origin := OriginRouteManager.new()
		if origin.complete_current(manager, str(manager.state.starting_character)).is_empty():
			manager.restore_snapshot(snapshot)
			return {}
	elif encounter_type == "shared":
		manager.state.record_milestone("SHARED_BATTLE_%s" % encounter_id, manager.state.current_global_timeline)
		if not SharedJourneyManager.complete(source_chapter_id, manager, false):
			manager.restore_snapshot(snapshot)
			return {}
	if not manager.save():
		manager.restore_snapshot(snapshot)
		return {}
	return {"granted": reward_result.get("granted", []), "inventory": reward_result.get("inventory", {})}

static func _validate_source(manager: NarrativeManager, encounter_type: String, source_chapter_id: String, source_route_id: String) -> bool:
	if encounter_type == "origin":
		if source_chapter_id.is_empty() or source_route_id.is_empty():
			return false
		var origin := OriginRouteManager.new()
		var character_id := str(manager.state.starting_character)
		var route := origin.get_route(character_id)
		if str(route.get("route_id", "")) != source_route_id:
			return false
		var chapter := origin.get_current_chapter(manager, character_id)
		return str(chapter.get("id", "")) == source_chapter_id
	if encounter_type == "shared":
		if source_chapter_id.is_empty() or source_route_id != "SHARED_JOURNEY":
			return false
		var chapter := SharedJourneyManager.get_chapter(source_chapter_id)
		return not chapter.is_empty() and SharedJourneyManager.can_enter(source_chapter_id, manager.state)
	return true
