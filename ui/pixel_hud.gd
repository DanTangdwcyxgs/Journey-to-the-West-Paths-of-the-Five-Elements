class_name PixelHUD
extends Control

const BG := Color("071018")
const INK := Color("0a121a")
const CYAN := Color("72d8d2")
const CYAN_DIM := Color("315d67")
const GOLD := Color("d8aa57")
const RED := Color("a94b43")
const TEXT := Color("d9eee9")
const MUTED := Color("81979a")
const FONT_PATH := "res://fonts/NotoSansSC-Regular.otf"

var scene_name := ""
var font: Font
var theme_applied_to := ""

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 200
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	font = load(FONT_PATH) as Font
	_process_scene()

func _process(_delta: float) -> void:
	_process_scene()

func _process_scene() -> void:
	var root := get_tree().current_scene
	var next := root.scene_file_path if root != null else ""
	if next == scene_name:
		return
	scene_name = next
	if root != null:
		root.theme = PixelUI.build_theme()
		theme_applied_to = scene_name
	queue_redraw()

func _cut_rect(rect: Rect2, cut := 12.0) -> PackedVector2Array:
	var x := rect.position.x
	var y := rect.position.y
	var w := rect.size.x
	var h := rect.size.y
	var c := min(cut, min(w, h) * 0.22)
	return PackedVector2Array([
		Vector2(x + c, y), Vector2(x + w - c, y),
		Vector2(x + w, y + c), Vector2(x + w, y + h - c),
		Vector2(x + w - c, y + h), Vector2(x + c, y + h),
		Vector2(x, y + h - c), Vector2(x, y + c)
	])

func _frame(rect: Rect2, accent := CYAN, cut := 12.0, fill_alpha := 0.16) -> void:
	if rect.size.x < 20.0 or rect.size.y < 14.0:
		return
	var outer := _cut_rect(rect, cut)
	var inner := _cut_rect(rect.grow(-4.0), max(6.0, cut - 3.0))
	draw_colored_polygon(outer, Color(INK, fill_alpha))
	draw_polyline(outer + PackedVector2Array([outer[0]]), Color(CYAN_DIM, 0.92), 2.0, true)
	draw_polyline(inner + PackedVector2Array([inner[0]]), Color(accent, 0.70), 1.0, true)
	for p in [Vector2(rect.position.x + 7, rect.position.y + rect.size.y * 0.5), Vector2(rect.end.x - 10, rect.position.y + rect.size.y * 0.5)]:
		draw_rect(Rect2(p, Vector2(3, 3)), Color(accent, 0.78))
	for x in range(int(rect.position.x + cut + 9), int(max(rect.position.x + cut + 9, rect.end.x - cut - 6)), 11):
		draw_rect(Rect2(float(x), rect.position.y + 5, 3, 2), Color(accent, 0.24))

func _text(pos: Vector2, value: String, size := 15, color := TEXT) -> void:
	if font == null:
		return
	draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _bar(rect: Rect2, ratio: float, accent := CYAN, segments := 16) -> void:
	var safe := clamp(ratio, 0.0, 1.0)
	var gap := 2.0
	var width := max(1.0, (rect.size.x - gap * float(segments - 1)) / float(segments))
	for i in range(segments):
		var x := rect.position.x + float(i) * (width + gap)
		var filled := float(i) / float(segments) < safe
		draw_rect(Rect2(x, rect.position.y, width, rect.size.y), Color(accent, 0.85 if filled else 0.14))

func _draw() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	if scene_name.ends_with("battle_ui.tscn"):
		_draw_battle(root)
	elif scene_name.ends_with("journey.tscn"):
		_draw_journey(root)
	elif scene_name.ends_with("main_menu.tscn"):
		_draw_main_menu(root)
	elif scene_name.ends_with("world_map.tscn"):
		_draw_world_map(root)
	elif scene_name.ends_with("yellow_wind_ridge.tscn") or scene_name.ends_with("yellow_wind_cave.tscn"):
		_draw_yellow_wind()

func _draw_main_menu(_root: Node) -> void:
	_frame(Rect2(34, 106, 320, size.y - 178), CYAN, 16, 0.10)
	_frame(Rect2(374, 106, size.x - 690, size.y - 178), GOLD, 18, 0.08)
	_frame(Rect2(size.x - 296, 106, 262, size.y - 178), CYAN, 16, 0.10)
	_text(Vector2(48, 98), "CHARACTER SELECT // ORIGIN ROUTES", 13, CYAN)
	_text(Vector2(size.x - 280, 98), "MEMORY // SAVE DATA", 13, GOLD)
	for i in range(9):
		var x := size.x * 0.38 + i * 43.0
		draw_rect(Rect2(x, 53 + (i % 2) * 3, 32, 2), Color(CYAN, 0.30))

func _draw_journey(root: Node) -> void:
	_frame(Rect2(34, 30, size.x - 68, 64), CYAN, 14, 0.10)
	_frame(Rect2(42, size.y - 276, size.x - 84, 236), GOLD, 18, 0.20)
	_frame(Rect2(size.x - 410, 112, 376, size.y - 406), CYAN, 16, 0.07)
	_text(Vector2(54, 69), "JOURNEY // FIVE ELEMENTS ROAD", 14, CYAN)
	_text(Vector2(size.x - 390, 140), "TIMELINE // PARTY // WORLD", 12, GOLD)
	for i in range(14):
		var x := 66.0 + float(i) * 72.0
		draw_rect(Rect2(x, 112, 44, 2), Color(CYAN, 0.25))
		if i % 3 == 0:
			draw_rect(Rect2(x + 17, 108, 8, 8), Color(CYAN, 0.50))

func _draw_battle(root: Node) -> void:
	_frame(Rect2(18, 16, size.x - 36, 76), CYAN, 16, 0.04)
	_frame(Rect2(size.x - 390, 104, 362, 112), GOLD, 16, 0.18)
	_frame(Rect2(18, size.y - 136, 330, 112), CYAN, 16, 0.18)
	_frame(Rect2(size.x * 0.37, size.y - 220, 330, 196), GOLD, 18, 0.22)
	_frame(Rect2(size.x - 306, size.y - 136, 278, 112), CYAN, 16, 0.18)
	_draw_turn_strip(root)
	_draw_target_box(root)
	_draw_team_box(root)
	_draw_command_header()

func _draw_turn_strip(root: Node) -> void:
	_text(Vector2(32, 45), "TURN //", 12, CYAN)
	var actors: Array = []
	if "allies" in root and root.allies != null:
		actors.append_array(root.allies)
	if "enemies" in root and root.enemies != null:
		actors.append_array(root.enemies)
	var max_count := min(7, actors.size())
	var start_x := 122.0
	for i in range(max_count):
		var x := start_x + float(i) * 82.0
		var live: bool = actors[i].is_alive() if actors[i] is Combatant else true
		draw_rect(Rect2(x, 28, 60, 18), Color(CYAN if live else CYAN_DIM, 0.20))
		draw_rect(Rect2(x, 28, 3, 18), Color(GOLD if i == 0 else CYAN, 0.90))
		_text(Vector2(x + 7, 42), str(i + 1).pad_zeros(2), 10, TEXT if live else MUTED)
	_text(Vector2(size.x - 255, 45), "ORDER // ACTION QUEUE", 11, MUTED)

func _draw_target_box(root: Node) -> void:
	var target_name := "TARGET // UNKNOWN"
	var hp_ratio := 1.0
	var shield_ratio := 0.0
	if "selected_target" in root and root.selected_target != null:
		target_name = "TARGET // %s" % str(root.NAMES.get(root.selected_target.id, root.selected_target.id)).to_upper()
		hp_ratio = float(root.selected_target.hp) / float(max(1, root.selected_target.max_hp))
		shield_ratio = float(root.selected_target.shield) / float(max(1, root.selected_target.max_shield))
	_text(Vector2(size.x - 370, 132), target_name, 16, GOLD)
	_text(Vector2(size.x - 370, 157), "HP", 12, TEXT)
	_bar(Rect2(size.x - 332, 148, 270, 9), hp_ratio, GOLD, 18)
	_text(Vector2(size.x - 370, 181), "WEAK // [金] [火]", 12, CYAN)
	_text(Vector2(size.x - 370, 201), "SHIELD", 12, TEXT)
	_bar(Rect2(size.x - 312, 192, 250, 7), shield_ratio, RED, 14)

func _draw_team_box(root: Node) -> void:
	var actor_name := "WUKONG"
	var hp_ratio := 1.0
	if "selected_ally" in root and root.selected_ally != null:
		actor_name = str(root.NAMES.get(root.selected_ally.id, root.selected_ally.id)).to_upper()
		hp_ratio = float(root.selected_ally.hp) / float(max(1, root.selected_ally.max_hp))
	_text(Vector2(34, size.y - 105), "%s // FRAME STATUS" % actor_name, 14, CYAN)
	_text(Vector2(34, size.y - 78), "HP", 12, TEXT)
	_bar(Rect2(72, size.y - 86, 248, 9), hp_ratio, CYAN, 16)
	_text(Vector2(34, size.y - 53), "MP / BP", 12, TEXT)
	_text(Vector2(112, size.y - 53), "|||||||||-------", 12, GOLD)
	_text(Vector2(34, size.y - 33), "HEAT // LOW HEAT", 11, GOLD)

func _draw_command_header() -> void:
	var x := size.x * 0.37 + 22.0
	_text(Vector2(x, size.y - 190), "[ A ]  COMMAND // ACT", 15, CYAN)
	_text(Vector2(x + 235, size.y - 190), "BOOST", 11, GOLD)

func _draw_world_map(_root: Node) -> void:
	_frame(Rect2(34, 104, 346, size.y - 160), CYAN, 16, 0.12)
	_frame(Rect2(396, 104, size.x - 430, size.y - 160), GOLD, 18, 0.08)
	_frame(Rect2(34, 28, size.x - 68, 58), CYAN, 14, 0.10)
	_text(Vector2(52, 63), "WORLD MAP // JOURNEY TIMELINE", 14, CYAN)
	_text(Vector2(414, 132), "ROUTE // INTEL // BOUNTY", 12, GOLD)
	for i in range(10):
		var x := 435.0 + float(i) * 55.0
		draw_rect(Rect2(x, 676, 32, 2), Color(GOLD, 0.24))

func _draw_yellow_wind() -> void:
	_frame(Rect2(20, 18, size.x - 40, 60), CYAN, 14, 0.06)
	_frame(Rect2(size.x - 350, 96, 322, 116), GOLD, 16, 0.16)
	_text(Vector2(38, 56), "YELLOW WIND // RIDGE", 14, CYAN)
	_text(Vector2(size.x - 332, 124), "THREAT // WIND DEMON", 14, GOLD)
	_bar(Rect2(size.x - 332, 151, 270, 9), 0.72, RED, 18)
	_text(Vector2(size.x - 332, 187), "WEAK // [金] [火]", 12, CYAN)
