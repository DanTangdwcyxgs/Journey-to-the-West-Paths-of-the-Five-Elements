class_name BountyPrepScreen
extends Control

const BOUNTY_PATH := "res://data/world/bounties.json"
const LOADOUT_PATH := "res://data/items/loadout_profiles.json"

var narrative := NarrativeManager.new()
var bounty_defs: Dictionary = {}
var loadouts := LoadoutManager.new()
var list: ItemList
var detail: Label
var status: Label

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	_load_json(BOUNTY_PATH, "bounties", bounty_defs)
	_load_loadouts()
	_build_ui()
	_refresh()

func _load_json(path: String, key: String, target: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	for entry in parsed.get(key, []):
		if entry is Dictionary and str(entry.get("id", "")) != "":
			target[str(entry.get("id", ""))] = entry.duplicate(true)

func _load_loadouts() -> void:
	var file := FileAccess.open(LOADOUT_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		loadouts.load_definitions(parsed)

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new(); bg.color = Color("111014"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 50); margin.add_theme_constant_override("margin_right", 50); margin.add_theme_constant_override("margin_top", 35); margin.add_theme_constant_override("margin_bottom", 35); add_child(margin)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation", 12); margin.add_child(root)
	var title := Label.new(); title.text = "悬赏准备 · 看清弱点再出手"; title.add_theme_font_size_override("font_size", 30); root.add_child(title)
	list = ItemList.new(); list.size_flags_vertical = Control.SIZE_EXPAND_FILL; list.item_selected.connect(_select); root.add_child(list)
	detail = Label.new(); detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; detail.custom_minimum_size = Vector2(0, 210); root.add_child(detail)
	status = Label.new(); status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; root.add_child(status)
	var back := Button.new(); back.text = "返回世界地图"; back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/world_map.tscn")); root.add_child(back)

func _refresh() -> void:
	list.clear()
	var discovered: Array = narrative.state.get_world_state().get("discovered_bounties", [])
	for id in discovered:
		if bounty_defs.has(str(id)):
			var bounty: Dictionary = bounty_defs[str(id)]
			list.add_item("[%s] %s · 推荐等级 %d" % [str(bounty.get("tier", "?")), str(bounty.get("name", id)), int(bounty.get("recommended_level", 0))])
	status.text = "已发现悬赏：%d · 这里负责战前判断，不会自动修改装备。" % discovered.size()
	if list.item_count == 0:
		detail.text = "暂时没有已发现的悬赏。先去世界地图听传闻。"
	else:
		_select(0)

func _select(index: int) -> void:
	var discovered: Array = narrative.state.get_world_state().get("discovered_bounties", [])
	if index < 0 or index >= discovered.size():
		return
	var id := str(discovered[index])
	if not bounty_defs.has(id):
		return
	var bounty: Dictionary = bounty_defs[id]
	var report := BountyPreparation.build_report(bounty, loadouts)
	detail.text = "%s\n\n弱点：%s\n护盾：%d\n可撤退：%s\n\n推荐配置：%s\n当前配置：%s" % [
		str(bounty.get("name", id)),
		", ".join(report.get("weaknesses", [])),
		int(bounty.get("battle_profile", {}).get("shield", 0)),
		"是" if report.get("can_retreat", true) else "否",
		", ".join(report.get("recommended_profiles", [])) if not report.get("recommended_profiles", []).is_empty() else "暂无命中标签的方案",
		str(report.get("current_loadouts", {})),
	]
