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

var narrative := NarrativeManager.new()
var selected_character := "WUKONG"
var selected_label: Label
var status_label: Label
var current_label: Label
var memory_list: ItemList
var continue_button: Button

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
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	var title := Label.new()
	title.text = "BLACK MYTH: WUKONG\nJRPG EDITION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "西游记 · HD-2D · 回合制 JRPG"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	root.add_child(subtitle)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	root.add_child(body)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(440, 0)
	left.add_theme_constant_override("separation", 10)
	body.add_child(left)

	var start_title := Label.new()
	start_title.text = "新游戏 · 选择你的第一位主角"
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
		button.custom_minimum_size = Vector2(205, 58)
		button.tooltip_text = CHARACTER_DESCRIPTIONS[character_id]
		button.pressed.connect(_select_character.bind(character_id))
		grid.add_child(button)

	selected_label = Label.new()
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_label.custom_minimum_size = Vector2(0, 80)
	selected_label.add_theme_font_size_override("font_size", 16)
	left.add_child(selected_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	left.add_child(actions)

	var start_button := Button.new()
	start_button.text = "开始新旅程"
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
	battle_button.text = "进入战斗演示"
	battle_button.custom_minimum_size = Vector2(0, 42)
	battle_button.pressed.connect(_open_battle_demo)
	left.add_child(battle_button)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(status_label)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	body.add_child(right)

	var journey_title := Label.new()
	journey_title.text = "当前西游状态"
	journey_title.add_theme_font_size_override("font_size", 20)
	right.add_child(journey_title)

	current_label = Label.new()
	current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_label.custom_minimum_size = Vector2(0, 92)
	right.add_child(current_label)

	var memory_title := Label.new()
	memory_title.text = "已解锁人物回忆"
	memory_title.add_theme_font_size_override("font_size", 18)
	right.add_child(memory_title)

	memory_list = ItemList.new()
	memory_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(memory_list)

	var hint := Label.new()
	hint.text = "规则：遇见/招募某人后，该人物的个人故事立即开放；回忆不会推进当前西游时间线。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(hint)

func _select_character(character_id: String) -> void:
	selected_character = character_id
	_refresh_ui()

func _start_new_game() -> void:
	if not narrative.start_new_game(selected_character):
		status_label.text = "无法开始：无效角色。"
		return
	narrative.save()
	status_label.text = "已创建新旅程：%s。个人路线已立即开放。" % CHARACTER_NAMES[selected_character]
	_refresh_ui()

func _load_game() -> void:
	if not narrative.load():
		status_label.text = "没有可读取的西游存档。"
		return
	selected_character = narrative.state.starting_character
	status_label.text = "存档读取成功。"
	_refresh_ui()

func _open_battle_demo() -> void:
	get_tree().change_scene_to_file("res://combat/battle_demo.tscn")

func _refresh_ui() -> void:
	if status_label == null:
		return

	selected_label.text = "%s\n%s" % [CHARACTER_NAMES[selected_character], CHARACTER_DESCRIPTIONS[selected_character]]
	continue_button.disabled = not NarrativeSave.has_save()

	if narrative.state.starting_character == "":
		current_label.text = "尚未开始旅程。\n选择任意一人开始；世界时间线仍然遵循固定西游顺序。"
	else:
		current_label.text = "起始主角：%s\n世界时间：T%04d\n当前共享章节：%s\n已招募：%s" % [
			CHARACTER_NAMES.get(narrative.state.starting_character, narrative.state.starting_character),
			narrative.state.current_global_timeline,
			narrative.state.current_shared_chapter if narrative.state.current_shared_chapter != "" else "尚未进入共享章节",
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
