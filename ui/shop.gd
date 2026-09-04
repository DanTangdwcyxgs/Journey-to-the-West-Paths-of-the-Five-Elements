class_name ShopScreen
extends Control

var narrative := NarrativeManager.new()
var shop := ShopManager.new()
var list: ItemList
var status: Label
var coin_label: Label

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new(); bg.color = Color("101118"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60); margin.add_theme_constant_override("margin_right", 60); margin.add_theme_constant_override("margin_top", 40); margin.add_theme_constant_override("margin_bottom", 40); add_child(margin)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation", 14); margin.add_child(root)
	var title := Label.new(); title.text = "行商小店 · 补给与出发准备"; title.add_theme_font_size_override("font_size", 30); root.add_child(title)
	coin_label = Label.new(); coin_label.add_theme_font_size_override("font_size", 18); root.add_child(coin_label)
	list = ItemList.new(); list.size_flags_vertical = Control.SIZE_EXPAND_FILL; root.add_child(list)
	var buy := Button.new(); buy.text = "购买 1 个"; buy.custom_minimum_size = Vector2(0,48); buy.pressed.connect(_buy); root.add_child(buy)
	status = Label.new(); status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; root.add_child(status)
	var back := Button.new(); back.text = "返回世界地图"; back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/world_map.tscn")); root.add_child(back)

func _refresh() -> void:
	var inventory := narrative.state.get_inventory()
	coin_label.text = "银钱：%d" % int(inventory.get("currencies", {}).get("COIN", 0))
	list.clear()
	for item in shop.get_items():
		var owned := int(inventory.get("items", {}).get(str(item.get("id", "")), 0))
		list.add_item("%s · %d钱 · 已有 %d\n%s" % [str(item.get("name", "")), int(item.get("price", 0)), owned, str(item.get("description", ""))])

func _buy() -> void:
	var selected := list.get_selected_items()
	if selected.is_empty():
		status.text = "先选择一件物品。"
		return
	var items := shop.get_items()
	if selected[0] >= items.size():
		return
	var id := str(items[selected[0]].get("id", ""))
	var result := shop.buy(narrative, id, 1)
	if result.get("ok", false):
		status.text = "购入成功：%s" % str(items[selected[0]].get("name", id))
	else:
		status.text = "购买失败：银钱不足，需要 %d，当前 %d。" % [int(result.get("need", 0)), int(result.get("have", 0))]
	_refresh()
