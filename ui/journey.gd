class_name JourneyScreen
extends Control

const CHARACTER_NAMES := {
	"TANG": "唐三藏",
	"WUKONG": "孙悟空",
	"BAJIE": "猪八戒",
	"WUJING": "沙悟净",
	"LONGMA": "白龙马",
}

const ORIGIN_CHAPTERS := {
	"WUKONG": [
		["WUK-01", "石猴出世"], ["WUK-02", "水帘洞主"], ["WUK-03", "寻仙问道"], ["WUK-04", "菩提门下"],
		["WUK-05", "大圣初醒"], ["WUK-06", "龙宫取宝"], ["WUK-07", "地府改命"], ["WUK-08", "弼马温"],
		["WUK-09", "齐天大圣"], ["WUK-10", "偷食蟠桃"], ["WUK-11", "天兵天将"], ["WUK-12", "二郎神"],
		["WUK-13", "炼丹炉"], ["WUK-14", "大闹天宫"], ["WUK-15", "五行山"],
	],
	"TANG": [
		["TANG-01", "陈玄奘"], ["TANG-02", "出家"], ["TANG-03", "玄奘法师"], ["TANG-04", "长安受命"],
		["TANG-05", "踏上取经路"], ["TANG-06", "双叉岭"], ["TANG-07", "鹰愁涧前夜"], ["TANG-08", "五行山"],
	],
	"LONGMA": [
		["LONGMA-01", "西海龙宫"], ["LONGMA-02", "龙子获罪"], ["LONGMA-03", "鹰愁涧"],
		["LONGMA-04", "白马之誓"], ["LONGMA-05", "唐僧来临"], ["LONGMA-06", "化作白马"],
	],
	"BAJIE": [
		["BAJIE-01", "天蓬元帅"], ["BAJIE-02", "蟠桃宴"], ["BAJIE-03", "天河逐罚"], ["BAJIE-04", "投胎凡间"],
		["BAJIE-05", "高老庄"], ["BAJIE-06", "招亲"], ["BAJIE-07", "妖身"], ["BAJIE-08", "悟空斗法"], ["BAJIE-09", "放下"],
	],
	"WUJING": [
		["WUJING-01", "卷帘大将"], ["WUJING-02", "失手"], ["WUJING-03", "流沙河"], ["WUJING-04", "无尽"],
		["WUJING-05", "河中来客"], ["WUJING-06", "观音渡厄"], ["WUJING-07", "流沙河之战"], ["WUJING-08", "皈依"],
	],
}

const CONVERGENCE := {
	"WUKONG": {"milestone": "WUKONG_RECRUITED", "timeline": 100, "shared": "SHARED-01-FIVE-ELEMENTS", "recruit": ["TANG", "WUKONG"]},
	"TANG": {"milestone": "WUKONG_RECRUITED", "timeline": 100, "shared": "SHARED-01-FIVE-ELEMENTS", "recruit": ["TANG", "WUKONG"]},
	"LONGMA": {"milestone": "BAI_LONGMA_RECRUITED", "timeline": 110, "shared": "SHARED-03-EAGLE-SORROW", "recruit": ["TANG", "WUKONG", "LONGMA"]},
	"BAJIE": {"milestone": "ZHU_BAJIE_RECRUITED", "timeline": 130, "shared": "SHARED-05-GAOJIAZHUANG", "recruit": ["TANG", "WUKONG", "LONGMA", "BAJIE"]},
	"WUJING": {"milestone": "SHA_WUJING_RECRUITED", "timeline": 150, "shared": "SHARED-07-FLOWING-SANDS", "recruit": ["TANG", "WUKONG", "LONGMA", "BAJIE", "WUJING"]},
}

var narrative := NarrativeManager.new()
var title_label: Label
var phase_label: Label
var chapter_label: Label
var description_label: Label
var list: ItemList
var primary_button: Button
var memory_button: Button
var save_button: Button
var route_index := 0

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	_route_index_from_save()
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

	memory_button = Button.new()
	memory_button.text = "播放已解锁回忆"
	memory_button.custom_minimum_size = Vector2(0, 46)
	memory_button.pressed.connect(_play_selected_memory)
	left.add_child(memory_button)

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
	list_title.text = "路线记录"
	list_title.add_theme_font_size_override("font_size", 18)
	right.add_child(list_title)

	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(list)

	var rule := Label.new()
	rule.text = "个人路线是历史章节；完成个人路线后回到当前固定世界时间线。招募新成员时，其个人故事会立即解锁。"
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(rule)

func _current_route() -> Array:
	return ORIGIN_CHAPTERS.get(narrative.state.starting_character, [])

func _route_index_from_save() -> void:
	var chapters:Array = _current_route()
	if chapters.is_empty():
		route_index = 0
		return
	if narrative.state.current_origin_chapter != "":
		for i in range(chapters.size()):
			if str(chapters[i][0]) == narrative.state.current_origin_chapter:
				route_index = i
				return
	route_index = 0
	for i in range(chapters.size()):
		if str(chapters[i][0]) in narrative.state.completed_chapters:
			route_index = i + 1
	if route_index > chapters.size():
		route_index = chapters.size()

func _advance_primary() -> void:
	var chapters:Array = _current_route()
	if chapters.is_empty():
		return
	if narrative.state.current_origin_route == "":
		narrative.state.set_origin_progress("%s_ORIGIN" % narrative.state.starting_character, str(chapters[route_index][0]))
	if route_index >= chapters.size():
		_finish_origin()
		return
	var entry:Array = chapters[route_index]
	var chapter_id := str(entry[0])
	if chapter_id not in narrative.state.completed_chapters:
		narrative.complete_chapter(chapter_id, false)
	route_index += 1
	if route_index < chapters.size():
		narrative.state.set_origin_progress("%s_ORIGIN" % narrative.state.starting_character, str(chapters[route_index][0]))
	else:
		narrative.state.set_origin_progress("%s_ORIGIN" % narrative.state.starting_character, "")
	narrative.save()
	_refresh()

func _finish_origin() -> void:
	var start := narrative.state.starting_character
	if not CONVERGENCE.has(start):
		return
	var handoff:Dictionary = CONVERGENCE[start]
	narrative.state.mark_route_complete(start)
	narrative.advance_world_milestone(str(handoff["milestone"]), int(handoff["timeline"]))
	narrative.set_shared_chapter(str(handoff["shared"]))
	for character_id in handoff["recruit"]:
		var memories:Array[String] = []
		if str(character_id) != start:
			memories = _memory_preview(str(character_id))
		narrative.encounter_character(str(character_id), memories)
	narrative.save()
	_refresh()

func _memory_preview(character_id:String) -> Array[String]:
	var chapters:Array = ORIGIN_CHAPTERS.get(character_id, [])
	var result:Array[String] = []
	for i in range(min(2, chapters.size())):
		result.append(str(chapters[i][0]))
	return result

func _play_selected_memory() -> void:
	var selected := list.get_selected_items()
	if selected.is_empty():
		return
	var row := list.get_item_text(selected[0])
	if not row.begins_with("回忆:") or not row.ends_with("[可回忆]"):
		return
	var memory_id := row.trim_prefix("回忆: ").trim_suffix(" [可回忆]")
	if narrative.can_enter_memory(memory_id):
		narrative.begin_memory(memory_id)
		narrative.finish_memory(memory_id)
		narrative.save()
		_refresh()

func _save() -> void:
	narrative.save()
	phase_label.text = "已保存。世界时间不会因回忆播放而改变。"

func _back_to_menu() -> void:
	narrative.save()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _refresh() -> void:
	if title_label == null:
		return
	var start := narrative.state.starting_character
	title_label.text = "西游 · %s" % CHARACTER_NAMES.get(start, start)
	if narrative.state.current_origin_route != "":
		phase_label.text = "个人路线进行中 · %s · 已完成 %d 章" % [narrative.state.current_origin_route, narrative.state.completed_chapters.size()]
	else:
		phase_label.text = "共享旅程 · T%04d · %s" % [narrative.state.current_global_timeline, narrative.state.current_shared_chapter]

	var chapters:Array = _current_route()
	if narrative.state.route_progress.get(start, NarrativeState.ROUTE_LOCKED) == NarrativeState.ROUTE_COMPLETE:
		chapter_label.text = "已完成个人起始路线"
		description_label.text = "你已经把起始角色的历史走完。现在世界继续沿固定西游时间线推进；这不是把世界倒回去，而是把这段历史正式接回主线。"
		primary_button.text = "进入共享旅程"
		primary_button.disabled = true
	elif route_index >= chapters.size():
		chapter_label.text = "路线汇合"
		description_label.text = "个人历史结束。点击一次完成汇合，系统会按该起始角色的固定汇合点恢复西游主时间线。"
		primary_button.text = "完成路线并回到主线"
		primary_button.disabled = false
	else:
		chapter_label.text = "%s · %s" % [chapters[route_index][0], chapters[route_index][1]]
		description_label.text = "这是起始角色的历史章节。它可以展开角色背景、关键战斗和人物关系，但不会改变共享西游世界的当前时间。"
		primary_button.text = "完成本章"
		primary_button.disabled = false

	memory_button.disabled = narrative.state.available_memory_chapters.is_empty()
	list.clear()
	for chapter in chapters:
		var id := str(chapter[0])
		var chapter_title := str(chapter[1])
		var marker := "✓" if id in narrative.state.completed_chapters else "·"
		list.add_item("路线 %s  %s %s" % [marker, id, chapter_title])
	for memory_id in narrative.state.available_memory_chapters:
		list.add_item("回忆: %s [可回忆]" % memory_id)
	for memory_id in narrative.state.played_memory_chapters:
		list.add_item("回忆: %s [已看]" % memory_id)
