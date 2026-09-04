class_name NarrativeManager
extends RefCounted

## Deterministic coordinator for narrative state transitions.
## Content data remains external; this class owns state mutation and persistence boundaries.

signal route_unlocked(character_id: String)
signal character_recruited(character_id: String)
signal milestone_reached(milestone_id: String, chronological_index: int)
signal chapter_completed(chapter_id: String)
signal memory_completed(chapter_id: String)
signal party_became_full()
signal world_effect_activated(effect_id: String)
signal battle_recorded(target_id: String, result: String)

var state := NarrativeState.new()
var origin_routes := OriginRouteManager.new()

func start_new_game(character_id: String) -> bool:
	if character_id not in NarrativeState.CHARACTER_IDS:
		return false
	state.initialize_for_start(character_id)
	return begin_origin_route(character_id)

func begin_origin_route(character_id: String) -> bool:
	if character_id not in NarrativeState.CHARACTER_IDS:
		return false
	if origin_routes.get_chapters(character_id).is_empty():
		return false
	if state.route_progress.get(character_id, NarrativeState.ROUTE_LOCKED) == NarrativeState.ROUTE_LOCKED:
		state.unlock_route(character_id)
	var chapter := origin_routes.get_current_chapter(self, character_id)
	if chapter.is_empty():
		state.mark_route_complete(character_id)
		return false
	var chapter_id := str(chapter.get("id", ""))
	state.set_origin_progress(str(origin_routes.get_route(character_id).get("route_id", "%s_ORIGIN" % character_id)), chapter_id)
	if chapter_id not in state.unlocked_chapters:
		state.unlocked_chapters.append(chapter_id)
	return true

func encounter_character(character_id: String, memory_chapters: Array[String] = []) -> bool:
	var recruited_now := state.mark_recruited(character_id)
	if not recruited_now:
		return false

	route_unlocked.emit(character_id)
	character_recruited.emit(character_id)
	# Personal history is unlocked immediately, never gated by PARTY_FULL.
	state.add_memory_chapters(memory_chapters)

	if party_full():
		party_became_full.emit()
	return true

func complete_chapter(chapter_id: String, is_shared: bool = false) -> bool:
	if chapter_id == "":
		return false
	var was_completed := chapter_id in state.completed_chapters
	state.record_chapter_complete(chapter_id, is_shared)
	if not was_completed:
		chapter_completed.emit(chapter_id)
	return not was_completed

func complete_origin_chapter(character_id: String) -> Dictionary:
	if character_id not in NarrativeState.CHARACTER_IDS:
		return {}
	var chapter := origin_routes.get_current_chapter(self, character_id)
	if chapter.is_empty():
		state.mark_route_complete(character_id)
		return {}
	var chapter_id := str(chapter.get("id", ""))
	complete_chapter(chapter_id, false)
	var next := origin_routes.get_current_chapter(self, character_id)
	if next.is_empty():
		state.mark_route_complete(character_id)
		state.clear_origin_progress()
		return chapter
	var next_id := str(next.get("id", ""))
	state.set_origin_progress(str(origin_routes.get_route(character_id).get("route_id", "%s_ORIGIN" % character_id)), next_id)
	if next_id not in state.unlocked_chapters:
		state.unlocked_chapters.append(next_id)
	return chapter

func get_origin_status(character_id: String) -> Dictionary:
	var route := origin_routes.get_route(character_id)
	var current := origin_routes.get_current_chapter(self, character_id)
	var total := origin_routes.get_chapters(character_id).size()
	return {
		"character_id": character_id,
		"route_id": str(route.get("route_id", "%s_ORIGIN" % character_id)),
		"state": str(state.route_progress.get(character_id, NarrativeState.ROUTE_LOCKED)),
		"current_chapter": str(current.get("id", "")),
		"completed_chapters": origin_routes.get_current_index(self, character_id),
		"total_chapters": total,
		"complete": origin_routes.is_complete(self, character_id),
	}

func advance_world_milestone(milestone_id: String, chronological_index: int) -> void:
	var previous := state.current_global_timeline
	state.record_milestone(milestone_id, chronological_index)
	if state.current_global_timeline != previous:
		milestone_reached.emit(milestone_id, state.current_global_timeline)

func set_shared_chapter(chapter_id: String) -> void:
	state.set_current_shared_chapter(chapter_id)

func can_enter_memory(chapter_id: String) -> bool:
	return chapter_id in state.available_memory_chapters

func begin_memory(chapter_id: String) -> Dictionary:
	if not can_enter_memory(chapter_id):
		return {}
	return state.snapshot_shared_context()

func finish_memory(chapter_id: String) -> bool:
	if not state.finish_memory_chapter(chapter_id):
		return false
	memory_completed.emit(chapter_id)
	return true

func party_full() -> bool:
	return state.recruited_characters.size() >= NarrativeState.CHARACTER_IDS.size()

func record_battle_result(target_id: String, target_name: String, result: String, rewards: Array = [], world_effects: Array = []) -> Dictionary:
	if target_id == "" or result == "":
		return {}
	var journal := JourneyLog.new()
	journal.restore(state.journey_log)
	var entry := journal.record_battle(target_id, target_name, result, rewards, world_effects)
	state.set_journey_log(journal.to_dict())
	for effect in world_effects:
		world_effect_activated.emit(str(effect))
	battle_recorded.emit(target_id, result)
	return entry

func record_bounty_defeat(target_id: String, target_name: String, rewards: Array = [], world_effects: Array = []) -> Dictionary:
	var entry := record_battle_result(target_id, target_name, "VICTORY", rewards, world_effects)
	if not entry.is_empty():
		advance_world_milestone("BOUNTY_%s_DEFEATED" % target_id, state.current_global_timeline)
	return entry

func serialize() -> Dictionary:
	return state.to_dict()

func save(path: String = NarrativeSave.SAVE_PATH) -> bool:
	return NarrativeSave.save_state(state, path)

func load(path: String = NarrativeSave.SAVE_PATH) -> bool:
	var restored := NarrativeSave.load_state(path)
	if restored == null:
		return false
	state = restored
	return true
