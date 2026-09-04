class_name CampScreen
extends Control

var narrative := NarrativeManager.new()
var status: Label

func _ready() -> void:
	if not narrative.load():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		return
	_build_ui()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new(); bg.color = Color("0d1110"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 80); margin.add_theme_constant_override("margin_right", 80); margin.add_theme_constant_override("margin_top", 60); margin.add_theme_constant_override("margin_bottom", 60); add_child(margin)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation", 16); margin.add_child(root)
	var title := Label.new(); title.text = "营地 · 整顿行装"; title.add_theme_font_size_override("font_size", 32); root.add_child(title)
	var location := Label.new(); location.text = "当前地点：%s" % str(narrative.state.get_world_state().get("current_location", "未知")); root.add_child(location)
	var hint := Label.new(); hint.text = "在安全节点休整，整理战斗记录，并准备下一段路。营地本身不推进西游时间线。"; hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; root.add_child(hint)
	var rest := Button.new(); rest.text = "休整并记录旅途"; rest.custom_minimum_size = Vector2(0, 52); rest.pressed.connect(_rest); root.add_child(rest)
	status = Label.new(); status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; root.add_child(status)
	var back := Button.new(); back.text = "返回世界地图"; back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/world_map.tscn")); root.add_child(back)

func _rest() -> void:
	var result := CampService.rest(narrative)
	if result.get("ok", false):
		status.text = "队伍已完成休整：%d 名当前队员。\n世界时间仍为 T%04d。" % [int(result.get("members_restored", 0)), narrative.state.current_global_timeline]
