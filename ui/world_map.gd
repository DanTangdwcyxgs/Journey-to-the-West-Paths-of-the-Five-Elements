class_name WorldMapScreen
extends Control

const WorldMapManagerScript = preload("res://scripts/world/world_map_manager.gd")

var world := WorldMapManagerScript.new()
var narrative := NarrativeManager.new()
var selected_node_id := ""
var selected_bounty_id := ""
var map_list: ItemList
var detail_label: Label
var bounty_label: Label
var rumor_list: ItemList
var travel_button: Button
var bounty_button: Button
var ridge_button: Button

func _ready() -> void:
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)
	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 20)
	margin.add_child(root)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	left.add_theme_constant_override("separation", 8)
	root.add_child(left)
	var title := Label.new()
	title.text = "大唐取经 · 地图"
	title.add_theme_font_size_override("font_size", 24)
	left.add_child(title)
	map_list = ItemList.new()
	map_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_list.item_selected.connect(_on_map_item_selected)
	left.add_child(map_list)
	var action_row := HBoxContainer.new()
	left.add_child(action_row)
	travel_button = Button.new()
	travel_button.text = "前往"
	travel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	travel_button.pressed.connect(_on_travel)
	action_row.add_child(travel_button)
	ridge_button = Button.new()
	ridge_button.text = "黄风岭"
	ridge_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ridge_button.pressed.connect(_open_ridge)
	action_row.add_child(ridge_button)
	bounty_button = Button.new()
	bounty_button.text = "接取悬赏"
	bounty_button.pressed.connect(_on_bounty)
	left.add_child(bounty_button)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	root.add_child(right)
	detail_label = Label.new()
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 17)
	right.add_child(detail_label)
	bounty_label = Label.new()
	bounty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(bounty_label)
	var rumor_title := Label.new()
	rumor_title.text = "当地传闻"
	rumor_title.add_theme_font_size_override("font_size", 18)
	right.add_child(rumor_title)
	rumor_list = ItemList.new()
	rumor_list.custom_minimum_size = Vector2(0, 180)
	right.add_child(rumor_list)

func _refresh() -> void:
	map_list.clear()
	var current := world.get_current_location(narrative)
	var nodes: Array = world.get_world_map().get("nodes", [])
	for node in nodes:
		if not (node is Dictionary):
			continue
		var label := str(node.get("name", node.get("id", "未知")))
		if str(node.get("id", "")) == current:
			label = "◆ " + label
		map_list.add_item(label)
	_refresh_rumors()
	travel_button.disabled = selected_node_id.is_empty() or selected_node_id == current
	ridge_button.disabled = current != "BLACK_WIND_NORTH_PATH" or not YellowWindRidgeManager.new().is_available(narrative)

func _render_node(node: Dictionary) -> void:
	selected_bounty_id = ""
	if node.is_empty(): detail_label.text = "请选择一个地点。"; bounty_label.text = ""; bounty_button.disabled = true; return
	var current := world.get_current_location(narrative); var state := narrative.state.get_world_state(); var node_id := str(node.get("id","")); var bounties: Array = node.get("bounties",[])
	detail_label.text = "%s\n\n%s\n\n节点时间：T%03d\n连接：%s" % [str(node.get("name",node_id)),str(node.get("description","")),int(node.get("timeline",0)),"、".join(node.get("connections",[]))]
	var bounty_lines:Array[String] = []; var challengeable := false
	for bounty_id in bounties:
		var bid := str(bounty_id); var discovered: bool = bid in state.get("discovered_bounties",[]); var defeated: bool = bid in narrative.state.journey_log.get("defeated_targets",[]); var mark := "✓" if defeated else ("!" if discovered else "?"); bounty_lines.append("%s %s" % [mark,bid])
		if discovered and not defeated and node_id == current and bid == "BOUNTY_YELLOW_FANG": selected_bounty_id = bid; challengeable = true
	bounty_label.text = "悬赏：%s\n" % ("、".join(bounty_lines) if not bounty_lines.is_empty() else "暂无")
	if node_id == current: bounty_label.text += "你正在这里，可以先和当地人打听传闻。"
	bounty_button.disabled = not challengeable
	if not challengeable and not bounties.is_empty(): bounty_label.text += "\n当前没有可直接接战的已发现悬赏。"

func _refresh_rumors() -> void:
	rumor_list.clear(); var rumors:Array = world.get_rumors_at_current_location(narrative)
	for rumor in rumors: rumor_list.add_item("%s：%s" % [str(rumor.get("speaker","路人")),str(rumor.get("text",""))])

func _on_map_item_selected(index: int) -> void:
	var current_nodes: Array = world.get_world_map().get("nodes", [])
	if index >= 0 and index < current_nodes.size():
		var node: Dictionary = current_nodes[index]
		selected_node_id = str(node.get("id", ""))
		_render_node(node)
		travel_button.disabled = selected_node_id == world.get_current_location(narrative)

func _on_travel() -> void:
	if selected_node_id.is_empty(): return
	if world.travel(narrative, selected_node_id):
		narrative.save()
		_refresh()
		_render_node(world.get_world_map().get_node_by_id(selected_node_id) if world.get_world_map().has_method("get_node_by_id") else {})

func _on_bounty() -> void:
	if selected_bounty_id.is_empty(): return
	if BountyPreparation.new().prepare(narrative, selected_bounty_id):
		get_tree().change_scene_to_file("res://ui/bounty_prep.tscn")

func _open_ridge() -> void:
	get_tree().change_scene_to_file("res://ui/yellow_wind_ridge.tscn")
