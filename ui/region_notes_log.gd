class_name RegionNotesLogScreen
extends Control

## Read-only review screen for region clues already stored in NarrativeState.
var narrative := NarrativeManager.new()
var region_manager := RegionExplorationManager.new()
var note_list: ItemList
var summary_label: Label
var detail_label: Label
var _notes: Array[Dictionary] = []
var _selected_point_id := ""
var _built := false

func _ready() -> void:
	_initialize_screen(true)


func _initialize_screen(load_saved_state: bool = true) -> void:
	if _built:
		return
	if load_saved_state and not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	_build_ui()
	_refresh()
	_built = true


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("0b0d12")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var title := Label.new()
	title.text = "旅途见闻"
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)

	var introduction := Label.new()
	introduction.text = "这里收录了你亲自发现的区域线索。离开现场后仍可回看；查阅记录不会改变西游主线。"
	introduction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	introduction.add_theme_font_size_override("font_size", 16)
	root.add_child(introduction)

	summary_label = Label.new()
	summary_label.add_theme_font_size_override("font_size", 15)
	root.add_child(summary_label)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)

	var list_title := Label.new()
	list_title.text = "已发现的线索"
	list_title.add_theme_font_size_override("font_size", 20)
	left.add_child(list_title)

	note_list = ItemList.new()
	note_list.name = "DiscoveredRegionNotes"
	note_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	note_list.item_selected.connect(_on_note_selected)
	left.add_child(note_list)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	body.add_child(right)

	var detail_title := Label.new()
	detail_title.text = "线索记录"
	detail_title.add_theme_font_size_override("font_size", 20)
	right.add_child(detail_title)

	detail_label = Label.new()
	detail_label.name = "RegionNoteDetail"
	detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	detail_label.add_theme_font_size_override("font_size", 18)
	right.add_child(detail_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	root.add_child(footer)

	var return_button := Button.new()
	return_button.text = "返回世界地图"
	return_button.custom_minimum_size = Vector2(200, 46)
	return_button.pressed.connect(_return_to_world_map)
	footer.add_child(return_button)

	var readonly_note := Label.new()
	readonly_note.text = "只读记录 · 不会重复发放奖励或推进章节"
	readonly_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	readonly_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	readonly_note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	readonly_note.add_theme_font_size_override("font_size", 13)
	readonly_note.modulate = Color("a79d89")
	footer.add_child(readonly_note)


func _refresh() -> void:
	if note_list == null:
		return
	_notes = region_manager.get_discovered_notes(narrative)
	note_list.clear()
	var selection_index := -1
	for i in range(_notes.size()):
		var note: Dictionary = _notes[i]
		var point_id := str(note.get("id", ""))
		var point_name := str(note.get("name", point_id))
		var region_name := str(note.get("region_name", ""))
		note_list.add_item("◆ %s\n%s" % [point_name, region_name])
		note_list.set_item_metadata(note_list.item_count - 1, point_id)
		if point_id == _selected_point_id:
			selection_index = note_list.item_count - 1

	summary_label.text = "已记录 %d 条线索 · 仅显示已发现记录" % _notes.size()
	if _notes.is_empty():
		_selected_point_id = ""
		detail_label.text = "目前还没有记录区域线索。前往世界地图上的可选区域，亲自调查后，就能在这里回看发现。"
		return

	if selection_index < 0:
		selection_index = 0
	_selected_point_id = str(note_list.get_item_metadata(selection_index))
	note_list.select(selection_index)
	_render_selected_note()


func _on_note_selected(index: int) -> void:
	if note_list == null or index < 0 or index >= note_list.item_count:
		return
	_selected_point_id = str(note_list.get_item_metadata(index))
	_render_selected_note()


func _render_selected_note() -> void:
	for note in _notes:
		if str(note.get("id", "")) != _selected_point_id:
			continue
		detail_label.text = "%s\n%s\n\n%s\n\n记录结果：%s" % [
			str(note.get("region_name", "旅途见闻")),
			str(note.get("name", _selected_point_id)),
			str(note.get("description", "")),
			str(note.get("result_text", "线索已经写入旅途记录。"))
		]
		return
	detail_label.text = "请选择一条已发现的线索。"


func _return_to_world_map() -> void:
	get_tree().change_scene_to_file("res://ui/world_map.tscn")
