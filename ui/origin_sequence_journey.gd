class_name OriginSequenceJourneyScreen
extends JourneyScreen

## Compatibility bridge: only migrated Origin chapters use EventSequence.
## All non-migrated Origin chapters continue through JourneyScreen's legacy path.

func _advance_primary() -> void:
	if event_session != null:
		super._advance_primary()
		return
	var start := narrative.state.starting_character
	var route := origin.get_route(start)
	if route.is_empty():
		super._advance_primary()
		return
	if narrative.state.route_progress.get(start, NarrativeState.ROUTE_LOCKED) == NarrativeState.ROUTE_COMPLETE:
		super._advance_primary()
		return
	if origin.is_complete(narrative, start):
		super._advance_primary()
		return
	var chapter := origin.get_current_chapter(narrative, start)
	if chapter.is_empty():
		super._advance_primary()
		return
	var chapter_id := str(chapter.get("id", ""))
	var sequence_id := "%s-SEQUENCE" % chapter_id
	if not EventSequenceManager.has_sequence(sequence_id):
		super._advance_primary()
		return
	event_session = NarrativeEventSession.new(EventSequenceManager.get_definition(sequence_id), narrative, "ORIGIN")
	_handle_event_action(event_session.start())

func _finish_event_session() -> void:
	if event_session != null and event_session.sequence != null:
		var definition := event_session.sequence.to_dict()
		var chapter_id := str(definition.get("chapter_id", ""))
		var has_battle := false
		for node in definition.get("nodes", []):
			if str(node.get("type", node.get("kind", ""))).to_lower() == EventRunner.BATTLE:
				has_battle = true
				break
		if not chapter_id.is_empty() and not has_battle:
			var start := narrative.state.starting_character
			var current := origin.get_current_chapter(narrative, start)
			if not current.is_empty() and str(current.get("id", "")) == chapter_id:
				var completed := narrative.complete_origin_chapter(start)
				if not completed.is_empty():
					event_session = null
					BountyEncounterState.clear()
					narrative.save()
					phase_label.text = "本段个人故事完成。"
					_refresh()
					return
	super._finish_event_session()
