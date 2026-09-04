class_name JourneyScreen
extends Control

const CHARACTER_NAMES := {"TANG":"唐三藏", "WUKONG":"孙悟空", "BAJIE":"猪八戒", "WUJING":"沙悟净", "LONGMA":"白龙马"}

var narrative := NarrativeManager.new()
var origin := OriginRouteManager.new()
var origin_events := OriginEventManager.new()
var party := PartyManager.new()
var title_label: Label
var phase_label: Label
var chapter_label: Label
var description_label: Label
var list: ItemList
var primary_button: Button
var choice_box: VBoxContainer
var memory_button: Button
var party_button: Button
var world_button: Button
var save_button: Button

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	party.initialize_from_saved_state(narrative.state.recruited_characters, narrative.state.get_party_formation())
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("0d0d12")
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	root.add_child(title_label)
	phase_label = Label.new()
	phase_label.add_theme_font_size_override("font_size", 16)
	root.add_child(phase_label)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(520, 0)
	left.add_theme_constant_override("separation", 10)
	body.add_child(left)
	chapter_label = Label.new()
	chapter_label.add_theme_font_size_override("font_size", 24)
	chapter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(chapter_label)
	description_label = Label.new()
	description_label.custom_minimum_size = Vector2(0, 180)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(description_label)
	primary_button = Button.new()
	primary_button.custom_minimum_size = Vector2(0, 54)
	primary_button.pressed.connect(_advance_primary)
	left.add_child(primary_button)
	choice_box = VBoxContainer.new()
	choice_box.add_theme_constant_override("separation", 8)
	left.add_child(choice_box)
	memory_button = Button.new()
	memory_button.text = "播放已解锁回忆"
	memory_button.custom_minimum_size = Vector2(0, 46)
	memory_button.pressed.connect(_play_selected_memory)
	left.add_child(memory_button)
	party_button = Button.new()
	party_button.text = "队伍编成"
	party_button.custom_minimum_size = Vector2(0, 46)
	party_button.pressed.connect(_open_party)
	left.add_child(party_button)
	world_button = Button.new()
	world_button.text = "进入世界地图"
	world_button.custom_minimum_size = Vector2(0, 46)
	world_button.pressed.connect(_open_world_map)
	left.add_child(world_button)
	var utility := HBoxContainer.new()
	utility.add_theme_constant_override("separation", 8)
	left.add_child(utility)
	save_button = Button.new()
	save_button.text = "保存"
	save_button.pressed.connect(_save)
	utility.add_child(save_button)
	var back := Button.new()
	back.text = "返回主菜单"
	back.pressed.connect(_back_to_menu)
	utility.add_child(back)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	body.add_child(right)
	var list_title := Label.new()
	list_title.text = "路线与共享西游"
	list_title.add_theme_font_size_override("font_size", 18)
	right.add_child(list_title)
	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(list)
	var rule := Label.new()
	rule.text = "世界时间线只向前；个人故事是历史回放。招募角色后，其回忆立即开放；五人集齐只开启完整队伍层。世界地图中的探索不会重写主线，只记录地点、情报与世界影响。"
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(rule)

func _current_route() -> Array:
	return origin.get_chapters(narrative.state.starting_character)

func _advance_primary() -> void:
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
		phase_label.text = "先做出选择，再继续本章。"
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

func _apply_choice(choice_id: String) -> void:
	var start := narrative.state.starting_character
	var chapter := origin.get_current_chapter(narrative, start)
	if chapter.is_empty():
		return
	var chapter_id := str(chapter.get("id", ""))
	if origin_events.apply_choice(narrative, chapter_id, choice_id):
		narrative.save()
		phase_label.text = "已记录你的选择。"
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
	var chapter := SharedJourneyManager.get_chapter(chapter_id)
	if chapter.is_empty():
		phase_label.text = "共享旅程已完成。"
		_refresh()
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
		phase_label.text = "完成 %s · 新加入：%s · 对应个人回忆已开放。" % [str(chapter.get("title", chapter_id)), "、".join(recruited_names)]

func _play_selected_memory() -> void:
	var selected := list.get_selected_items()
	if selected.is_empty():
		return
	var row := list.get_item_text(selected[0])
	if not row.begins_with("回忆:"):
		return
	var memory_id := row.replace("回忆: ", "").replace(" [可回忆]", "")
	if narrative.can_enter_memory(memory_id):
		narrative.begin_memory(memory_id)
		narrative.finish_memory(memory_id)
		narrative.save()
		_refresh()

func _open_party() -> void:
	get_tree().change_scene_to_file("res://ui/party_screen.tscn")

func _open_world_map() -> void:
	get_tree().change_scene_to_file("res://ui/world_map.tscn")

func _save() -> void:
	narrative.state.set_party_formation(party.to_dict())
	if narrative.save():
		phase_label.text = "已保存。世界时间不会因回忆播放而改变。"
	else:
		phase_label.text = "保存失败。"

func _back_to_menu() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _refresh() -> void:
	if title_label == null:
		return
	var start := narrative.state.starting_character
	title_label.text = "西游 · %s" % CHARACTER_NAMES.get(start, start)
	_clear_choices()
	if narrative.state.route_progress.get(start, NarrativeState.ROUTE_LOCKED) == NarrativeState.ROUTE_COMPLETE:
		phase_label.text = "共享旅程 · T%04d · %s · 队伍 %d/5" % [narrative.state.current_global_timeline, narrative.state.current_shared_chapter, party.roster.size()]
		var chapter := SharedJourneyManager.get_chapter(narrative.state.current_shared_chapter)
		if chapter.is_empty():
			chapter_label.text = "共享旅程已完成"
			description_label.text = "当前共享章节链已经走完。"
			primary_button.text = "已完成"
			primary_button.disabled = true
		else:
			chapter_label.text = "%s · %s" % [chapter.get("id", ""), chapter.get("title", "")]
			description_label.text = "固定西游时间线 T%04d。完成该章会推进到下一段共享旅程；若命中招募节点，会同时开放对应角色历史。" % int(chapter.get("timeline", 0))
			primary_button.text = "完成共享章节"
			primary_button.disabled = false
	else:
		var chapters := _current_route()
		var index := origin.get_current_index(narrative, start)
		if index >= chapters.size():
			chapter_label.text = "路线汇合"
			description_label.text = "个人历史结束。下一步会将起始角色接回固定西游主线，并按经典招募节点建立当前队伍。"
			primary_button.text = "完成路线并回到主线"
			primary_button.disabled = false
		else:
			var chapter: Dictionary = chapters[index]
			var chapter_id := str(chapter.get("id", ""))
			var event := origin_events.get_event(chapter_id)
			var chosen := narrative.state.get_origin_choice(chapter_id)
			chapter_label.text = "%s · %s" % [chapter.get("id", ""), chapter.get("title", "")]
			var battle_hint := str(chapter.get("battle_after", ""))
			description_label.text = str(chapter.get("summary", ""))
			if not event.is_empty():
				description_label.text += "\n\n" + str(event.get("text", ""))
			if not battle_hint.is_empty():
				description_label.text += "\n\n战斗节点：" + battle_hint
			description_label.text += "\n\n起始角色历史章节只推进个人路线，不改变共享西游时间线。"
			if not event.is_empty() and chosen == "":
				primary_button.text = "请选择立场"
				primary_button.disabled = true
				_render_choices(event)
			else:
				primary_button.text = "进入个人战斗" if not str(chapter.get("encounter_id", "")).is_empty() else "完成本章"
				primary_button.disabled = false
	list.clear()
	for chapter in _current_route():
		var id := str(chapter.get("id", ""))
		var chapter_title := str(chapter.get("title", ""))
		var battle_mark := " ⚔" if not str(chapter.get("encounter_id", "")).is_empty() else ""
		var marker := "✓" if id in narrative.state.completed_chapters else "·"
		var choice_mark := " ◆" if narrative.state.get_origin_choice(id) != "" else ""
		list.add_item("路线 %s  %s %s%s%s" % [marker, id, chapter_title, battle_mark, choice_mark])
	for memory_id in narrative.state.available_memory_chapters:
		list.add_item("回忆: %s [可回忆]" % memory_id)
	for memory_id in narrative.state.played_memory_chapters:
		list.add_item("回忆: %s [已看]" % memory_id)
	for shared_id in narrative.state.completed_shared_chapters:
		list.add_item("主线 ✓ %s" % shared_id)
	if not narrative.state.current_shared_chapter.is_empty():
		list.add_item("主线 → %s" % narrative.state.current_shared_chapter)

func _clear_choices() -> void:
	if choice_box == null:
		return
	for child in choice_box.get_children():
		child.queue_free()

func _render_choices(event: Dictionary) -> void:
	_clear_choices()
	for choice in event.get("choices", []):
		var choice_id := str(choice.get("id", ""))
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 48)
		button.text = str(choice.get("label", choice_id))
		button.pressed.connect(_apply_choice.bind(choice_id))
		choice_box.add_child(button)
