class_name YellowWindCaveScreen
extends Control

const DATA_PATH := "res://data/dungeons/yellow_wind_cave.json"

var narrative := NarrativeManager.new()
var rooms: Array = []
var current_room_index := 0
var room_list: ItemList
var detail_label: Label
var action_box: VBoxContainer
var status_label: Label

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	_load_data()
	if rooms.is_empty():
		get_tree().change_scene_to_file("res://ui/yellow_wind_ridge.tscn")
		return
	_build_ui()
	_refresh()

func _load_data() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		rooms = parsed.get("rooms", [])

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("0f1118")
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
	title.text = "黄风洞 · 第一座灰盒地城"
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)
	status_label = Label.new()
	root.add_child(status_label)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(360, 0)
	body.add_child(left)
	var map_title := Label.new()
	map_title.text = "房间路线"
	map_title.add_theme_font_size_override("font_size", 18)
	left.add_child(map_title)
	room_list = ItemList.new()
	room_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	room_list.item_selected.connect(_on_room_selected)
	left.add_child(room_list)
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
	root.add_child(footer)
	var back := Button.new()
	back.text = "返回黄风岭"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/yellow_wind_ridge.tscn"))
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
	status_label.text = "黄风洞进度 · 房间 %d/%d · 当前阶段：%s" % [current_room_index + 1, rooms.size(), str(rooms[current_room_index].get("name", "未知"))]
	room_list.clear()
	for i in range(rooms.size()):
		var room: Dictionary = rooms[i]
		var mark := "▶" if i == current_room_index else ("✓" if i < current_room_index else "○")
		room_list.add_item("%s %s" % [mark, str(room.get("name", "房间"))])
	_render_room()

func _render_room() -> void:
	for child in action_box.get_children(): child.queue_free()
	var room: Dictionary = rooms[current_room_index]
	detail_label.text = "%s\n\n%s" % [str(room.get("name", "")), str(room.get("description", ""))]
	var room_type := str(room.get("type", "EXPLORE"))
	if room_type == "CHOICE":
		for choice in room.get("choices", []):
			if not choice is Dictionary: continue
			var button := Button.new()
			button.text = str(choice.get("label", choice.get("id", "选择")))
			button.custom_minimum_size = Vector2(0, 50)
			button.pressed.connect(_resolve_choice.bind(choice))
			action_box.add_child(button)
	elif room_type == "BOSS":
		var boss := Button.new()
		boss.text = "进入黄风妖王战场"
		boss.custom_minimum_size = Vector2(0, 54)
		boss.pressed.connect(_enter_boss)
		action_box.add_child(boss)
	else:
		var investigate := Button.new()
		investigate.text = "搜索并继续前进"
		investigate.custom_minimum_size = Vector2(0, 50)
		investigate.pressed.connect(_advance_room)
		action_box.add_child(investigate)

func _advance_room() -> void:
	if current_room_index >= rooms.size() - 1:
		return
	narrative.state.add_world_rumor("YELLOW_WIND_CAVE_%s" % str(rooms[current_room_index].get("id", "ROOM")))
	current_room_index += 1
	narrative.save()
	_refresh()

func _resolve_choice(choice: Dictionary) -> void:
	narrative.state.add_world_rumor("YELLOW_WIND_CAVE_%s" % str(choice.get("id", "CHOICE")))
	if current_room_index < rooms.size() - 1:
		current_room_index += 1
	narrative.save()
	_refresh()

func _enter_boss() -> void:
	if BountyEncounterState.start("BOUNTY_YELLOW_FANG", "YELLOW_WIND_GATE"):
		get_tree().change_scene_to_file("res://ui/battle_ui.tscn")

func _on_room_selected(index: int) -> void:
	if index < 0 or index >= rooms.size():
		return
	if index <= current_room_index:
		current_room_index = index
		_refresh()
