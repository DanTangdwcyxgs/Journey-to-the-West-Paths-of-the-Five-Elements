class_name VisualOverlay
extends Control

const SKY_TOP := Color("172235")
const SKY_MID := Color("30455b")
const SKY_LOW := Color("7a6f63")
const MOUNTAIN_DARK := Color("1b242b")
const MOUNTAIN_MID := Color("303b42")
const SAND := Color("8f7355")
const ROAD := Color("524840")
const GOLD := Color("c7a56a")
const RED := Color("8f473c")
const JADE := Color("5c8b77")

var scene_name := ""
var applied_root: Node = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = -100
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	_apply_scene_visuals()
	queue_redraw()

func _process(_delta: float) -> void:
	var next_scene := get_tree().current_scene.scene_file_path if get_tree().current_scene != null else ""
	if next_scene != scene_name:
		_apply_scene_visuals()
		queue_redraw()

func _apply_scene_visuals() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	scene_name = root.scene_file_path
	applied_root = root
	# Existing screens were written as pure UI. Make their opaque backdrop
	# translucent so the low-resource illustrated layer can sit underneath.
	for child in root.get_children():
		if child is ColorRect:
			var rect := child as ColorRect
			if rect.size.x >= 900.0 and rect.size.y >= 500.0:
				var c := rect.color
				c.a = 0.18
				rect.color = c

func _draw() -> void:
	if scene_name.ends_with("main_menu.tscn"):
		_draw_main_menu()
	elif scene_name.ends_with("battle_ui.tscn"):
		_draw_battle()
	elif scene_name.ends_with("world_map.tscn"):
		_draw_world_map()
	elif scene_name.ends_with("yellow_wind_ridge.tscn") or scene_name.ends_with("yellow_wind_cave.tscn"):
		_draw_yellow_wind()
	else:
		_draw_journey()

func _draw_sky() -> void:
	var h := size.y
	var band_h := h / 8.0
	for i in range(8):
		var t := float(i) / 7.0
		var c := SKY_TOP.lerp(SKY_LOW, t)
		draw_rect(Rect2(0, band_h * i, size.x, band_h + 2), c)
	var sun_center := Vector2(size.x * 0.77, size.y * 0.24)
	draw_circle(sun_center, 54.0, Color(GOLD, 0.16))
	draw_circle(sun_center, 34.0, Color(GOLD, 0.24))

func _draw_mountains(base_y: float, depth: float) -> void:
	var w := size.x
	var pts := PackedVector2Array([
		Vector2(0, base_y), Vector2(w * 0.10, base_y - depth * 0.55), Vector2(w * 0.22, base_y - depth),
		Vector2(w * 0.34, base_y - depth * 0.44), Vector2(w * 0.48, base_y - depth * 0.86),
		Vector2(w * 0.63, base_y - depth * 0.42), Vector2(w * 0.77, base_y - depth * 0.95),
		Vector2(w * 0.92, base_y - depth * 0.50), Vector2(w, base_y - depth * 0.66), Vector2(w, size.y), Vector2(0, size.y)
	])
	draw_colored_polygon(pts, Color(MOUNTAIN_DARK, 0.92))
	var ridge := PackedVector2Array([
		Vector2(0, base_y + 6), Vector2(w * 0.15, base_y - depth * 0.30), Vector2(w * 0.28, base_y - depth * 0.68),
		Vector2(w * 0.41, base_y - depth * 0.18), Vector2(w * 0.56, base_y - depth * 0.52),
		Vector2(w * 0.70, base_y - depth * 0.14), Vector2(w * 0.84, base_y - depth * 0.65), Vector2(w, base_y - depth * 0.28),
		Vector2(w, size.y), Vector2(0, size.y)
	])
	draw_colored_polygon(ridge, Color(MOUNTAIN_MID, 0.72))

func _draw_main_menu() -> void:
	_draw_sky()
	_draw_mountains(size.y * 0.78, size.y * 0.28)
	_draw_road(size.y * 0.79)
	_draw_tree(Vector2(size.x * 0.08, size.y * 0.70), 1.0)
	_draw_tree(Vector2(size.x * 0.92, size.y * 0.67), 0.85)
	_draw_temple(Vector2(size.x * 0.73, size.y * 0.61), 1.15)
	_draw_character(Vector2(size.x * 0.25, size.y * 0.76), 1.2, "WUKONG")
	_draw_character(Vector2(size.x * 0.34, size.y * 0.79), 0.96, "BAJIE")
	_draw_character(Vector2(size.x * 0.43, size.y * 0.80), 0.96, "WUJING")

func _draw_journey() -> void:
	_draw_sky()
	_draw_mountains(size.y * 0.72, size.y * 0.26)
	_draw_road(size.y * 0.74)
	_draw_character(Vector2(size.x * 0.15, size.y * 0.78), 1.18, "WUKONG")
	_draw_character(Vector2(size.x * 0.25, size.y * 0.80), 1.0, "TANG")
	_draw_character(Vector2(size.x * 0.35, size.y * 0.80), 1.05, "BAJIE")
	_draw_character(Vector2(size.x * 0.45, size.y * 0.81), 1.02, "WUJING")
	_draw_character(Vector2(size.x * 0.55, size.y * 0.81), 1.02, "LONGMA")
	_draw_tree(Vector2(size.x * 0.88, size.y * 0.69), 0.95)

func _draw_world_map() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("1d2528", 0.36))
	for i in range(7):
		var y := size.y * (0.18 + float(i) * 0.11)
		draw_line(Vector2(size.x * 0.10, y), Vector2(size.x * 0.92, y + 18), Color(GOLD, 0.08), 2.0)
	_draw_mountains(size.y * 0.86, size.y * 0.20)
	_draw_route_map()

func _draw_yellow_wind() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(SAND, 0.26))
	for i in range(9):
		var y := size.y * (0.28 + float(i) * 0.06)
		draw_arc(Vector2(size.x * 0.52, y), size.x * (0.28 + float(i) * 0.01), PI * 0.08, PI * 0.92, 32, Color("d1b184", 0.10), 3.0)
	_draw_cave(Vector2(size.x * 0.78, size.y * 0.70), 1.4)
	_draw_character(Vector2(size.x * 0.18, size.y * 0.79), 1.05, "WUKONG")
	_draw_character(Vector2(size.x * 0.27, size.y * 0.80), 1.02, "TANG")

func _draw_battle() -> void:
	_draw_sky()
	_draw_mountains(size.y * 0.70, size.y * 0.22)
	var center := Vector2(size.x * 0.56, size.y * 0.61)
	draw_circle(center, min(size.x, size.y) * 0.28, Color("3b302b", 0.68))
	draw_arc(center, min(size.x, size.y) * 0.28, 0.0, TAU, 64, Color(GOLD, 0.34), 4.0)
	draw_arc(center, min(size.x, size.y) * 0.20, 0.0, TAU, 64, Color(GOLD, 0.16), 2.0)
	_draw_character(Vector2(size.x * 0.34, size.y * 0.69), 1.28, "WUKONG")
	_draw_character(Vector2(size.x * 0.46, size.y * 0.73), 1.0, "TANG")
	_draw_character(Vector2(size.x * 0.78, size.y * 0.67), 1.35, "YELLOW_WIND")
	for i in range(5):
		var spark := center + Vector2(cos(i * 1.256) * 130.0, sin(i * 1.256) * 62.0)
		draw_circle(spark, 3.0, Color(GOLD, 0.45))

func _draw_route_map() -> void:
	var nodes := [
		Vector2(size.x * 0.18, size.y * 0.72), Vector2(size.x * 0.32, size.y * 0.60),
		Vector2(size.x * 0.45, size.y * 0.69), Vector2(size.x * 0.59, size.y * 0.52),
		Vector2(size.x * 0.73, size.y * 0.62), Vector2(size.x * 0.84, size.y * 0.46)
	]
	for i in range(nodes.size() - 1):
		draw_dashed_line(nodes[i], nodes[i + 1], Color(GOLD, 0.38), 3.0, 10.0)
	for i in range(nodes.size()):
		draw_circle(nodes[i], 11.0 if i == 0 else 7.0, Color(GOLD, 0.30))
		draw_arc(nodes[i], 15.0 if i == 0 else 10.0, 0.0, TAU, 24, Color(GOLD, 0.42), 2.0)

func _draw_road(y: float) -> void:
	var w := size.x
	var pts := PackedVector2Array([
		Vector2(w * 0.42, y), Vector2(w * 0.58, y), Vector2(w * 0.72, size.y), Vector2(w * 0.28, size.y)
	])
	draw_colored_polygon(pts, Color(ROAD, 0.72))
	draw_line(Vector2(w * 0.50, y), Vector2(w * 0.50, size.y), Color(GOLD, 0.20), 3.0)

func _draw_tree(base: Vector2, scale_factor: float) -> void:
	var trunk_h := 84.0 * scale_factor
	draw_rect(Rect2(base + Vector2(-8 * scale_factor, -trunk_h), Vector2(16 * scale_factor, trunk_h)), Color("463930", 0.86))
	for p in [Vector2(0,-trunk_h-30),Vector2(-38,-trunk_h+4),Vector2(34,-trunk_h+8)]:
		draw_circle(base + p * scale_factor, 40.0 * scale_factor, Color("27433b", 0.84))

func _draw_temple(base: Vector2, scale_factor: float) -> void:
	var s := scale_factor
	draw_rect(Rect2(base + Vector2(-72,-95) * s, Vector2(144,95) * s), Color("665247", 0.86))
	var roof := PackedVector2Array([base + Vector2(-96,-95)*s, base + Vector2.ZERO*s, base + Vector2(96,-95)*s])
	draw_colored_polygon(roof, Color(RED, 0.84))
	draw_line(base + Vector2(-100,-94)*s, base + Vector2(100,-94)*s, Color(GOLD, 0.68), 5.0)
	for x in [-45.0, -15.0, 15.0, 45.0]:
		draw_rect(Rect2(base + Vector2(x,-82)*s, Vector2(8,82)*s), Color("3a2f2d", 0.84))

func _draw_cave(base: Vector2, scale_factor: float) -> void:
	var r := 120.0 * scale_factor
	draw_circle(base, r, Color("17191d", 0.82))
	draw_arc(base, r, PI, TAU, 40, Color(GOLD, 0.26), 5.0)
	draw_colored_polygon(PackedVector2Array([base + Vector2(-r,0), base + Vector2(-r*0.55, -r*0.25), base + Vector2(r*0.30,-r*0.22), base + Vector2(r,0), base + Vector2(r*0.45,r*0.42), base + Vector2(-r*0.50,r*0.38)]), Color("2b2523",0.58))

func _draw_character(base: Vector2, scale_factor: float, kind: String) -> void:
	var s := scale_factor
	var body := Color(MOUNTAIN_DARK, 0.90)
	var accent := Color(GOLD, 0.60)
	match kind:
		"WUKONG":
			body = Color("6c4b3a", 0.94); accent = Color(GOLD, 0.82)
			draw_line(base + Vector2(35,-86)*s, base + Vector2(44,76)*s, Color(GOLD,0.72), 6.0*s)
		"TANG":
			body = Color("5c6b69", 0.88); accent = Color("d6c6a1",0.72)
		"BAJIE":
			body = Color("65594f", 0.92); accent = Color("a9b4b1",0.70)
		"WUJING":
			body = Color("4f5f67", 0.92); accent = Color(JADE,0.75)
		"LONGMA":
			body = Color("b7b3a5",0.72); accent = Color("d7d6cc",0.80)
		"YELLOW_WIND":
			body = Color("9a7954",0.92); accent = Color(RED,0.78)
	var head := base + Vector2(0,-88)*s
	draw_circle(head, 26*s, Color(body, 0.96))
	var torso := PackedVector2Array([
		base + Vector2(-35,-54)*s, base + Vector2(34,-54)*s,
		base + Vector2(49,62)*s, base + Vector2(-49,62)*s
	])
	draw_colored_polygon(torso, body)
	draw_line(base + Vector2(-28,-12)*s, base + Vector2(28,-12)*s, accent, 4.0*s)
	draw_line(base + Vector2(-20,60)*s, base + Vector2(-28,108)*s, body, 12*s)
	draw_line(base + Vector2(20,60)*s, base + Vector2(28,108)*s, body, 12*s)
	draw_arc(head, 30*s, 0.0, TAU, 24, Color(accent,0.24), 2.0*s)
