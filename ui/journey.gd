class_name JourneyScreen
extends Control

const CHARACTER_NAMES := {"TANG":"唐三藏", "WUKONG":"孙悟空", "BAJIE":"猪八戒", "WUJING":"沙悟净", "LONGMA":"白龙马"}
const DIALOGUE_CHARS_PER_SECOND := 42.0
const EVENT_TRANSITION_DELAY := 0.28

var narrative := NarrativeManager.new()
var origin := OriginRouteManager.new()
var origin_events := OriginEventManager.new()
var shared_events := SharedEventManager.new()
var party := PartyManager.new()
var event_session: NarrativeEventSession
var memory_playback_session: MemoryPlaybackSession
var memory_playback_state_snapshot: Dictionary = {}
var title_label: Label
var phase_label: Label
var chapter_label: Label
var description_label: Label
var dialogue_panel: PanelContainer
var speaker_label: Label
var dialogue_text_label: Label
var dialogue_hint_label: Label
var event_meta_label: Label
var list: ItemList
var primary_button: Button
var choice_box: VBoxContainer
var memory_button: Button
var party_button: Button
var world_button: Button
var save_button: Button
var back_button: Button
var dialogue_full_text := ""
var dialogue_visible_characters := 0
var dialogue_revealing := false
var dialogue_speed_accumulator := 0.0
var event_transition_pending := false

const GOLD := Color("d5ad57")
const PAPER := Color("ead9aa")
const MUTED := Color("a79d89")
const PANEL := Color(0.035, 0.032, 0.040, 0.84)

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	party.initialize_from_saved_state(narrative.state.recruited_characters, narrative.state.get_party_formation())
	_restore_event_session()
	_build_ui()
	_refresh()

func _process(delta: float) -> void:
	if not dialogue_revealing:
		return
	dialogue_speed_accumulator += delta * DIALOGUE_CHARS_PER_SECOND
	var target: int = min(dialogue_full_text.length(), dialogue_visible_characters + int(dialogue_speed_accumulator))
	if target > dialogue_visible_characters:
		var added: int = target - dialogue_visible_characters
		dialogue_visible_characters = target
		dialogue_speed_accumulator -= float(added)
		if dialogue_text_label != null:
			dialogue_text_label.text = dialogue_full_text.left(dialogue_visible_characters)
	if dialogue_visible_characters >= dialogue_full_text.length():
		dialogue_revealing = false
		dialogue_speed_accumulator = 0.0
		if dialogue_hint_label != null:
			dialogue_hint_label.text = "SPACE / ENTER · 继续"

func _panel(parent: Node, min_size := Vector2.ZERO) -> PanelContainer:
	var panel := PanelContainer.new()
	if min_size != Vector2.ZERO:
		panel.custom_minimum_size = min_size
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color(GOLD, 0.34)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _label(text: String, size: int, color := PAPER) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.modulate = color
	return node

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.018, 0.025, 0.18)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)
	var header_left := VBoxContainer.new()
	header_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_left)
	title_label = _label("西游", 28)
	header_left.add_child(title_label)
	phase_label = _label("", 13, MUTED)
	header_left.add_child(phase_label)
	chapter_label = _label("", 20)
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(chapter_label)

	var sidebar_title := _label("章节进度 / 可回忆", 12, MUTED)
	root.add_child(sidebar_title)
	list = ItemList.new()
	list.name = "JourneyChapterMemoryList"
	list.custom_minimum_size = Vector2(0, 88)
	list.item_selected.connect(_on_sidebar_item_selected)
	root.add_child(list)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 78)
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	var dialogue_wrap := MarginContainer.new()
	dialogue_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_wrap.add_theme_constant_override("margin_left", 150)
	dialogue_wrap.add_theme_constant_override("margin_right", 150)
	dialogue_wrap.add_theme_constant_override("margin_bottom", 0)
	root.add_child(dialogue_wrap)

	dialogue_panel = _panel(dialogue_wrap, Vector2(0, 238))
	dialogue_panel.name = "DialoguePanel"
	var dialogue_root := VBoxContainer.new()
	dialogue_root.add_theme_constant_override("separation", 8)
	dialogue_panel.add_child(dialogue_root)

	speaker_label = _label("", 18, Color("f0c66a"))
	speaker_label.name = "Speaker"
	dialogue_root.add_child(speaker_label)

	dialogue_text_label = _label("", 20)
	dialogue_text_label.name = "Text"
	dialogue_text_label.custom_minimum_size = Vector2(0, 105)
	dialogue_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	dialogue_root.add_child(dialogue_text_label)

	choice_box = VBoxContainer.new()
	choice_box.name = "EventChoices"
	choice_box.add_theme_constant_override("separation", 6)
	dialogue_root.add_child(choice_box)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", 8)
	dialogue_root.add_child(action_row)

	memory_button = Button.new()
	memory_button.text = "播放回忆"
	memory_button.disabled = true
	memory_button.custom_minimum_size = Vector2(90, 36)
	memory_button.pressed.connect(_play_selected_memory)
	action_row.add_child(memory_button)

	party_button = Button.new()
	party_button.text = "队伍"
	party_button.custom_minimum_size = Vector2(90, 36)
	party_button.pressed.connect(_open_party)
	action_row.add_child(party_button)

	world_button = Button.new()
	world_button.text = "地图"
	world_button.custom_minimum_size = Vector2(90, 36)
	world_button.pressed.connect(_open_world_map)
	action_row.add_child(world_button)

	primary_button = Button.new()
	primary_button.text = "继续"
	primary_button.custom_minimum_size = Vector2(150, 40)
	primary_button.pressed.connect(_advance_primary)
	action_row.add_child(primary_button)

	dialogue_hint_label = _label("", 12, MUTED)
	dialogue_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	dialogue_root.add_child(dialogue_hint_label)

	event_meta_label = _label("", 11, Color("777163"))
	event_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dialogue_root.add_child(event_meta_label)

	var utility := HBoxContainer.new()
	utility.add_theme_constant_override("separation", 8)
	root.add_child(utility)
	save_button = Button.new()
	save_button.text = "保存"
	save_button.custom_minimum_size = Vector2(76, 30)
	save_button.pressed.connect(_save)
	utility.add_child(save_button)
	back_button = Button.new()
	back_button.text = "返回"
	back_button.custom_minimum_size = Vector2(76, 30)
	back_button.pressed.connect(_back_to_menu)
	utility.add_child(back_button)
	var route_status := _label("个人序章 → 共享西游", 12, MUTED)
	route_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	utility.add_child(route_status)

func _restore_event_session() -> void:
	var record := BountyEncounterState.get_active_record()
	if not record.has("event_resume"):
		return
	event_session = NarrativeEventSession.resume_from_battle_record(record, narrative)

func _current_route() -> Array:
	return origin.get_chapters(narrative.state.starting_character)

func _advance_primary() -> void:
	if memory_playback_session != null:
		_advance_memory_playback()
		return
	if event_session != null:
		_advance_event_session()
		return
	var start := narrative.state.starting_character
	var route := origin.get_route(start)
	if route.is_empty():
		return
	if narrative.state.route_progress.get(start, NarrativeState.ROUTE_LOCKED) == NarrativeState.ROUTE_COMPLETE:
		_advance_shared()
		return
	if origin.is_complete(narrative, start):
		_finish_origin()
		return
	var chapter := origin.get_current_chapter(narrative, start)
	if chapter.is_empty():
		return
	var chapter_id := str(chapter.get("id", ""))
	var event := origin_events.get_event(chapter_id)
	if not event.is_empty() and narrative.state.get_origin_choice(chapter_id) == "":
		phase_label.text = "请选择你的行动。"
		return
	var encounter_id := str(chapter.get("encounter_id", ""))
	if not encounter_id.is_empty():
		var route_id := str(route.get("route_id", "%s_ORIGIN" % start))
		if BountyEncounterState.start_narrative_encounter(encounter_id, chapter_id, route_id):
			get_tree().change_scene_to_file("res://ui/battle_ui.tscn")
		return
	var completed := narrative.complete_origin_chapter(start)
	if completed.is_empty():
		return
	narrative.save()
	_refresh()

func _advance_event_session() -> void:
	if event_session == null:
		return
	var action := event_session.get_action()
	match str(action.get("kind", "")):
		EventRunner.DIALOGUE:
			if dialogue_revealing:
				_reveal_dialogue_immediately()
				return
			var next := event_session.complete_action()
			_handle_event_action(next)
		EventRunner.WAIT, EventRunner.MOVE:
			_start_event_transition(action)
		EventRunner.REWARD, EventRunner.JUMP:
			var next := event_session.complete_action()
			_handle_event_action(next)
		EventRunner.BATTLE:
			_handle_event_action(action)
		EventRunner.END:
			_finish_event_session()
		_:
			phase_label.text = "当前剧情需要选择或完成战斗。"

func _start_event_transition(action: Dictionary) -> void:
	if event_transition_pending:
		return
	event_transition_pending = true
	primary_button.disabled = true
	var kind := str(action.get("kind", ""))
	var seconds: float = maxf(float(action.get("seconds", 0.0)), EVENT_TRANSITION_DELAY)
	if kind == EventRunner.MOVE:
		phase_label.text = "旅途移动中"
		_set_dialogue("旁白", "队伍正沿着新的路标继续前行。抵达后，旅途记录将会更新。", false)
		primary_button.text = "行进中…"
		dialogue_hint_label.text = "路途过渡中…"
	else:
		phase_label.text = "停驻片刻 · %.1f 秒" % seconds
		_set_dialogue("旁白", "队伍暂时停下脚步，片刻后继续前行。", false)
		primary_button.text = "稍候…"
		dialogue_hint_label.text = "停驻中…"
	await get_tree().create_timer(seconds).timeout
	event_transition_pending = false
	if event_session == null:
		return

	if kind == EventRunner.MOVE:
		var state_before_move: Dictionary = narrative.serialize().duplicate(true)
		var movement_result := WorldActionService.apply_move(narrative, action)
		if movement_result.is_empty():
			primary_button.disabled = false
			primary_button.text = "重试移动"
			phase_label.text = "路途位置无效，未更新探索记录；可以重试。"
			return
		if not narrative.save():
			narrative.restore_snapshot(state_before_move)
			primary_button.disabled = false
			primary_button.text = "重试移动"
			phase_label.text = "保存失败，抵达记录已回滚；再次确认可重试。"
			return

	var next := event_session.complete_action()
	_handle_event_action(next)

func _handle_event_action(action: Dictionary) -> void:
	if action.is_empty():
		phase_label.text = "剧情运行失败：%s" % event_session.runner.get_error()
		return
	if action.get("kind", "") == EventRunner.BATTLE:
		var record := event_session.start_battle_handoff()
		if record.is_empty():
			phase_label.text = "战斗接管失败。"
			return
		if BountyEncounterState.start_encounter(
			str(record.get("encounter_type", "shared")),
			str(record.get("encounter_id", "")),
			str(record.get("source_stage_id", "")),
			str(record.get("source_chapter_id", "")),
			str(record.get("source_route_id", "SHARED_JOURNEY")),
			{"event_resume": record.get("event_resume", {})}
		):
			get_tree().change_scene_to_file("res://ui/battle_ui.tscn")
		return
	_refresh()

func _submit_event_choice(choice_id: String) -> void:
	if event_session == null:
		return
	var action := event_session.submit_choice(choice_id)
	if action.is_empty():
		phase_label.text = "选择无法执行：%s" % event_session.runner.get_error()
		return
	if narrative.save():
		_handle_event_action(action)
	else:
		phase_label.text = "选择已执行，但保存失败。"

func _apply_choice(choice_id: String) -> void:
	var start := narrative.state.starting_character
	var chapter := origin.get_current_chapter(narrative, start)
	if chapter.is_empty():
		return
	var chapter_id := str(chapter.get("id", ""))
	if origin_events.apply_choice(narrative, chapter_id, choice_id):
		narrative.save()
		phase_label.text = "已记录选择。"
		_refresh()

func _finish_origin() -> void:
	var start := narrative.state.starting_character
	if not narrative.handoff_origin_to_shared(start):
		phase_label.text = "路线尚未完成，无法汇入共享西游。"
		return
	party.initialize_from_recruited(narrative.state.recruited_characters)
	narrative.save()
	_refresh()

func _advance_shared() -> void:
	var chapter_id := narrative.state.current_shared_chapter
	var sequence_id := "%s-SEQUENCE" % chapter_id
	if EventSequenceManager.has_sequence(sequence_id):
		if event_session == null:
			event_session = NarrativeEventSession.new(EventSequenceManager.get_definition(sequence_id), narrative, "SHARED")
			_handle_event_action(event_session.start())
		else:
			_advance_event_session()
		return

	var chapter := SharedJourneyManager.get_chapter(chapter_id)
	if chapter.is_empty():
		phase_label.text = "共享旅程已完成。"
		_refresh()
		return
	var event_id := str(chapter.get("event", ""))
	var event := shared_events.get_event(event_id if event_id != "" else chapter_id)
	var selected := shared_events.get_choice(narrative, event_id if event_id != "" else chapter_id)
	if not event.is_empty() and selected == "":
		phase_label.text = "共享章节需要先完成剧情选择。"
		_refresh()
		return
	var encounter_id := str(chapter.get("encounter_id", ""))
	if encounter_id != "":
		var source_id := "shared:%s" % chapter_id
		if BountyEncounterState.start_narrative_encounter(encounter_id, source_id, "SHARED_JOURNEY"):
			get_tree().change_scene_to_file("res://ui/battle_ui.tscn")
		return
	var recruit_before := narrative.state.recruited_characters.duplicate()
	if not SharedJourneyManager.complete(chapter_id, narrative):
		phase_label.text = "当前共享章节暂不可推进，需要先完成前置招募。"
		return
	party.initialize_from_saved_state(narrative.state.recruited_characters, narrative.state.get_party_formation())
	var recruited_names: Array[String] = []
	for id in narrative.state.recruited_characters:
		if id not in recruit_before:
			recruited_names.append(CHARACTER_NAMES.get(id, id))
	_refresh()
	if not recruited_names.is_empty():
		phase_label.text = "完成 %s · 新加入：%s" % [str(chapter.get("title", chapter_id)), "、".join(recruited_names)]

func _apply_shared_choice(choice_id: String) -> void:
	var chapter_id := narrative.state.current_shared_chapter
	var chapter := SharedJourneyManager.get_chapter(chapter_id)
	if chapter.is_empty():
		return
	var event_id := str(chapter.get("event", ""))
	if event_id == "":
		event_id = chapter_id
	if shared_events.apply_choice(narrative, event_id, choice_id):
		narrative.save()
		phase_label.text = "已记录本章选择。"
		_refresh()

func _memory_preview(character_id: String) -> Array[String]:
	var chapters := origin.get_chapters(character_id)
	var result: Array[String] = []
	for i in range(min(2, chapters.size())):
		result.append(str(chapters[i].get("id", "")))
	return result

func _on_sidebar_item_selected(index: int) -> void:
	if memory_playback_session != null or memory_button == null or list == null:
		return
	var row := list.get_item_text(index)
	var is_memory := not _memory_id_from_row(row).is_empty()
	memory_button.disabled = not is_memory
	memory_button.text = "播放回忆" if is_memory else "回忆"

func _memory_id_from_row(row: String) -> String:
	var prefix := "回忆 · "
	if not row.begins_with(prefix):
		return ""
	var memory_id := row.substr(prefix.length()).strip_edges()
	var title_separator := memory_id.find(" · ")
	if title_separator >= 0:
		memory_id = memory_id.substr(0, title_separator).strip_edges()
	return memory_id

func _play_selected_memory() -> void:
	if memory_playback_session != null or list == null:
		return
	var selected := list.get_selected_items()
	if selected.is_empty():
		return
	var memory_id := _memory_id_from_row(list.get_item_text(selected[0]))
	if memory_id.is_empty() or not narrative.can_enter_memory(memory_id):
		return

	var starting_snapshot := narrative.serialize().duplicate(true)
	var playback := MemoryPlaybackSession.new()
	if not playback.start(narrative, memory_id):
		phase_label.text = "这段回忆暂时无法打开。"
		return

	memory_playback_state_snapshot = starting_snapshot
	memory_playback_session = playback
	_clear_choices()
	_set_memory_playback_controls(true)
	_render_memory_playback_entry()

func _set_memory_playback_controls(playing: bool) -> void:
	if memory_button != null:
		memory_button.disabled = playing
	_set_event_navigation_locked(playing)
	if primary_button != null:
		primary_button.disabled = false

func _set_event_navigation_locked(locked: bool) -> void:
	for button in [party_button, world_button, save_button, back_button]:
		if button != null:
			button.disabled = locked

func _render_memory_playback_entry() -> void:
	if memory_playback_session == null:
		return
	var entry := memory_playback_session.get_current_entry()
	if entry.is_empty():
		phase_label.text = "回忆内容为空，无法继续。"
		return
	phase_label.text = "人物回忆 · %s · %d/%d" % [
		memory_playback_session.chapter_title,
		memory_playback_session.get_current_position(),
		memory_playback_session.get_total_entries(),
	]
	chapter_label.text = "回忆 · %s" % memory_playback_session.chapter_id
	event_meta_label.text = "历史回放 · 不执行选择、战斗或奖励"
	_set_dialogue(str(entry.get("speaker", "旁白")), str(entry.get("text", "")))
	primary_button.text = "完成回忆" if memory_playback_session.is_last_entry() else "继续回忆"
	primary_button.disabled = false

func _advance_memory_playback() -> void:
	if memory_playback_session == null:
		return
	if dialogue_revealing:
		_reveal_dialogue_immediately()
		return
	if not memory_playback_session.is_last_entry():
		if memory_playback_session.advance():
			_render_memory_playback_entry()
		return
	_finish_memory_playback()

func _finish_memory_playback() -> void:
	if memory_playback_session == null:
		return
	if not memory_playback_session.shared_context_unchanged():
		var changed_title := memory_playback_session.chapter_title
		memory_playback_session = null
		memory_playback_state_snapshot.clear()
		_set_memory_playback_controls(false)
		_refresh()
		phase_label.text = "回忆期间西游状态发生变化，未记录本次回放：%s" % changed_title
		return

	var chapter_id := memory_playback_session.chapter_id
	var chapter_title := memory_playback_session.chapter_title
	if not narrative.finish_memory(chapter_id):
		phase_label.text = "这段回忆已不在可回忆列表中。"
		return
	if not narrative.save():
		narrative.restore_snapshot(memory_playback_state_snapshot)
		phase_label.text = "保存失败，回忆尚未完成；再按一次重试。"
		primary_button.text = "重试保存"
		return

	memory_playback_session = null
	memory_playback_state_snapshot.clear()
	_set_memory_playback_controls(false)
	_refresh()
	phase_label.text = "回忆完成 · %s · 西游进度未改变" % chapter_title

func _open_party() -> void:
	get_tree().change_scene_to_file("res://ui/party_screen.tscn")

func _open_world_map() -> void:
	get_tree().change_scene_to_file("res://ui/world_map.tscn")

func _save() -> void:
	narrative.state.set_party_formation(party.to_dict())
	if narrative.save():
		phase_label.text = "已保存。"
	else:
		phase_label.text = "保存失败。"

func _back_to_menu() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _finish_event_session() -> void:
	var sequence_chapter_id := ""
	var sequence_namespace := ""
	var sequence_has_battle := false
	if event_session != null and event_session.sequence != null:
		var definition := event_session.sequence.to_dict()
		sequence_chapter_id = str(definition.get("chapter_id", ""))
		sequence_namespace = event_session.namespace_id
		for node in definition.get("nodes", []):
			if str(node.get("type", node.get("kind", ""))).to_lower() == EventRunner.BATTLE:
				sequence_has_battle = true
				break

	var completion_notice := "本段剧情完成。"
	if not sequence_chapter_id.is_empty():
		var chapter_title := _sequence_chapter_title(sequence_chapter_id, sequence_namespace)
		if sequence_namespace == "SHARED":
			if not sequence_has_battle and narrative.state.current_shared_chapter == sequence_chapter_id:
				if SharedJourneyManager.complete(sequence_chapter_id, narrative, false):
					party.initialize_from_saved_state(narrative.state.recruited_characters, narrative.state.get_party_formation())
					completion_notice = "章节完成 · %s" % chapter_title
				else:
					completion_notice = "章节推进未确认 · %s" % chapter_title
			elif sequence_has_battle:
				if sequence_chapter_id in narrative.state.completed_shared_chapters:
					completion_notice = "战后剧情完成 · %s 已结算" % chapter_title
				else:
					completion_notice = "战后剧情结束 · %s" % chapter_title
			else:
				completion_notice = "剧情片段完成 · %s" % chapter_title

			var next_shared_id := narrative.state.current_shared_chapter
			if not next_shared_id.is_empty() and next_shared_id != sequence_chapter_id:
				var next_shared_chapter: Dictionary = SharedJourneyManager.get_chapter(next_shared_id)
				if not next_shared_chapter.is_empty():
					completion_notice += " · 下一章：" + str(next_shared_chapter.get("title", next_shared_id))
			elif sequence_chapter_id in narrative.state.completed_shared_chapters:
				var completed_definition: ChapterDefinition = SharedJourneyManager.get_definition(sequence_chapter_id)
				if ChapterRuntime.next_id(completed_definition).is_empty():
					completion_notice += " · 当前共享章节链已完成"
		elif sequence_namespace == "ORIGIN" and sequence_has_battle:
			completion_notice = "战后剧情完成 · %s" % chapter_title
			var next_origin_chapter: Dictionary = origin.get_current_chapter(narrative, narrative.state.starting_character)
			if not next_origin_chapter.is_empty() and str(next_origin_chapter.get("id", "")) != sequence_chapter_id:
				completion_notice += " · 下一章：" + str(next_origin_chapter.get("title", next_origin_chapter.get("id", "")))

	event_session = null
	var resume_context_cleared: bool = BountyEncounterState.clear_completed_event_session()
	var save_succeeded: bool = narrative.save()
	_refresh()
	if not resume_context_cleared:
		completion_notice += " · 事件接续记录清理失败"
	phase_label.text = completion_notice if save_succeeded else completion_notice + " · 存档失败"

func _sequence_chapter_title(chapter_id: String, namespace_id: String) -> String:
	if namespace_id == "SHARED":
		var shared_chapter: Dictionary = SharedJourneyManager.get_chapter(chapter_id)
		if not shared_chapter.is_empty():
			return str(shared_chapter.get("title", chapter_id))
	for chapter in origin.get_chapters(narrative.state.starting_character):
		if str(chapter.get("id", "")) == chapter_id:
			return str(chapter.get("title", chapter_id))
	return chapter_id

func _refresh() -> void:
	if title_label == null:
		return
	var start := narrative.state.starting_character
	title_label.text = "西游 · %s" % CHARACTER_NAMES.get(start, start)
	_clear_choices()
	if event_session != null:
		_render_event_action(event_session.get_action())
	else:
		_render_route_or_shared()
	_refresh_sidebar()

func _refresh_sidebar() -> void:
	if list == null:
		return
	list.clear()
	if memory_button != null:
		memory_button.disabled = true
		memory_button.text = "播放回忆"
	for chapter in _current_route():
		var id := str(chapter.get("id", ""))
		var chapter_title := str(chapter.get("title", ""))
		var marker := "✓" if id in narrative.state.completed_chapters else "·"
		list.add_item("%s  %s" % [marker, chapter_title])
	for memory_id in narrative.state.available_memory_chapters:
		list.add_item("回忆 · %s" % memory_id)

func _render_event_action(action: Dictionary) -> void:
	_set_event_navigation_locked(true)
	if memory_button != null:
		memory_button.disabled = true
	if action.is_empty():
		chapter_label.text = "剧情运行失败"
		_set_dialogue("", event_session.runner.get_error() if event_session != null else "未知错误", false)
		primary_button.disabled = true
		return
	var kind := str(action.get("kind", ""))
	chapter_label.text = str(action.get("node_id", ""))
	event_meta_label.text = "序列 %s · 节点 %s" % [str(action.get("sequence_id", "")), str(action.get("node_id", ""))]
	match kind:
		EventRunner.DIALOGUE:
			phase_label.text = "剧情对话"
			_set_dialogue(str(action.get("speaker", "")), str(action.get("text", "")))
			primary_button.text = "继续"
			primary_button.disabled = false
		EventRunner.CHOICE:
			phase_label.text = "选择"
			_set_dialogue("", "%s\n\n%s" % [str(action.get("title", "")), str(action.get("text", ""))], false)
			primary_button.text = "请选择"
			primary_button.disabled = true
			_render_event_choices(action)
		EventRunner.MOVE:
			phase_label.text = "旅途移动"
			_set_dialogue("旁白", _describe_move_action(action), false)
			primary_button.text = "前往"
			primary_button.disabled = false
			dialogue_hint_label.text = "点击前往 · 将短暂呈现旅途过渡"
		EventRunner.WAIT:
			var seconds: float = maxf(float(action.get("seconds", 0.0)), EVENT_TRANSITION_DELAY)
			phase_label.text = "停驻片刻 · %.1f 秒" % seconds
			_set_dialogue("旁白", "队伍暂时停下脚步，片刻后继续前行。", false)
			primary_button.text = "继续"
			primary_button.disabled = false
			dialogue_hint_label.text = "点击继续 · 稍作停留后恢复剧情"
		EventRunner.BATTLE:
			phase_label.text = "战斗"
			_set_dialogue("", "战斗即将开始。完成后会回到这一段剧情。", false)
			primary_button.text = "进入战斗"
			primary_button.disabled = false
		EventRunner.END:
			phase_label.text = "剧情终点 · 等待确认"
			_set_dialogue("", "这一段故事已经走完。确认后会记录章节进度，并返回旅途。", false)
			primary_button.text = "完成并继续"
			primary_button.disabled = false
			dialogue_hint_label.text = "确认结束本段剧情 · 完成记录由旅途统一处理"
		_:
			phase_label.text = "剧情进行中"
			_set_dialogue("", str(action), false)
			primary_button.text = "继续"
			primary_button.disabled = false

func _describe_move_action(action: Dictionary) -> String:
	var map_id := str(action.get("map_id", "")).strip_edges()
	var marker_id := str(action.get("marker_id", "")).strip_edges()
	var description := "队伍准备离开当前地点，沿着新的路线继续前行。"
	if not map_id.is_empty():
		description += "\n目标地图：" + map_id
	if not marker_id.is_empty():
		description += "\n目标路标：" + marker_id
	return description

func _set_dialogue(speaker: String, text: String, typewriter := true) -> void:
	if speaker_label == null or dialogue_text_label == null:
		return
	speaker_label.text = speaker
	dialogue_full_text = text
	dialogue_visible_characters = 0
	dialogue_speed_accumulator = 0.0
	dialogue_revealing = typewriter and not text.is_empty()
	dialogue_text_label.text = "" if dialogue_revealing else text
	dialogue_hint_label.text = "正在阅读… · 再按一次显示全文" if dialogue_revealing else ""

func _reveal_dialogue_immediately() -> void:
	dialogue_visible_characters = dialogue_full_text.length()
	dialogue_text_label.text = dialogue_full_text
	dialogue_revealing = false
	dialogue_speed_accumulator = 0.0
	dialogue_hint_label.text = "SPACE / ENTER · 继续"

func _render_event_choices(action: Dictionary) -> void:
	for choice in action.get("choices", []):
		var choice_id := str(choice.get("id", ""))
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 42)
		button.text = str(choice.get("label", choice_id))
		button.pressed.connect(_submit_event_choice.bind(choice_id))
		choice_box.add_child(button)

func _render_route_or_shared() -> void:
	_set_event_navigation_locked(false)
	if narrative.state.route_progress.get(narrative.state.starting_character, NarrativeState.ROUTE_LOCKED) == NarrativeState.ROUTE_COMPLETE:
		phase_label.text = "共享旅途 · 队伍 %d/5" % party.roster.size()
		var chapter := SharedJourneyManager.get_chapter(narrative.state.current_shared_chapter)
		if chapter.is_empty():
			chapter_label.text = "共享旅程已完成"
			_set_dialogue("", "当前共享章节链已经走完。", false)
			primary_button.text = "已完成"
			primary_button.disabled = true
		else:
			chapter_label.text = "%s · %s" % [chapter.get("id", ""), chapter.get("title", "")]
			var event_id := str(chapter.get("event", ""))
			var event := shared_events.get_event(event_id if event_id != "" else str(chapter.get("id", "")))
			var chosen := shared_events.get_choice(narrative, event_id if event_id != "" else str(chapter.get("id", "")))
			if not event.is_empty() and chosen == "":
				_set_dialogue("", "%s\n\n%s" % [str(event.get("title", "选择")), str(event.get("text", ""))], false)
				primary_button.text = "请选择"
				primary_button.disabled = true
				_render_shared_choices(event)
			else:
				_set_dialogue("旁白", str(chapter.get("summary", "")), false)
				primary_button.text = "进入共享战斗" if not str(chapter.get("encounter_id", "")).is_empty() else "继续"
				primary_button.disabled = false
	else:
		var chapters := _current_route()
		var index := origin.get_current_index(narrative, narrative.state.starting_character)
		if index >= chapters.size():
			chapter_label.text = "路线汇合"
			_set_dialogue("旁白", "个人历史结束。下一步会将起始角色接回固定西游主线。", false)
			primary_button.text = "进入共享主线"
			primary_button.disabled = false
		else:
			var chapter: Dictionary = chapters[index]
			var chapter_id := str(chapter.get("id", ""))
			var event := origin_events.get_event(chapter_id)
			var chosen := narrative.state.get_origin_choice(chapter_id)
			chapter_label.text = "%s · %s" % [chapter.get("id", ""), chapter.get("title", "")]
			if not event.is_empty() and chosen == "":
				_set_dialogue("旁白", "%s\n\n%s" % [str(chapter.get("summary", "")), str(event.get("text", ""))], false)
				primary_button.text = "请选择立场"
				primary_button.disabled = true
				_render_choices(event)
			else:
				_set_dialogue("旁白", str(chapter.get("summary", "")), false)
				primary_button.text = "进入战斗" if not str(chapter.get("encounter_id", "")).is_empty() else "继续"
				primary_button.disabled = false

func _render_choices(event: Dictionary) -> void:
	_clear_choices()
	for choice in event.get("choices", []):
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 42)
		button.text = str(choice.get("label", ""))
		button.pressed.connect(_apply_choice.bind(str(choice.get("id", ""))))
		choice_box.add_child(button)

func _render_shared_choices(event: Dictionary) -> void:
	_clear_choices()
	for choice in event.get("choices", []):
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 42)
		button.text = str(choice.get("label", ""))
		button.pressed.connect(_apply_shared_choice.bind(str(choice.get("id", ""))))
		choice_box.add_child(button)

func _clear_choices() -> void:
	if choice_box == null:
		return
	for child in choice_box.get_children():
		child.queue_free()
