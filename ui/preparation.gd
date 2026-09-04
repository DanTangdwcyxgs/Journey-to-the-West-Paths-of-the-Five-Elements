class_name PreparationScreen
extends Control

const NAMES := {"TANG":"唐三藏", "WUKONG":"孙悟空", "BAJIE":"猪八戒", "WUJING":"沙悟净", "LONGMA":"白龙马"}

var narrative := NarrativeManager.new()
var loadout := LoadoutManager.new()
var character_list: ItemList
var profile_list: ItemList
var detail_label: Label
var status_label: Label
var equip_button: Button
var selected_character := ""

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	loadout.restore_from_narrative(narrative)
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new(); bg.color = Color("101118"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); margin.add_theme_constant_override("margin_left",50); margin.add_theme_constant_override("margin_right",50); margin.add_theme_constant_override("margin_top",34); margin.add_theme_constant_override("margin_bottom",34); add_child(margin)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation",12); margin.add_child(root)
	var title := Label.new(); title.text = "出战准备 · 装备方案"; title.add_theme_font_size_override("font_size",30); root.add_child(title)
	status_label = Label.new(); root.add_child(status_label)
	var body := HBoxContainer.new(); body.size_flags_vertical = Control.SIZE_EXPAND_FILL; body.add_theme_constant_override("separation",16); root.add_child(body)
	var left := VBoxContainer.new(); left.custom_minimum_size = Vector2(260,0); body.add_child(left)
	var lt := Label.new(); lt.text = "队员"; lt.add_theme_font_size_override("font_size",18); left.add_child(lt)
	character_list = ItemList.new(); character_list.size_flags_vertical = Control.SIZE_EXPAND_FILL; character_list.item_selected.connect(_on_character_selected); left.add_child(character_list)
	var center := VBoxContainer.new(); center.size_flags_horizontal = Control.SIZE_EXPAND_FILL; body.add_child(center)
	detail_label = Label.new(); detail_label.custom_minimum_size = Vector2(0,110); detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; center.add_child(detail_label)
	var pt := Label.new(); pt.text = "可选方案"; pt.add_theme_font_size_override("font_size",18); center.add_child(pt)
	profile_list = ItemList.new(); profile_list.size_flags_vertical = Control.SIZE_EXPAND_FILL; profile_list.item_selected.connect(_on_profile_selected); center.add_child(profile_list)
	equip_button = Button.new(); equip_button.text = "装备该方案"; equip_button.custom_minimum_size = Vector2(0,48); equip_button.pressed.connect(_equip); center.add_child(equip_button)
	var right := VBoxContainer.new(); right.custom_minimum_size = Vector2(320,0); body.add_child(right)
	var rt := Label.new(); rt.text = "当前配置"; rt.add_theme_font_size_override("font_size",18); right.add_child(rt)
	var current := Label.new(); current.name = "CurrentLabel"; current.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; current.size_flags_vertical = Control.SIZE_EXPAND_FILL; right.add_child(current)
	var bottom := HBoxContainer.new(); root.add_child(bottom)
	var back := Button.new(); back.text = "返回世界地图"; back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/world_map.tscn")); bottom.add_child(back)
	var save := Button.new(); save.text = "保存"; save.pressed.connect(_save); bottom.add_child(save)

func _refresh() -> void:
	character_list.clear()
	for character_id in narrative.state.recruited_characters:
		character_list.add_item(str(NAMES.get(character_id,character_id)))
	if selected_character.is_empty() and not narrative.state.recruited_characters.is_empty():
		selected_character = str(narrative.state.recruited_characters[0])
	if not selected_character.is_empty():
		_render_character()
	var current := get_node_or_null("Nope")
	var label := find_child("CurrentLabel", true, false) as Label
	if label != null:
		var lines:Array[String] = []
		for character_id in narrative.state.recruited_characters:
			var profile := loadout.get_equipped_profile(str(character_id)); lines.append("%s：%s" % [str(NAMES.get(character_id,character_id)),str(profile.get("name","未装备"))])
		label.text = "\n".join(lines) if not lines.is_empty() else "暂无队伍成员。"

func _render_character() -> void:
	profile_list.clear()
	var equipped := loadout.get_equipped_profile(selected_character)
	detail_label.text = "%s\n当前方案：%s" % [str(NAMES.get(selected_character,selected_character)),str(equipped.get("name","未装备"))]
	for profile in loadout.definitions.values():
		if str(profile.get("character_id","")) != selected_character: continue
		var marker := "★" if str(profile.get("id","")) == str(equipped.get("id","")) else "·"
		profile_list.add_item("%s %s · %s\n%s\n取舍：%s" % [marker,str(profile.get("name",profile.get("id",""))),str(profile.get("purpose","")),str(profile.get("effects",{})),"、".join(profile.get("tradeoffs",[]))])

func _on_character_selected(index:int) -> void:
	if index < 0 or index >= narrative.state.recruited_characters.size(): return
	selected_character = str(narrative.state.recruited_characters[index]); _render_character()

func _on_profile_selected(_index:int) -> void:
	equip_button.disabled = false

func _equip() -> void:
	var selected := profile_list.get_selected_items()
	if selected.is_empty() or selected[0] >= profile_list.item_count or selected_character.is_empty(): return
	var profiles:Array = []
	for profile in loadout.definitions.values():
		if str(profile.get("character_id","")) == selected_character: profiles.append(profile)
	profiles.sort_custom(func(a,b): return str(a.get("id","")) < str(b.get("id","")))
	if selected[0] >= profiles.size(): return
	if loadout.equip(str(profiles[selected[0]].get("id",""))):
		status_label.text = "已装备：%s" % str(profiles[selected[0]].get("name","")); _refresh()

func _save() -> void:
	if loadout.save_to_narrative(narrative): status_label.text = "出战方案已保存。"
	else: status_label.text = "保存失败。"
