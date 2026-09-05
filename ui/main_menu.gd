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
	"TANG": "取经之路的起点。信念、慈悲与戒律。",
	"WUKONG": "石猴、齐天大圣与五行山。自由与束缚。",
	"BAJIE": "天蓬元帅堕入凡间。欲望、选择与责任。",
	"WUJING": "卷帘大将与流沙河。罪责、沉默与救赎。",
	"LONGMA": "西海龙脉化身白马。身份、荣誉与使命。",
}

const CHARACTER_STORIES := {
	"WUKONG": "花果山的石猴从水帘洞出发，求的是一个“不受拘束”。真正让他无法回避的，是天地秩序与自己的桀骜。",
	"TANG": "他不是最强的人，却决定踏上最漫长的路。慈悲不是软弱，而是一条必须承担代价的道路。",
	"BAJIE": "曾经的天蓬元帅跌入凡间。带着一身本领，也带着割舍不掉的欲念。",
	"WUJING": "卷帘大将失手打碎琉璃盏。流沙河的岁月，让赎罪成为一次次重新选择。",
	"LONGMA": "西海龙宫的血脉给了他骄傲，也给了他枷锁。使命最终比出身更重要。",
}

const ROUTE_LENGTHS := {
	"TANG": "8章",
	"WUKONG": "15章",
	"BAJIE": "9章",
	"WUJING": "8章",
	"LONGMA": "6章",
}

const GOLD := Color("d5ad57")
const PAPER := Color("ead9aa")
const INK := Color("111018")
const PANEL := Color(0.045, 0.042, 0.055, 0.82)

const CHARACTER_ORDER := ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA"]

var narrative := NarrativeManager.new()
var selected_character := "WUKONG"
var selected_label: Label
var story_label: Label
var current_label: Label
var continue_button: Button
var portrait: CharacterPortrait
var character_buttons: Dictionary = {}

func _ready() -> void:
	_build_ui()
	_refresh_ui()

func _panel(parent: Node, min_size := Vector2.ZERO) -> PanelContainer:
	var panel := PanelContainer.new()
	if min_size != Vector2.ZERO:
		panel.custom_minimum_size = min_size
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color(GOLD, 0.42)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
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
	shade.color = Color(0.03, 0.025, 0.04, 0.12)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 42)
	root_margin.add_theme_constant_override("margin_right", 42)
	root_margin.add_theme_constant_override("margin_top", 34)
	root_margin.add_theme_constant_override("margin_bottom", 30)
	add_child(root_margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	root_margin.add_child(root)

	var title_row := HBoxContainer.new()
	root.add_child(title_row)
	var title_stack := VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_stack)
	var title := _label("西游：五行之路", 42)
	title.modulate = Color(1.0, 0.89, 0.64)
	title_stack.add_child(title)
	var subtitle := _label("THE PILGRIMAGE OF THE FIVE ELEMENTS", 13, Color("a9966c"))
	title_stack.add_child(subtitle)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(360, 2)
	rule.color = Color(GOLD, 0.6)
	title_stack.add_child(rule)
	var chapter := _label("五行路 · 第一卷 · 从一个人的故事开始", 15, Color("c4b486"))
	chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title_row.add_child(chapter)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	var left := _panel(body, Vector2(330, 0))
	var left_box := VBoxContainer.new()
	left_box.add_theme_constant_override("separation", 9)
	left.add_child(left_box)
	left_box.add_child(_label("选择主角", 22))
	left_box.add_child(_label("五条序章，最终汇入同一条西游时间线", 13, Color("958b7a")))

	var selector := VBoxContainer.new()
	selector.add_theme_constant_override("separation", 5)
	left_box.add_child(selector)
	for id in CHARACTER_ORDER:
		var button := Button.new()
		button.text = "◆  " + CHARACTER_NAMES[id]
		button.custom_minimum_size = Vector2(0, 46)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_select_character.bind(id))
		selector.add_child(button)
		character_buttons[id] = button

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color("4d463b")
	left_box.add_child(sep)

	selected_label = _label("", 17)
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_box.add_child(selected_label)
	story_label = _label("", 14, Color("c3b798"))
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.custom_minimum_size = Vector2(0, 118)
	left_box.add_child(story_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 7)
	left_box.add_child(actions)
	var start_button := Button.new()
	start_button.text = "开始序章"
	start_button.custom_minimum_size = Vector2(0, 48)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(_start_new_game)
	actions.add_child(start_button)
	continue_button = Button.new()
	continue_button.text = "继续"
	continue_button.custom_minimum_size = Vector2(0, 48)
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_button.pressed.connect(_load_game)
	actions.add_child(continue_button)

	var battle_button := Button.new()
	battle_button.text = "测试战斗"
	battle_button.custom_minimum_size = Vector2(0, 38)
	battle_button.pressed.connect(_open_battle_ui)
	left_box.add_child(battle_button)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 6)
	body.add_child(center)
	var scene_hint := _label("花果山 · 西行之路", 15, Color("d1ba7e"))
	scene_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(scene_hint)
	var scene_frame := _panel(center, Vector2(0, 0))
	scene_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var empty := Control.new()
	empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_frame.add_child(empty)
	var frame_hint := _label("", 13, Color("9e927b"))
	frame_hint.text = "选择角色 · 进入序章 · 五人将在此相遇"
	frame_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame_hint.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	empty.add_child(frame_hint)

	var right := _panel(body, Vector2(300, 0))
	var right_box := VBoxContainer.new()
	right_box.add_theme_constant_override("separation", 9)
	right.add_child(right_box)
	portrait = CharacterPortrait.new()
	portrait.custom_minimum_size = Vector2(260, 250)
	right_box.add_child(portrait)
	var identity := _label("人物序章", 14, Color("a99569"))
	right_box.add_child(identity)
	current_label = _label("", 14, Color("c6b995"))
	current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_label.custom_minimum_size = Vector2(0, 110)
	right_box.add_child(current_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 16)
	root.add_child(footer)
	var footer_left := _label("↑↓ / 鼠标选择主角   Enter 开始   Esc 返回", 12, Color("8f866f"))
	footer_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_left)
	var footer_right := _label("蛋汤 · Journey to the West", 12, Color("8f866f"))
	footer_right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer.add_child(footer_right)

func _select_character(character_id: String) -> void:
	selected_character = character_id
	if portrait != null:
		portrait.set_character(character_id)
	_refresh_ui()

func _refresh_ui() -> void:
	if continue_button == null:
		return
	selected_label.text = "%s · %s\n%s" % [CHARACTER_NAMES[selected_character], ROUTE_LENGTHS[selected_character], CHARACTER_DESCRIPTIONS[selected_character]]
	story_label.text = CHARACTER_STORIES[selected_character]
	continue_button.disabled = not NarrativeSave.has_save()
	for id in character_buttons:
		var button: Button = character_buttons[id]
		button.modulate = Color("f1d27d") if id == selected_character else Color("c5b99e")
	if narrative.state.starting_character == "":
		current_label.text = "尚未开始旅程。\n\n选择一位主角，他的个人序章将成为你第一次踏上西游的视角。"
	else:
		current_label.text = "当前存档\n起始主角：%s\n世界时间：T%04d\n共享章节：%s\n已招募：%s" % [
			CHARACTER_NAMES.get(narrative.state.starting_character, narrative.state.starting_character),
			narrative.state.current_global_timeline,
			narrative.state.current_shared_chapter if narrative.state.current_shared_chapter != "" else "尚未汇合",
			_join_character_names(narrative.state.recruited_characters),
		]

func _start_new_game() -> void:
	if not narrative.start_new_game(selected_character):
		return
	if narrative.save():
		get_tree().change_scene_to_file("res://ui/journey.tscn")

func _load_game() -> void:
	if narrative.load():
		get_tree().change_scene_to_file("res://ui/journey.tscn")

func _open_battle_ui() -> void:
	get_tree().change_scene_to_file("res://ui/battle_ui.tscn")

func _join_character_names(ids: Array[String]) -> String:
	if ids.is_empty():
		return "无"
	var names: Array[String] = []
	for id in ids:
		names.append(CHARACTER_NAMES.get(id, id))
	return "、".join(names)
