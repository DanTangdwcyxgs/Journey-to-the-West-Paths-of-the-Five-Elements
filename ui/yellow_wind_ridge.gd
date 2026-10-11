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
	var stages := ridge.get_stages(narrative)
	var completed := 0
	var current_stage := ridge.get_current_stage(narrative)
	for stage in stages:
		if bool(stage.get("completed", false)):
			completed += 1
	if selected_stage_id.is_empty():
		selected_stage_id = str(current_stage.get("id", ""))
	status_label.text = "T%04d · 黄风岭进度 %d/4 · 已招募 %d/5" % [narrative.state.current_global_timeline, completed, narrative.state.recruited_characters.size()]
	stage_list.clear()
	for stage in stages:
		var id := str(stage.get("id", ""))
		var mark := "✓" if bool(stage.get("completed", false)) else ("▶" if id == selected_stage_id else "○")
		var label := "%s %s" % [mark, str(stage.get("name", id))]
		if not bool(stage.get("available", false)):
			label += " · 未解锁"
		stage_list.add_item(label)
		if id == selected_stage_id:
			stage_list.select(stage_list.item_count - 1)
	_render_stage(selected_stage_id)

func _render_stage(stage_id: String) -> void:
	for child in action_box.get_children():
		child.queue_free()
	var stage: Dictionary = ridge.get_stage(stage_id, narrative)
	if stage.is_empty():
		detail_label.text = "黄风岭的道路已经走完。"
		return
	detail_label.text = "%s\n\n%s" % [str(stage.get("name", stage_id)), str(stage.get("description", ""))]
	if bool(stage.get("completed", false)):
		detail_label.text += "\n\n已完成：这一段进度已记录。"
		return
	if not ridge.can_enter_stage(narrative, stage_id):
		detail_label.text += "\n\n请先完成当前阶段，再继续前进。"
		return
	var type := str(stage.get("type", "EVENT")).to_upper()
	if type == "CHOICE":
		for choice_variant in stage.get("choices", []):
			if not choice_variant is Dictionary:
				continue
			var choice: Dictionary = choice_variant
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
	var stage_id := str(stage.get("id", ""))
	var expected_choice_found := false
	for choice_variant in stage.get("choices", []):
		if choice_variant is Dictionary and str(choice_variant.get("id", "")) == str(choice.get("id", "")):
			expected_choice_found = true
			break
	if not expected_choice_found:
		status_label.text += " · 无效选择，未修改进度"
		return
	var choice_id := str(choice.get("id", "CHOICE"))
	if _commit_stage(stage_id, "YELLOW_RIDGE_%s" % choice_id):
		status_label.text += " · %s" % str(choice.get("result", ""))

func _resolve_event(stage: Dictionary) -> void:
	var stage_id := str(stage.get("id", ""))
	if str(stage.get("type", "")).to_upper() == "BOSS_GATE":
		status_label.text += " · 请先完成黄风洞战斗"
		return
	_commit_stage(stage_id, stage_id)

func _commit_stage(stage_id: String, rumor_id: String) -> bool:
	if not ridge.can_enter_stage(narrative, stage_id):
		status_label.text += " · 当前阶段已变化，请刷新后继续"
		return false
	var state_before: Dictionary = narrative.serialize().duplicate(true)
	if ridge.complete_stage(narrative, stage_id).is_empty():
		status_label.text += " · 当前阶段无法完成"
		return false
	if not rumor_id.is_empty():
		narrative.state.add_world_rumor(rumor_id)
	if not narrative.save():
		narrative.restore_snapshot(state_before)
		_refresh()
		status_label.text += " · 保存失败，进度已回滚；可以重试"
		return false
	selected_stage_id = str(ridge.get_current_stage(narrative).get("id", ""))
	_refresh()
	return true

func _enter_dungeon() -> void:
	var state_before: Dictionary = narrative.serialize().duplicate(true)
	if not ridge.open_gate(narrative):
		status_label.text += " · 尚未到达黄风洞入口，不能进入"
		return
	if not narrative.save():
		narrative.restore_snapshot(state_before)
		_refresh()
		status_label.text += " · 保存失败，洞口进度已回滚；可以重试"
		return
	_change_to_cave()

func _change_to_cave() -> void:
	get_tree().change_scene_to_file("res://ui/yellow_wind_cave.tscn")

func _on_stage_selected(index: int) -> void:
	var stages := ridge.get_stages(narrative)
	if index < 0 or index >= stages.size():
		return
	var requested_id := str(stages[index].get("id", ""))
	if not ridge.can_enter_stage(narrative, requested_id):
		selected_stage_id = str(ridge.get_current_stage(narrative).get("id", ""))
		_refresh()
		status_label.text += " · 请先完成当前阶段"
		return
	selected_stage_id = requested_id
	_render_stage(selected_stage_id)
