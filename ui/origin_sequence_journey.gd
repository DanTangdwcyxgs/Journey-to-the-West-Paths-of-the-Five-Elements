class_name OriginSequenceJourneyScreen
extends JourneyScreen

## Compatibility bridge: only migrated Origin chapters use EventSequence.
## All non-migrated Origin chapters continue through JourneyScreen's legacy path.

func _advance_primary() -> void:
	if memory_playback_session != null:
		super._advance_primary()
		return
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
				var state_before_completion: Dictionary = narrative.serialize().duplicate(true)
				var completed: Dictionary = narrative.complete_origin_chapter(start)
				if not completed.is_empty():
					var chapter_title := str(completed.get("title", chapter_id))
					var completion_notice := "个人章节完成 · %s" % chapter_title
					var next_chapter: Dictionary = origin.get_current_chapter(narrative, start)
					if next_chapter.is_empty():
						if not narrative.handoff_origin_to_shared(start):
							narrative.restore_snapshot(state_before_completion)
							_refresh()
							phase_label.text = "个人序章完成，但无法进入共享西游；进度已回滚，请再次确认重试。"
							return
						party.initialize_from_recruited(narrative.state.recruited_characters)
						var shared_chapter := SharedJourneyManager.get_chapter(narrative.state.current_shared_chapter)
						completion_notice += " · 已汇入共享西游"
						if not shared_chapter.is_empty():
							completion_notice += " · 下一章：" + str(shared_chapter.get("title", shared_chapter.get("id", "")))
					else:
						completion_notice += " · 下一章：" + str(next_chapter.get("title", next_chapter.get("id", "")))

					if not narrative.save():
						narrative.restore_snapshot(state_before_completion)
						_refresh()
						phase_label.text = "存档失败，章节进度已回滚；再次确认可重试。"
						return

					event_session = null
					var resume_context_cleared: bool = BountyEncounterState.clear_completed_event_session()
					_refresh()
					if not resume_context_cleared:
						completion_notice += " · 事件接续记录清理失败"
					phase_label.text = completion_notice
					return
	super._finish_event_session()
