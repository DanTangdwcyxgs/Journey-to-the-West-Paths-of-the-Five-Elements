class_name WorldMapScreen
extends Control

var narrative := NarrativeManager.new()
var world := WorldMapManager.new()
var node_list: ItemList
var rumor_list: ItemList
var detail_label: Label
var status_label: Label
var travel_button: Button
var rumor_button: Button
var bounty_button: Button
var bounty_label: Label
var selected_node_id := ""
var selected_bounty_id := ""

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	world.ensure_initialized(narrative)
	narrative.save()
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
	title.text = "西游地图 · 行路与传闻"
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
	var node_title := Label.new()
	node_title.text = "可到达地点"
	node_title.add_theme_font_size_override("font_size", 18)
	left.add_child(node_title)
	node_list = ItemList.new()
	node_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node_list.item_selected.connect(_on_node_selected)
	left.add_child(node_list)
	travel_button = Button.new()
	travel_button.text = "前往地点"
	travel_button.custom_minimum_size = Vector2(0, 48)
	travel_button.pressed.connect(_travel)
	left.add_child(travel_button)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)
	detail_label = Label.new()
	detail_label.custom_minimum_size = Vector2(0, 200)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 17)
	center.add_child(detail_label)
	bounty_label = Label.new()
	bounty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center.add_child(bounty_label)
	bounty_button = Button.new()
	bounty_button.text = "接受悬赏并出战"
	bounty_button.custom_minimum_size = Vector2(0, 46)
	bounty_button.pressed.connect(_challenge_bounty)
	center.add_child(bounty_button)
	var rumor_title := Label.new()
	rumor_title.text = "当前位置的新传闻"
	rumor_title.add_theme_font_size_override("font_size", 18)
	center.add_child(rumor_title)
	rumor_list = ItemList.new()
	rumor_list.custom_minimum_size = Vector2(0, 150)
	center.add_child(rumor_list)
	rumor_button = Button.new()
	rumor_button.text = "听取选中传闻"
	rumor_button.custom_minimum_size = Vector2(0, 44)
	rumor_button.pressed.connect(_hear_rumor)
	center.add_child(rumor_button)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	root.add_child(footer)
	var preparation := Button.new(); preparation.text = "出战准备"; preparation.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/preparation.tscn")); footer.add_child(preparation)
	var camp := Button.new(); camp.text = "营地休整"; camp.pressed.connect(_rest_at_camp); footer.add_child(camp)
	var shop := Button.new(); shop.text = "补给商店"; shop.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/shop.tscn")); footer.add_child(shop)
	var party := Button.new(); party.text = "队伍编成"; party.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/party_screen.tscn")); footer.add_child(party)
	var journey := Button.new(); journey.text = "返回行程"; journey.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/journey.tscn")); footer.add_child(journey)
	var menu := Button.new(); menu.text = "主菜单"; menu.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/main_menu.tscn")); footer.add_child(menu)

func _refresh() -> void:
	if node_list == null: return
	var current := world.get_current_location(narrative)
	var world_state := narrative.state.get_world_state()
	var current_node := world.get_node(current)
	status_label.text = "T%04d · 当前：%s · 队伍 %d/5 · 已探索 %d处 · 已知悬赏 %d · 银钱 %d" % [narrative.state.current_global_timeline,str(current_node.get("name","未定")),narrative.state.recruited_characters.size(),world_state.get("visited_nodes",[]).size(),world_state.get("discovered_bounties",[]).size(),int(narrative.state.get_inventory().get("currencies",{}).get("COIN",0))]
	node_list.clear()
	for node in world.get_reachable_nodes(narrative):
		var node_id := str(node.get("id","")); var marker := "★" if node_id == current else "→"; var visited := "· 已到" if node_id in world_state.get("visited_nodes",[]) else "· 未到"; node_list.add_item("%s %s  T%03d  %s" % [marker,str(node.get("name",node_id)),int(node.get("timeline",0)),visited]); if node_id == selected_node_id: node_list.select(node_list.item_count - 1)
	if selected_node_id.is_empty(): selected_node_id = current
	if not selected_node_id.is_empty(): _render_node(world.get_node(selected_node_id))
	_refresh_rumors()
	travel_button.disabled = selected_node_id.is_empty() or selected_node_id == current

func _render_node(node: Dictionary) -> void:
	selected_bounty_id = ""
	if node.is_empty(): detail_label.text = "请选择一个地点。"; bounty_label.text = ""; bounty_button.disabled = true; return
	var current := world.get_current_location(narrative); var state := narrative.state.get_world_state(); var node_id := str(node.get("id","")); var bounties:Array = node.get("bounties",[])
	detail_label.text = "%s\n\n%s\n\n节点时间：T%03d\n连接：%s" % [str(node.get("name",node_id)),str(node.get("description","")),int(node.get("timeline",0)),"、".join(node.get("connections",[]))]
	var bounty_lines:Array[String] = []; var challengeable := false
	for bounty_id in bounties:
		var bid := str(bounty_id); var discovered := bid in state.get("discovered_bounties",[]); var defeated := bid in narrative.state.journey_log.get("defeated_targets",[]); var mark := "✓" if defeated else ("!" if discovered else "?"); bounty_lines.append("%s %s" % [mark,bid])
		if discovered and not defeated and node_id == current and bid == "BOUNTY_YELLOW_FANG": selected_bounty_id = bid; challengeable = true
	bounty_label.text = "悬赏：%s\n" % ("、".join(bounty_lines) if not bounty_lines.is_empty() else "暂无")
	if node_id == current: bounty_label.text += "你正在这里，可以先和当地人打听传闻。"
	bounty_button.disabled = not challengeable
	if not challengeable and not bounties.is_empty(): bounty_label.text += "\n当前没有可直接接战的已发现悬赏。"

func _refresh_rumors() -> void:
	rumor_list.clear(); var rumors:Array = world.get_rumors_at_current_location(narrative)
	for rumor in rumors: rumor_list.add_item("%s：%s" % [str(rumor.get("speaker","路人")),str(rumor.get("text",""))])
	rumor_button.disabled = rumor_list.item_count == 0
	if rumor_list.item_count == 0: rumor_list.add_item("暂无新的传闻。探索新的地点，或推进西游时间线。")

func _on_node_selected(index:int) -> void:
	var reachable := world.get_reachable_nodes(narrative)
	if index < 0 or index >= reachable.size(): return
	selected_node_id = str(reachable[index].get("id","")); _render_node(reachable[index]); travel_button.disabled = selected_node_id == world.get_current_location(narrative)

func _travel() -> void:
	if selected_node_id.is_empty(): return
	if world.visit(narrative, selected_node_id): narrative.save(); _refresh(); status_label.text += " · 已抵达"

func _hear_rumor() -> void:
	var selected := rumor_list.get_selected_items()
	if selected.is_empty(): return
	var rumors:Array = world.get_rumors_at_current_location(narrative)
	if selected[0] >= rumors.size(): return
	var rumor:Dictionary = world.hear_rumor(narrative,str(rumors[selected[0]].get("id","")))
	if rumor.is_empty(): return
	narrative.save(); _refresh(); status_label.text += " · 已获得情报：%s" % str(rumor.get("reward_intel",""))

func _challenge_bounty() -> void:
	if selected_bounty_id.is_empty(): return
	if not BountyEncounterState.start(selected_bounty_id): status_label.text = "无法建立悬赏战斗。"; return
	get_tree().change_scene_to_file("res://ui/battle_ui.tscn")

func _rest_at_camp() -> void:
	var result := CampService.rest(narrative)
	if result.get("ok", false):
		status_label.text = "已在当前地点休整，并写入营火记录。"
	else:
		status_label.text = "暂时无法休整。"
