class_name PartyScreen
extends Control

const NAMES := {"TANG":"唐三藏", "WUKONG":"孙悟空", "BAJIE":"猪八戒", "WUJING":"沙悟净", "LONGMA":"白龙马"}

var party := PartyManager.new()
var narrative := NarrativeManager.new()
var front_list: ItemList
var back_list: ItemList
var roster_list: ItemList
var status_label: Label

func _ready() -> void:
	if narrative.load():
		party.initialize_from_recruited(narrative.state.recruited_characters)
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("101017")
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 50)
	margin.add_theme_constant_override("margin_right", 50)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var title := Label.new()
	title.text = "队伍编成"
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)

	status_label = Label.new()
	root.add_child(status_label)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	body.add_child(left)

	var front_title := Label.new()
	front_title.text = "前排 · 3"
	front_title.add_theme_font_size_override("font_size", 20)
	left.add_child(front_title)
	front_list = ItemList.new()
	front_list.custom_minimum_size = Vector2(0, 180)
	front_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(front_list)

	var back_title := Label.new()
	back_title.text = "后排 · 2"
	back_title.add_theme_font_size_override("font_size", 20)
	left.add_child(back_title)
	back_list = ItemList.new()
	back_list.custom_minimum_size = Vector2(0, 120)
	left.add_child(back_list)

	var move_front := Button.new()
	move_front.text = "选中角色 → 前排"
	move_front.pressed.connect(_selected_to_front)
	left.add_child(move_front)
	var move_back := Button.new()
	move_back.text = "选中角色 → 后排"
	move_back.pressed.connect(_selected_to_back)
	left.add_child(move_back)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	var roster_title := Label.new()
	roster_title.text = "已招募角色"
	roster_title.add_theme_font_size_override("font_size", 20)
	right.add_child(roster_title)
	roster_list = ItemList.new()
	roster_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(roster_list)
	var hint := Label.new()
	hint.text = "选择两个角色后，可直接互换位置；前排不足 3 人时按当前招募顺序补位。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(hint)

	var utility := HBoxContainer.new()
	root.add_child(utility)
	var swap := Button.new()
	swap.text = "互换选中两人"
	swap.pressed.connect(_swap_selected)
	utility.add_child(swap)
	var save := Button.new()
	save.text = "保存编成"
	save.pressed.connect(_save)
	utility.add_child(save)
	var back := Button.new()
	back.text = "返回"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/journey.tscn"))
	utility.add_child(back)

func _selected_ids_from(list: ItemList) -> Array[String]:
	var result: Array[String] = []
	for index in list.get_selected_items():
		if index >= 0 and index < list.item_count:
			var text := list.get_item_text(index)
			result.append(text)
	return result

func _selected_to_front() -> void:
	var ids := _selected_ids_from(back_list)
	if ids.size() == 1:
		party.move_to_front(ids[0])
		_refresh()

func _selected_to_back() -> void:
	var ids := _selected_ids_from(front_list)
	if ids.size() == 1:
		party.move_to_back(ids[0])
		_refresh()

func _swap_selected() -> void:
	var ids := _selected_ids_from(roster_list)
	if ids.size() == 2:
		party.swap_positions(ids[0], ids[1])
		_refresh()

func _save() -> void:
	if narrative.state.starting_character == "":
		status_label.text = "没有有效存档。"
		return
	# Party formation currently lives beside NarrativeState; save it with the same slot payload in the next persistence layer.
	narrative.save()
	status_label.text = "当前队形已保存到运行状态。"

func _refresh() -> void:
	front_list.clear()
	back_list.clear()
	roster_list.clear()
	for id in party.front_row:
		front_list.add_item(id)
	for id in party.back_row:
		back_list.add_item(id)
	for id in party.roster:
		roster_list.add_item(id)
	status_label.text = "前排：%s    后排：%s" % [_join_names(party.front_row), _join_names(party.back_row)]

func _join_names(ids: Array[String]) -> String:
	var names: Array[String] = []
	for id in ids:
		names.append(NAMES.get(id, id))
	return "、".join(names) if not names.is_empty() else "空"
