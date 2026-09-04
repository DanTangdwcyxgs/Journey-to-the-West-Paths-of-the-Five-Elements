class_name NarrativeState
extends RefCounted

## Runtime narrative state shared by route, memory, chapter, party, and world systems.
## World chronology is monotonic; character-history playback never rewinds it.

const ROUTE_LOCKED := "LOCKED"
const ROUTE_UNLOCKED := "UNLOCKED"
const ROUTE_IN_PROGRESS := "IN_PROGRESS"
const ROUTE_COMPLETE := "COMPLETE"
const CHARACTER_IDS := ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA"]

var starting_character: String = ""
var current_origin_route: String = ""
var current_origin_chapter: String = ""
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
var party_formation: Dictionary = {"roster": [], "front_row": [], "back_row": []}
var journey_log: Dictionary = {"entries": [], "defeated_targets": [], "active_world_effects": []}
var inventory: Dictionary = {"currencies": {"COIN": 0}, "items": {}}

func initialize_for_start(character_id: String, initial_timeline: int = 0) -> void:
	if character_id not in CHARACTER_IDS:
		push_error("Unknown starting character: %s" % character_id)
		return
	starting_character = character_id
	current_origin_route = ""
	current_origin_chapter = ""
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
	party_formation = {"roster": [], "front_row": [], "back_row": []}
	journey_log = {"entries": [], "defeated_targets": [], "active_world_effects": []}
	inventory = {"currencies": {"COIN": 0}, "items": {}}
	route_progress.clear()
	for id in CHARACTER_IDS:
		route_progress[id] = ROUTE_LOCKED
	route_progress[character_id] = ROUTE_UNLOCKED

func set_origin_progress(route_id: String, chapter_id: String) -> void:
	current_origin_route = route_id
	current_origin_chapter = chapter_id

func clear_origin_progress() -> void:
	current_origin_route = ""
	current_origin_chapter = ""

func unlock_route(character_id: String) -> bool:
	if character_id not in CHARACTER_IDS:
		return false
	if not route_progress.has(character_id):
		route_progress[character_id] = ROUTE_LOCKED
	if route_progress[character_id] == ROUTE_LOCKED:
		route_progress[character_id] = ROUTE_UNLOCKED
		return true
	return false

func mark_recruited(character_id: String) -> bool:
	if character_id not in CHARACTER_IDS or character_id in recruited_characters:
		return false
	recruited_characters.append(character_id)
	unlock_route(character_id)
	return true

func mark_route_complete(character_id: String) -> bool:
	if character_id not in CHARACTER_IDS:
		return false
	route_progress[character_id] = ROUTE_COMPLETE
	if character_id == starting_character:
		clear_origin_progress()
	return true

func record_chapter_complete(chapter_id: String, is_shared: bool = false) -> void:
	if chapter_id == "":
		return
	if chapter_id not in completed_chapters:
		completed_chapters.append(chapter_id)
	if is_shared and chapter_id not in completed_shared_chapters:
		completed_shared_chapters.append(chapter_id)

func record_milestone(milestone_id: String, chronological_index: int) -> void:
	if milestone_id != "" and milestone_id not in completed_milestones:
		completed_milestones.append(milestone_id)
	current_global_timeline = max(current_global_timeline, chronological_index)

func set_current_shared_chapter(chapter_id: String) -> void:
	current_shared_chapter = chapter_id

func set_party_formation(formation: Dictionary) -> void:
	party_formation = {
		"roster": _string_array(formation.get("roster", [])),
		"front_row": _string_array(formation.get("front_row", [])),
		"back_row": _string_array(formation.get("back_row", [])),
	}

func get_party_formation() -> Dictionary:
	return party_formation.duplicate(true)

func set_journey_log(data: Dictionary) -> void:
	journey_log = {
		"entries": data.get("entries", []).duplicate(true),
		"defeated_targets": _string_array(data.get("defeated_targets", [])),
		"active_world_effects": _string_array(data.get("active_world_effects", [])),
	}

func get_journey_log() -> Dictionary:
	return journey_log.duplicate(true)

func set_inventory(data: Dictionary) -> void:
	inventory = {
		"currencies": data.get("currencies", {"COIN": 0}).duplicate(true),
		"items": data.get("items", {}).duplicate(true),
	}

func get_inventory() -> Dictionary:
	return inventory.duplicate(true)

func add_memory_chapters(chapter_ids: Array[String]) -> void:
	for chapter_id in chapter_ids:
		if chapter_id not in available_memory_chapters and chapter_id not in played_memory_chapters:
			available_memory_chapters.append(chapter_id)

func finish_memory_chapter(chapter_id: String) -> bool:
	if chapter_id not in available_memory_chapters:
		return false
	available_memory_chapters.erase(chapter_id)
	if chapter_id not in played_memory_chapters:
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
		"current_origin_route": current_origin_route,
		"current_origin_chapter": current_origin_chapter,
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
		"party_formation": party_formation.duplicate(true),
		"journey_log": journey_log.duplicate(true),
		"inventory": inventory.duplicate(true),
	}

static func from_dict(data: Dictionary) -> NarrativeState:
	var restored := NarrativeState.new()
	restored.starting_character = str(data.get("starting_character", ""))
	restored.current_origin_route = str(data.get("current_origin_route", ""))
	restored.current_origin_chapter = str(data.get("current_origin_chapter", ""))
	restored.current_global_timeline = int(data.get("current_global_timeline", 0))
	restored.current_shared_chapter = str(data.get("current_shared_chapter", ""))
	restored.completed_chapters = _string_array(data.get("completed_chapters", []))
	restored.completed_shared_chapters = _string_array(data.get("completed_shared_chapters", []))
	restored.completed_milestones = _string_array(data.get("completed_milestones", []))
	restored.recruited_characters = _string_array(data.get("recruited_characters", []))
	restored.unlocked_chapters = _string_array(data.get("unlocked_chapters", []))
	restored.available_memory_chapters = _string_array(data.get("available_memory_chapters", []))
	restored.played_memory_chapters = _string_array(data.get("played_memory_chapters", []))
	restored.route_progress = data.get("route_progress", {}).duplicate(true)
	restored.relationship_values = data.get("relationship_values", {}).duplicate(true)
	var raw_party: Dictionary = data.get("party_formation", {})
	restored.party_formation = {
		"roster": _string_array(raw_party.get("roster", [])),
		"front_row": _string_array(raw_party.get("front_row", [])),
		"back_row": _string_array(raw_party.get("back_row", [])),
	}
	var raw_log: Dictionary = data.get("journey_log", {})
	restored.journey_log = {
		"entries": raw_log.get("entries", []).duplicate(true),
		"defeated_targets": _string_array(raw_log.get("defeated_targets", [])),
		"active_world_effects": _string_array(raw_log.get("active_world_effects", [])),
	}
	var raw_inventory: Dictionary = data.get("inventory", {})
	restored.inventory = {
		"currencies": raw_inventory.get("currencies", {"COIN": 0}).duplicate(true),
		"items": raw_inventory.get("items", {}).duplicate(true),
	}
	for id in CHARACTER_IDS:
		if not restored.route_progress.has(id):
			restored.route_progress[id] = ROUTE_LOCKED
	return restored

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry in value:
			result.append(str(entry))
	return result
