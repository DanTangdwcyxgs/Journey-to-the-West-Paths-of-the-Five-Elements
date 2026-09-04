class_name ChapterUnlocker
extends RefCounted

## Deterministic chapter availability evaluator.
## A chapter unlock never mutates NarrativeState.

func is_available(chapter: Dictionary, state: NarrativeState) -> bool:
	var chapter_type: String = str(chapter.get("chapter_type", ""))
	if chapter_type == "ORIGIN" or chapter_type == "PERSPECTIVE":
		return _is_route_available(chapter, state) and _passes_prerequisites(chapter, state)

	if chapter_type == "SHARED" or chapter_type == "RECRUITMENT" or chapter_type == "MAJOR_TRIAL" or chapter_type == "INTERLUDE" or chapter_type == "SIDE_STORY":
		if not _passes_timeline_gate(chapter, state):
			return false
		return _passes_prerequisites(chapter, state)

	return false

func _is_route_available(chapter: Dictionary, state: NarrativeState) -> bool:
	var character_id := str(chapter.get("character_id", ""))
	if character_id == "":
		return false
	var status = state.route_progress.get(character_id, NarrativeState.ROUTE_LOCKED)
	return status != NarrativeState.ROUTE_LOCKED

func _passes_timeline_gate(chapter: Dictionary, state: NarrativeState) -> bool:
	if not chapter.has("timeline_gate_index"):
		return true
	return state.current_global_timeline >= int(chapter["timeline_gate_index"])

func _passes_prerequisites(chapter: Dictionary, state: NarrativeState) -> bool:
	for prerequisite in chapter.get("prerequisites", []):
		if str(prerequisite) not in state.completed_chapters and str(prerequisite) not in state.completed_milestones:
			return false
	return true
