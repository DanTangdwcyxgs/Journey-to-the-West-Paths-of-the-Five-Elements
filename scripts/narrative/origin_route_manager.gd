class_name OriginRouteManager
extends RefCounted

const DATA_PATH := "res://data/narrative/origin_chapters.json"

var definitions: Dictionary = {}

func _init() -> void:
	load_definitions()

func load_definitions() -> void:
	definitions.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		definitions = parsed.get("routes", {}).duplicate(true)

func get_route(character_id: String) -> Dictionary:
	return definitions.get(character_id, {}).duplicate(true)

func get_chapters(character_id: String) -> Array:
	return get_route(character_id).get("chapters", []).duplicate(true)

func get_current_index(manager: NarrativeManager, character_id: String) -> int:
	if manager == null:
		return 0
	var chapters := get_chapters(character_id)
	var index := 0
	for chapter in chapters:
		if str(chapter.get("id", "")) in manager.state.completed_chapters:
			index += 1
		else:
			break
	return index

func get_current_chapter(manager: NarrativeManager, character_id: String) -> Dictionary:
	var chapters := get_chapters(character_id)
	var index := get_current_index(manager, character_id)
	if index < 0 or index >= chapters.size():
		return {}
	return chapters[index].duplicate(true)

func is_complete(manager: NarrativeManager, character_id: String) -> bool:
	return get_current_index(manager, character_id) >= get_chapters(character_id).size()

func complete_current(manager: NarrativeManager, character_id: String) -> Dictionary:
	var chapter := get_current_chapter(manager, character_id)
	if manager == null or chapter.is_empty():
		return {}
	var chapter_id := str(chapter.get("id", ""))
	if chapter_id == "":
		return {}
	manager.complete_chapter(chapter_id, false)
	manager.state.set_origin_progress(str(get_route(character_id).get("route_id", "%s_ORIGIN" % character_id)), _next_chapter_id(manager, character_id))
	return chapter

func _next_chapter_id(manager: NarrativeManager, character_id: String) -> String:
	var next := get_current_chapter(manager, character_id)
	return str(next.get("id", "")) if not next.is_empty() else ""
