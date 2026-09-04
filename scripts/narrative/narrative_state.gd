class_name NarrativeState
extends RefCounted

## Runtime narrative state shared by route, memory, and chapter systems.
## World chronology is monotonic; character-history playback never rewinds it.

const ROUTE_LOCKED := "LOCKED"
const ROUTE_UNLOCKED := "UNLOCKED"
const ROUTE_IN_PROGRESS := "IN_PROGRESS"
const ROUTE_COMPLETE := "COMPLETE"

var starting_character: String = ""
var current_global_timeline: int = 0
var current_shared_chapter: String = ""

var completed_chapters: Array[String] = []
var completed_shared_chapters: Array[String] = []
var completed_milestones: Array[String] = []
var recruited_characters: Array[String] = []

var route_progress: Dictionary = {}
var unlocked_chapters: Array[String] = []
var available_memory_chapters: Array[String] = []
var played_memory_chapters: Array[String] = []
var relationship_values: Dictionary = {}

func initialize_for_start(character_id: String, initial_timeline: int = 0) -> void:
	starting_character = character_id
	current_global_timeline = initial_timeline
	current_shared_chapter = ""
	completed_chapters.clear()
	completed_shared_chapters.clear()
	completed_milestones.clear()
	recruited_characters.clear()
	unlocked_chapters.clear()
	available_memory_chapters.clear()
	played_memory_chapters.clear()
	relationship_values.clear()
	route_progress.clear()

	for id in ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA"]:
		route_progress[id] = ROUTE_LOCKED
	route_progress[character_id] = ROUTE_UNLOCKED

func unlock_route(character_id: String) -> bool:
	if not route_progress.has(character_id):
		route_progress[character_id] = ROUTE_LOCKED
	if route_progress[character_id] == ROUTE_LOCKED:
		route_progress[character_id] = ROUTE_UNLOCKED
		return true
	return false

func mark_recruited(character_id: String) -> bool:
	if character_id in recruited_characters:
		return false
	recruited_characters.append(character_id)
	unlock_route(character_id)
	return true

func record_milestone(milestone_id: String, chronological_index: int) -> void:
	if milestone_id not in completed_milestones:
		completed_milestones.append(milestone_id)
	current_global_timeline = max(current_global_timeline, chronological_index)

func add_memory_chapters(chapter_ids: Array[String]) -> void:
	for chapter_id in chapter_ids:
		if chapter_id not in available_memory_chapters and chapter_id not in played_memory_chapters:
			available_memory_chapters.append(chapter_id)

func finish_memory_chapter(chapter_id: String) -> bool:
	if chapter_id not in available_memory_chapters:
		return false
	available_memory_chapters.erase(chapter_id)
	played_memory_chapters.append(chapter_id)
	return true

func snapshot_shared_context() -> Dictionary:
	return {
		"current_global_timeline": current_global_timeline,
		"current_shared_chapter": current_shared_chapter,
		"completed_shared_chapters": completed_shared_chapters.duplicate(),
		"recruited_characters": recruited_characters.duplicate(),
	}

func to_dict() -> Dictionary:
	return {
		"starting_character": starting_character,
		"current_global_timeline": current_global_timeline,
		"current_shared_chapter": current_shared_chapter,
		"completed_chapters": completed_chapters.duplicate(),
		"completed_shared_chapters": completed_shared_chapters.duplicate(),
		"completed_milestones": completed_milestones.duplicate(),
		"recruited_characters": recruited_characters.duplicate(),
		"route_progress": route_progress.duplicate(true),
		"unlocked_chapters": unlocked_chapters.duplicate(),
		"available_memory_chapters": available_memory_chapters.duplicate(),
		"played_memory_chapters": played_memory_chapters.duplicate(),
		"relationship_values": relationship_values.duplicate(true),
	}
