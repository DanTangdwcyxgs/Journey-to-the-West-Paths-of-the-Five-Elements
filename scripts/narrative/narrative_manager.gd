class_name NarrativeManager
extends RefCounted

## Small deterministic coordinator for narrative state.
## Content data remains external; this class owns state transitions only.

signal route_unlocked(character_id: String)
signal character_recruited(character_id: String)
signal milestone_reached(milestone_id: String, chronological_index: int)
signal memory_completed(chapter_id: String)

var state := NarrativeState.new()

func start_new_game(character_id: String) -> void:
	state.initialize_for_start(character_id)

func encounter_character(character_id: String, memory_chapters: Array[String] = []) -> bool:
	var recruited_now := state.mark_recruited(character_id)
	if recruited_now:
		route_unlocked.emit(character_id)
		character_recruited.emit(character_id)
	if not memory_chapters.is_empty():
		state.add_memory_chapters(memory_chapters)
	return recruited_now

func advance_world_milestone(milestone_id: String, chronological_index: int) -> void:
	var previous := state.current_global_timeline
	state.record_milestone(milestone_id, chronological_index)
	if state.current_global_timeline != previous:
		milestone_reached.emit(milestone_id, state.current_global_timeline)

func can_enter_memory(chapter_id: String) -> bool:
	return chapter_id in state.available_memory_chapters

func finish_memory(chapter_id: String) -> bool:
	if not state.finish_memory_chapter(chapter_id):
		return false
	memory_completed.emit(chapter_id)
	return true

func party_full() -> bool:
	return state.recruited_characters.size() >= 5

func serialize() -> Dictionary:
	return state.to_dict()
