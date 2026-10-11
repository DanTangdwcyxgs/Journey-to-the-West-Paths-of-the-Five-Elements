class_name MemoryPlaybackSession
extends RefCounted

## Read-only playback of an unlocked Origin chapter.
## Only dialogue nodes are presented. Choices, combat, rewards and world actions are never executed.

var chapter_id: String = ""
var chapter_title: String = ""
var entries: Array[Dictionary] = []
var current_index: int = 0
var narrative_manager: NarrativeManager
var shared_context_snapshot: Dictionary = {}
var started: bool = false

func start(manager: NarrativeManager, requested_chapter_id: String) -> bool:
	if manager == null or not manager.can_enter_memory(requested_chapter_id):
		return false

	var chapter := _find_origin_chapter(manager, requested_chapter_id)
	if chapter.is_empty():
		return false

	narrative_manager = manager
	chapter_id = requested_chapter_id
	chapter_title = str(chapter.get("title", chapter_id))
	shared_context_snapshot = manager.begin_memory(chapter_id)
	if shared_context_snapshot.is_empty():
		return false

	var sequence_id := "%s-SEQUENCE" % chapter_id
	var definition: EventSequenceDefinition = EventSequenceManager.get_definition(sequence_id)
	if definition != null:
		var sequence_data: Dictionary = definition.to_dict()
		var namespace_id := str(sequence_data.get("namespace", "")).to_upper()
		var source_chapter_id := str(sequence_data.get("chapter_id", ""))
		if namespace_id == "ORIGIN" and source_chapter_id == chapter_id:
			entries = _collect_dialogue_entries(definition)

	if entries.is_empty():
		var summary := str(chapter.get("summary", "")).strip_edges()
		if not summary.is_empty():
			entries.append({
				"node_id": "chapter_summary",
				"speaker": "旁白",
				"text": summary,
			})

	if entries.is_empty():
		narrative_manager = null
		shared_context_snapshot.clear()
		return false

	current_index = 0
	started = true
	return true

func get_current_entry() -> Dictionary:
	if not started or current_index < 0 or current_index >= entries.size():
		return {}
	return entries[current_index].duplicate(true)

func get_total_entries() -> int:
	return entries.size()

func get_current_position() -> int:
	return current_index + 1 if not entries.is_empty() else 0

func is_last_entry() -> bool:
	return not entries.is_empty() and current_index >= entries.size() - 1

func advance() -> bool:
	if not started or is_last_entry():
		return false
	current_index += 1
	return true

func shared_context_unchanged() -> bool:
	return narrative_manager != null and narrative_manager.state.snapshot_shared_context() == shared_context_snapshot

func _find_origin_chapter(manager: NarrativeManager, requested_chapter_id: String) -> Dictionary:
	for character_id in NarrativeState.CHARACTER_IDS:
		var chapters: Array = manager.origin_routes.get_chapters(str(character_id))
		for chapter_variant in chapters:
			if chapter_variant is Dictionary and str(chapter_variant.get("id", "")) == requested_chapter_id:
				return chapter_variant.duplicate(true)
	return {}

func _collect_dialogue_entries(definition: EventSequenceDefinition) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var cursor := definition.get_start_node_id()
	var visited: Dictionary = {}
	var guard_limit: int = definition.get_nodes().size() + 1
	var guard := 0

	while not cursor.is_empty() and guard < guard_limit:
		guard += 1
		if visited.has(cursor):
			break
		visited[cursor] = true
		var node: Dictionary = definition.get_node(cursor)
		if node.is_empty():
			break

		var kind := str(node.get("type", node.get("kind", ""))).to_lower()
		if kind == EventRunner.DIALOGUE:
			var dialogue_text := str(node.get("text", "")).strip_edges()
			if not dialogue_text.is_empty():
				result.append({
					"node_id": str(node.get("id", "")),
					"speaker": str(node.get("speaker", "旁白")),
					"text": dialogue_text,
				})
		if kind == EventRunner.END:
			break
		cursor = _next_read_only_node(node, kind)

	return result

func _next_read_only_node(node: Dictionary, kind: String) -> String:
	if kind == EventRunner.JUMP:
		var jump_target := str(node.get("target", node.get("next", "")))
		if not jump_target.is_empty():
			return jump_target

	var next_id := str(node.get("next", ""))
	if not next_id.is_empty():
		return next_id

	var next_map: Dictionary = node.get("next_map", {})
	if not next_map.is_empty():
		var keys: Array = next_map.keys()
		keys.sort()
		return str(next_map[keys[0]])
	return ""
