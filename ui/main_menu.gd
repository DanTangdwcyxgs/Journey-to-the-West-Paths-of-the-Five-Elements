class_name MainMenu
extends Control

const CHARACTER_NAMES := {
	"TANG": "唐三藏",
	"WUKONG": "孙悟空",
	"BAJIE": "猪八戒",
	"WUJING": "沙悟净",
	"LONGMA": "白龙马",
}

const CHARACTER_DESCRIPTIONS := {
	"TANG": "取经之路的起点。信念、慈悲与戒律的故事。",
	"WUKONG": "石猴、齐天大圣与五行山。自由与束缚的故事。",
	"BAJIE": "天蓬元帅堕落凡间。欲望、选择与责任的故事。",
	"WUJING": "卷帘大将与流沙河。罪责、沉默与救赎的故事。",
	"LONGMA": "龙族血脉与白马之身。身份、荣誉与使命的故事。",
}

const CHARACTER_STORIES := {
	"WUKONG": "花果山的石猴从水帘洞出发，求的是一个\"不受拘束\"。他学会七十二变，也夺过定海神针；真正让他无法回避的，却是天地秩序与自己的桀骜。五行山下的五百年，是这段西游路真正的前夜。",
	"TANG": "他不是最强的人，却决定踏上最漫长的路。玄奘以取经为愿，在长安接下西行使命；从这一刻起，慈悲不是软弱，而是一条必须承担代价的道路。",
	"BAJIE": "曾经的天蓬元帅跌入凡间，带着一身本领，也带着割舍不掉的欲念。高老庄之前，他一直在逃避\"自己到底想成为什么人\"；这一趟西游，会逼他重新作答。",
	"WUJING": "卷帘大将失手打碎琉璃盏，被贬流沙河。岁月让他沉默，也让他明白：赎罪不是等待宽恕，而是重新选择一次该走的路。",
	"LONGMA": "西海龙宫的血脉给了他骄傲，也给了他枷锁。一次意外让他失去原本的身份；当他成为白马、踏上取经队伍时，\"使命\"第一次比\"出身\"更重要。",
}

const ROUTE_LENGTHS := {
	"TANG": "8章",
	"WUKONG": "15章",
	"BAJIE": "9章",
	"WUJING": "8章",
	"LONGMA": "6章",
}

const DEVELOPER_NAME := "蛋汤"
const CONTACT_WECHAT := "DanTangdwcyxgs"

var narrative := NarrativeManager.new()
var selected_character := "WUKONG"
var selected_label: Label
var story_label: Label
var route_label: Label
var status_label: Label
var current_label: Label
var memory_list: ItemList
var continue_button: Button
var portrait: CharacterPortrait

func _ready() -> void:
	_build_ui()
	_refresh_ui()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("111018")
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 34)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var title := Label.new()
	title.text = "西游：五行之路"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "低资源 2D JRPG · 八方旅人式多主角入口 · 回合制冒险"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	root.add_child(subtitle)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(430, 0)
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)

	var start_title := Label.new()
	start_title.text = "第一章 · 选择你的主角"
	start_title.add_theme_font_size_override("font_size", 20)
	left.add_child(start_title)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	left.add_child(grid)
	for character_id in ["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"]:
		var button := Button.new()
		button.text = CHARACTER_NAMES[character_id]
		button.custom_minimum_size = Vector2(205, 52)
		button.tooltip_text = CHARACTER_DESCRIPTIONS[character_id]
		button.pressed.connect(_select_character.bind(character_id))
		grid.add_child(button)

	selected_label = Label.new()
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_label.custom_minimum_size = Vector2(0, 56)
	selected_label.add_theme_font_size_override("font_size", 16)
	left.add_child(selected_label)

	story_label = Label.new()
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.custom_minimum_size = Vector2(0, 154)
	story_label.add_theme_font_size_override("font_size", 15)
	left.add_child(story_label)

	route_label = Label.new()
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label.add_theme_font_size_override("font_size", 13)
	left.add_child(route_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	left.add_child(actions)
	var start_button := Button.new()
	start_button.text = "进入个人序章"
	start_button.custom_minimum_size = Vector2(0, 48)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(_start_new_game)
	actions.add_child(start_button)

	continue_button = Button.new()
	continue_button.text = "读取存档"
	continue_button.custom_minimum_size = Vector2(0, 48)
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_button.pressed.connect(_load_game)
	actions.add_child(continue_button)

	var battle_button := Button.new()
	battle_button.text = "测试战斗"
	battle_button.custom_minimum_size = Vector2(0, 40)
	battle_button.pressed.connect(_open_battle_ui)
	left.add_child(battle_button)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(status_label)

	var center := VBoxContainer.new()
	center.custom_minimum_size = Vector2(300, 0)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 6)
	body.add_child(center)

	portrait = CharacterPortrait.new()
	portrait.custom_minimum_size = Vector2(300, 360)
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(portrait)
	var portrait_hint := Label.new()
	portrait_hint.text = "角色图采用少量颜色、程序绘制和可替换资源槽；后期可直接换成像素立绘。"
	portrait_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	portrait_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_hint.add_theme_font_size_override("font_size", 12)
	center.add_child(portrait_hint)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(360, 0)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 7)
	body.add_child(right)

	var journey_title := Label.new()
	journey_title.text = "当前西游状态"
	journey_title.add_theme_font_size_override("font_size", 20)
	right.add_child(journey_title)
	current_label = Label.new()
	current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_label.custom_minimum_size = Vector2(0, 96)
	right.add_child(current_label)

	var memory_title := Label.new()
	memory_title.text = "已解锁人物回忆"
	memory_title.add_theme_font_size_override("font_size", 18)
	right.add_child(memory_title)
	memory_list = ItemList.new()
	memory_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(memory_list)

	var hint := Label.new()
	hint.text = "设计原则：主线时间线固定；角色个人序章负责选择与视角；招募后立即开启该角色回忆。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(hint)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 12)
	root.add_child(footer)
	var credit := Label.new()
	credit.text = "开发者：%s" % DEVELOPER_NAME
	credit.add_theme_font_size_override("font_size", 13)
	footer.add_child(credit)
	var contact_button := Button.new()
	contact_button.text = "投资合作 / 联系开发者"
	contact_button.custom_minimum_size = Vector2(190, 34)
	contact_button.tooltip_text = "联系开发者：%s" % CONTACT_WECHAT
	contact_button.pressed.connect(_show_contact_dialog)
	footer.add_child(contact_button)

func _select_character(character_id: String) -> void:
	selected_character = character_id
	if portrait != null:
		portrait.set_character(character_id)
	_refresh_ui()

func _start_new_game() -> void:
	if not narrative.start_new_game(selected_character):
		status_label.text = "无法开始：无效角色。"
		return
	if not narrative.save():
		status_label.text = "新旅程已创建，但存档写入失败。"
		return
	get_tree().change_scene_to_file("res://ui/journey.tscn")

func _load_game() -> void:
	if not narrative.load():
		status_label.text = "没有可读取的西游存档。"
		return
	get_tree().change_scene_to_file("res://ui/journey.tscn")

func _open_battle_ui() -> void:
	get_tree().change_scene_to_file("res://ui/battle_ui.tscn")

func _show_contact_dialog() -> void:
	var dialog := _create_contact_dialog()
	add_child(dialog)
	dialog.popup_centered(Vector2i(560, 300))

func _create_contact_dialog() -> AcceptDialog:
	var dialog := AcceptDialog.new()
	dialog.title = "投资合作 / 联系开发者"
	dialog.dialog_text = "开发者：%s\n\n微信：%s\n\n感谢关注《西游：五行之路》。如有投资、发行、商务合作或项目交流，可通过微信联系。" % [DEVELOPER_NAME, CONTACT_WECHAT]
	dialog.ok_button_text = "复制微信号"
	dialog.confirmed.connect(_copy_contact_to_clipboard.bind(dialog))
	return dialog

func _copy_contact_to_clipboard(dialog: AcceptDialog) -> void:
	DisplayServer.clipboard_set(CONTACT_WECHAT)
	status_label.text = "微信号已复制：%s" % CONTACT_WECHAT
	dialog.queue_free()

func _refresh_ui() -> void:
	if status_label == null:
		return
	selected_label.text = "%s · %s\n%s" % [CHARACTER_NAMES[selected_character], ROUTE_LENGTHS[selected_character], CHARACTER_DESCRIPTIONS[selected_character]]
	story_label.text = "人物序章\n" + CHARACTER_STORIES[selected_character]
	route_label.text = "序章长度：%s · 完成后进入固定世界时间线；个人路线只改变进入西游的视角。" % ROUTE_LENGTHS[selected_character]
	continue_button.disabled = not NarrativeSave.has_save()
	if narrative.state.starting_character == "":
		current_label.text = "尚未开始旅程。\n选择任意一人，先体验他的个人序章，再与共享西游主线汇合。"
	else:
		current_label.text = "起始主角：%s\n世界时间：T%04d\n当前共享章节：%s\n当前个人路线：%s / %s\n已招募：%s" % [
			CHARACTER_NAMES.get(narrative.state.starting_character, narrative.state.starting_character),
			narrative.state.current_global_timeline,
			narrative.state.current_shared_chapter if narrative.state.current_shared_chapter != "" else "尚未进入共享章节",
			narrative.state.current_origin_route if narrative.state.current_origin_route != "" else "已汇合",
			narrative.state.current_origin_chapter if narrative.state.current_origin_chapter != "" else "—",
			_join_character_names(narrative.state.recruited_characters),
		]
	memory_list.clear()
	if narrative.state.available_memory_chapters.is_empty() and narrative.state.played_memory_chapters.is_empty():
		memory_list.add_item("暂无回忆。遇见新伙伴后会立即出现。")
	else:
		for memory_id in narrative.state.available_memory_chapters:
			memory_list.add_item("▶ %s" % memory_id)
		for memory_id in narrative.state.played_memory_chapters:
			memory_list.add_item("✓ %s" % memory_id)

func _join_character_names(ids: Array[String]) -> String:
	if ids.is_empty():
		return "无"
	var names: Array[String] = []
	for id in ids:
		names.append(CHARACTER_NAMES.get(id, id))
	return "、".join(names)
