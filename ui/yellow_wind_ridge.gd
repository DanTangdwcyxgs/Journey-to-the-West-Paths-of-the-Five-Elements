class_name YellowWindRidgeScreen
extends Control

var narrative := NarrativeManager.new()
var ridge := YellowWindRidgeManager.new()
var stage_list: ItemList
var detail_label: Label
var status_label: Label
var action_box: VBoxContainer
var selected_stage_id := ""

func _ready() -> void:
	if not narrative.load() or not ridge.is_available(narrative):
		get_tree().change_scene_to_file("res://ui/world_map.tscn")
		return
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("111017")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)
	var title := Label.new()
	title.text = "黄风岭 · 风沙险路"
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 16)
	root.add_child(status_label)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	body.add_child(left)
	var list_title := Label.new()
	list_title.text = "行进阶段"
	list_title.add_theme_font_size_override("font_size", 18)
	left.add_child(list_title)
	stage_list = ItemList.new()
	stage_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_list.item_selected.connect(_on_stage_selected)
	left.add_child(stage_list)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	detail_label = Label.new()
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_label.add_theme_font_size_override("font_size", 18)
	center.add_child(detail_label)
	action_box = VBoxContainer.new()
	action_box.add_theme_constant_override("separation", 8)
	center.add_child(action_box)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	root.add_child(footer)
	var back := Button.new()
	back.text = "返回世界地图"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/world_map.tscn"))
	footer.add_child(back)
	var prep := Button.new()
	prep.text = "出战准备"
	prep.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/preparation.tscn"))
	footer.add_child(prep)
	var shop := Button.new()
	shop.text = "补给商店"
	shop.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/shop.tscn"))
	footer.add_child(shop)

func _refresh() -> void:
	var completed := 0
	for stage in ridge.get_stages(narrative):
		if bool(stage.get("completed", false)): completed += 1
	status_label.text = "T%04d · 黄风岭进度 %d/4 · 已招募 %d/5" % [narrative.state.current_global_timeline, completed, narrative.state.recruited_characters.size()]
	stage_list.clear()
	for stage in ridge.get_stages(narrative):
		var id := str(stage.get("id", ""))
		var mark := "✓" if bool(stage.get("completed", false)) else ("▶" if id == selected_stage_id else "○")
		stage_list.add_item("%s %s" % [mark, str(stage.get("name", id))])
		if id == selected_stage_id: stage_list.select(stage_list.item_count - 1)
	if selected_stage_id.is_empty():
		selected_stage_id = str(ridge.get_current_stage(narrative).get("id", ""))
	_render_stage(selected_stage_id)

func _render_stage(stage_id: String) -> void:
	for child in action_box.get_children(): child.queue_free()
	var stage: Dictionary = ridge.get_stage(stage_id)
	if stage.is_empty():
		detail_label.text = "黄风岭的道路已经走完。"
		return
	var completed := narrative.state.completed_milestones.has(str(stage.get("milestone", "")))
	detail_label.text = "%s\n\n%s" % [str(stage.get("name", stage_id)), str(stage.get("description", ""))]
	if completed:
		detail_label.text += "\n\n已完成：风沙已经散去，这一段支线不会重复开启妖王战。"
		return
	var type := str(stage.get("type", "EVENT"))
	if type == "CHOICE":
		for choice in stage.get("choices", []):
			if not choice is Dictionary: continue
			var button := Button.new()
			button.text = str(choice.get("label", choice.get("id", "选择")))
			button.custom_minimum_size = Vector2(0, 50)
			button.pressed.connect(_resolve_choice.bind(stage, choice))
			action_box.add_child(button)
	elif type == "BOSS_GATE":
		_add_dungeon_button()
	else:
		var button := Button.new()
		button.text = "调查并记录情报"
		button.custom_minimum_size = Vector2(0, 50)
		button.pressed.connect(_resolve_event.bind(stage))
		action_box.add_child(button)

func _add_dungeon_button() -> void:
	var button := Button.new()
	button.text = "进入黄风洞 · 灰盒地城"
	button.custom_minimum_size = Vector2(0, 54)
	button.pressed.connect(_enter_dungeon)
	action_box.add_child(button)

func _resolve_choice(stage: Dictionary, choice: Dictionary) -> void:
	ridge.complete_stage(narrative, str(stage.get("id", "")))
	narrative.state.add_world_rumor("YELLOW_RIDGE_%s" % str(choice.get("id", "CHOICE")))
	narrative.save()
	detail_label.text = "%s\n\n%s\n\n选择结果：%s" % [str(stage.get("name", "")), str(stage.get("description", "")), str(choice.get("result", ""))]
	_refresh()

func _resolve_event(stage: Dictionary) -> void:
	ridge.complete_stage(narrative, str(stage.get("id", "")))
	narrative.state.add_world_rumor(str(stage.get("id", "")))
	narrative.save()
	_refresh()

func _enter_dungeon() -> void:
	get_tree().change_scene_to_file("res://ui/yellow_wind_cave.tscn")

func _on_stage_selected(index: int) -> void:
	var stages := ridge.get_stages(narrative)
	if index < 0 or index >= stages.size(): return
	selected_stage_id = str(stages[index].get("id", ""))
	_render_stage(selected_stage_id)
