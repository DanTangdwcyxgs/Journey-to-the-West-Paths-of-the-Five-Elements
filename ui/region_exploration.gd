class_name RegionExplorationScreen
extends Control

var narrative := NarrativeManager.new()
var region_manager := RegionExplorationManager.new()
var world_map_manager := WorldMapManager.new()
var region_id: String = ""
var region_definition: Dictionary = {}
var point_list: ItemList
var point_detail: Label
var status_label: Label
var inspect_button: Button
var return_button: Button
var selected_point_id: String = ""

func _ready() -> void:
	_initialize_region_screen(true)

func _initialize_region_screen(load_saved_state: bool = true) -> void:
	if load_saved_state and not narrative.load():
		get_tree().change_scene_to_file("res://ui/world_map.tscn")
		return
	var current_location := world_map_manager.get_current_location(narrative)
	region_definition = region_manager.get_region_for_location(current_location)
	region_id = str(region_definition.get("id", ""))
	if region_id == "" or not region_manager.can_enter(narrative, region_id):
		if load_saved_state:
			get_tree().change_scene_to_file("res://ui/world_map.tscn")
		return
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("0b0d12")
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
	title.text = "区域探索 · %s" % str(region_definition.get("name", region_id))
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)

	var introduction := Label.new()
	introduction.text = str(region_definition.get("description", "调查周围环境，发现可以留存的线索。"))
	introduction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	introduction.add_theme_font_size_override("font_size", 16)
	root.add_child(introduction)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 16)
	root.add_child(status_label)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)

	var points_title := Label.new()
	points_title.text = "可调查的地点"
	points_title.add_theme_font_size_override("font_size", 20)
	left.add_child(points_title)

	point_list = ItemList.new()
	point_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	point_list.item_selected.connect(_on_point_selected)
	left.add_child(point_list)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 10)
	body.add_child(right)

	var detail_title := Label.new()
	detail_title.text = "现场记录"
	detail_title.add_theme_font_size_override("font_size", 20)
	right.add_child(detail_title)

	point_detail = Label.new()
	point_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	point_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	point_detail.add_theme_font_size_override("font_size", 18)
	right.add_child(point_detail)

	inspect_button = Button.new()
	inspect_button.text = "调查并记录线索"
	inspect_button.custom_minimum_size = Vector2(0, 48)
	inspect_button.pressed.connect(_inspect_selected_point)
	right.add_child(inspect_button)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	root.add_child(footer)

	return_button = Button.new()
	return_button.text = "返回世界地图"
	return_button.custom_minimum_size = Vector2(220, 48)
	return_button.pressed.connect(_return_to_world_map)
	footer.add_child(return_button)

	var rule_label := Label.new()
	rule_label.text = "区域调查只记录线索，不推进共享章节、世界时间线或角色招募。"
	rule_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_child(rule_label)

func _refresh() -> void:
	if point_list == null:
		return
	var points := region_manager.get_points(region_id)
	var discovered := region_manager.get_discovered_point_ids(narrative)
	point_list.clear()
	var found_count := 0
	for point in points:
		var point_id := str(point.get("id", ""))
		var is_found := point_id in discovered
		if is_found:
			found_count += 1
		var marker := "✓" if is_found else "◇"
		point_list.add_item("%s %s" % [marker, str(point.get("name", point_id))])
		point_list.set_item_metadata(point_list.item_count - 1, point_id)
		if point_id == selected_point_id:
			point_list.select(point_list.item_count - 1)
	status_label.text = "线索 %d/%d · 当前区域：%s · 可选探索（不推进西游主线）" % [
		found_count,
		points.size(),
		str(region_definition.get("name", region_id))
	]
	if selected_point_id == "" and not points.is_empty():
		selected_point_id = str(points[0].get("id", ""))
		point_list.select(0)
		_render_selected_point()
	elif selected_point_id != "":
		_render_selected_point()
	else:
		point_detail.text = "此区域暂时没有可调查的地点。"
		inspect_button.disabled = true

func _on_point_selected(index: int) -> void:
	if point_list == null or index < 0 or index >= point_list.item_count:
		return
	selected_point_id = str(point_list.get_item_metadata(index))
	_render_selected_point()

func _render_selected_point() -> void:
	var point := region_manager.get_point(region_id, selected_point_id)
	if point.is_empty():
		point_detail.text = "请选择一处地点。"
		inspect_button.disabled = true
		return
	var is_found := region_manager.is_discovered(narrative, selected_point_id)
	point_detail.text = "%s\n\n%s" % [
		str(point.get("name", selected_point_id)),
		str(point.get("description", ""))
	]
	if is_found:
		point_detail.text += "\n\n已记录：%s" % str(point.get("result_text", "线索已经写入旅途记录。"))
	inspect_button.text = "已记录" if is_found else "调查并记录线索"
	inspect_button.disabled = is_found or not region_manager.can_enter(narrative, region_id)

func _inspect_selected_point() -> void:
	if selected_point_id == "" or not region_manager.can_enter(narrative, region_id):
		status_label.text = "当前无法调查此地点。"
		return
	var state_before: Dictionary = narrative.serialize().duplicate(true)
	var point := region_manager.discover_point(narrative, region_id, selected_point_id)
	if point.is_empty():
		_refresh()
		status_label.text = "这处线索已记录，或当前条件不允许调查。"
		return
	if not narrative.save():
		narrative.restore_snapshot(state_before)
		_refresh()
		status_label.text = "保存失败，调查结果已回滚；可以重试。"
		return
	_refresh()
	status_label.text = str(point.get("result_text", "线索已写入旅途记录。"))

func _return_to_world_map() -> void:
	get_tree().change_scene_to_file("res://ui/world_map.tscn")
