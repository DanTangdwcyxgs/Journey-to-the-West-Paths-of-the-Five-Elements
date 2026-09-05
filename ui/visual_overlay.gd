class_name VisualOverlay
extends Control

const JOURNEY_SCENE := "res://assets/art/scenes/journey_scenery.svg"
const BATTLE_SCENE := "res://assets/art/scenes/yellow_wind_battle.svg"
const MAP_SCENE := "res://assets/art/scenes/journey_map.svg"

const SPRITES := {
	"WUKONG": "res://assets/art/characters/wukong.svg",
	"TANG": "res://assets/art/characters/tang.svg",
	"BAJIE": "res://assets/art/characters/bajie.svg",
	"WUJING": "res://assets/art/characters/wujing.svg",
	"LONGMA": "res://assets/art/characters/longma.svg",
	"YELLOW_WIND": "res://assets/art/characters/yellow_wind.svg",
}

const INK := Color("15151b")
const PAPER := Color("d2bd89")
const GOLD := Color("d5ad57")
const RED := Color("8f3f39")

var scene_name := ""
var background_texture: Texture2D
var sprite_textures: Dictionary = {}
var pixel_hud: PixelHUD

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = -100
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for key in SPRITES:
		sprite_textures[key] = load(SPRITES[key])
	pixel_hud = PixelHUD.new()
	pixel_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pixel_hud.z_index = 200
	add_child(pixel_hud)
	_apply_scene_visuals()
	queue_redraw()

func _process(_delta: float) -> void:
	var root := get_tree().current_scene
	var next_scene := root.scene_file_path if root != null else ""
	if next_scene != scene_name:
		_apply_scene_visuals()
		queue_redraw()

func _apply_scene_visuals() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	scene_name = root.scene_file_path
	background_texture = null
	if scene_name.ends_with("main_menu.tscn") or scene_name.ends_with("journey.tscn"):
		background_texture = load(JOURNEY_SCENE)
	elif scene_name.ends_with("battle_ui.tscn"):
		background_texture = load(BATTLE_SCENE)
	elif scene_name.ends_with("world_map.tscn"):
		background_texture = load(MAP_SCENE)
	elif scene_name.ends_with("yellow_wind_ridge.tscn") or scene_name.ends_with("yellow_wind_cave.tscn"):
		background_texture = load(BATTLE_SCENE)
	for child in root.get_children():
		if child is ColorRect:
			var rect := child as ColorRect
			if rect.size.x >= 900.0 and rect.size.y >= 500.0:
				var c := rect.color
				c.a = min(c.a, 0.30)
				rect.color = c

func _draw() -> void:
	if background_texture != null:
		draw_texture_rect(background_texture, Rect2(Vector2.ZERO, size), false)
	if scene_name.ends_with("main_menu.tscn"):
		_draw_main_menu_stage()
	elif scene_name.ends_with("battle_ui.tscn"):
		_draw_battle_stage()
	elif scene_name.ends_with("world_map.tscn"):
		_draw_map_details()
	elif scene_name.ends_with("yellow_wind_ridge.tscn") or scene_name.ends_with("yellow_wind_cave.tscn"):
		_draw_yellow_wind_stage()
	else:
		_draw_journey_stage()

func _draw_main_menu_stage() -> void:
	_draw_sprite("WUKONG", Vector2(size.x * 0.18, size.y * 0.70), 2.35)
	_draw_sprite("TANG", Vector2(size.x * 0.29, size.y * 0.73), 2.05)
	_draw_sprite("BAJIE", Vector2(size.x * 0.40, size.y * 0.76), 2.25)
	_draw_sprite("WUJING", Vector2(size.x * 0.51, size.y * 0.76), 2.15)
	_draw_sprite("LONGMA", Vector2(size.x * 0.67, size.y * 0.73), 2.0)
	_draw_title_ornament()

func _draw_journey_stage() -> void:
	var journey := get_tree().current_scene as JourneyScreen
	var is_origin: bool = journey != null and journey.narrative != null and journey.narrative.state != null and journey.narrative.state.route_progress.get(journey.narrative.state.starting_character, NarrativeState.ROUTE_LOCKED) != NarrativeState.ROUTE_COMPLETE
	if is_origin:
		var hero := journey.narrative.state.starting_character
		_draw_sprite(hero, Vector2(size.x * 0.50, size.y * 0.66), 3.45)
		_draw_sprite_shadow(Vector2(size.x * 0.50, size.y * 0.83), 74.0)
		_draw_origin_landmarks(hero)
	else:
		_draw_sprite("WUKONG", Vector2(size.x * 0.16, size.y * 0.74), 1.75)
		_draw_sprite("TANG", Vector2(size.x * 0.28, size.y * 0.78), 1.60)
		_draw_sprite("BAJIE", Vector2(size.x * 0.39, size.y * 0.78), 1.72)
		_draw_sprite("WUJING", Vector2(size.x * 0.49, size.y * 0.79), 1.68)
		_draw_sprite("LONGMA", Vector2(size.x * 0.61, size.y * 0.77), 1.58)
		_draw_pixel_path()

func _draw_sprite_shadow(center: Vector2, width: float) -> void:
	draw_rect(Rect2(center - Vector2(width * 0.5, 4.0), Vector2(width, 8.0)), Color(INK, 0.32), true)
	draw_rect(Rect2(center - Vector2(width * 0.32, 2.0), Vector2(width * 0.64, 4.0)), Color(INK, 0.30), true)

func _draw_origin_landmarks(hero: String) -> void:
	var ground_y := size.y * 0.82
	draw_rect(Rect2(size.x * 0.08, ground_y, size.x * 0.84, 3.0), Color(PAPER, 0.18))
	for x in [0.17, 0.28, 0.72, 0.83]:
		draw_rect(Rect2(size.x * x, ground_y - 18.0, 5.0, 18.0), Color(INK, 0.24))
	draw_rect(Rect2(size.x * 0.46, ground_y - 34.0, 70.0, 5.0), Color(GOLD, 0.22))
	if hero == "WUKONG":
		draw_rect(Rect2(size.x * 0.08, size.y * 0.28, 86.0, 5.0), Color(PAPER, 0.18))
	elif hero == "TANG":
		draw_rect(Rect2(size.x * 0.80, size.y * 0.32, 56.0, 42.0), Color(INK, 0.18))
		draw_rect(Rect2(size.x * 0.815, size.y * 0.34, 26.0, 3.0), Color(GOLD, 0.26))
	elif hero == "BAJIE":
		draw_rect(Rect2(size.x * 0.10, size.y * 0.40, 46.0, 18.0), Color(INK, 0.24))
		draw_rect(Rect2(size.x * 0.10, size.y * 0.36, 46.0, 4.0), Color(PAPER, 0.18))
	elif hero == "WUJING":
		draw_rect(Rect2(size.x * 0.81, size.y * 0.42, 62.0, 20.0), Color(INK, 0.22))
		draw_rect(Rect2(size.x * 0.82, size.y * 0.39, 42.0, 4.0), Color(PAPER, 0.18))
	elif hero == "LONGMA":
		draw_rect(Rect2(size.x * 0.10, size.y * 0.34, 58.0, 34.0), Color(PAPER, 0.12))
		draw_rect(Rect2(size.x * 0.12, size.y * 0.36, 34.0, 4.0), Color(GOLD, 0.22))

func _draw_battle_stage() -> void:
	_draw_sprite("WUKONG", Vector2(size.x * 0.31, size.y * 0.70), 2.40)
	_draw_sprite("TANG", Vector2(size.x * 0.42, size.y * 0.74), 1.95)
	_draw_sprite("YELLOW_WIND", Vector2(size.x * 0.76, size.y * 0.68), 2.65)
	_draw_battle_marks()

func _draw_yellow_wind_stage() -> void:
	_draw_sprite("WUKONG", Vector2(size.x * 0.18, size.y * 0.77), 1.90)
	_draw_sprite("TANG", Vector2(size.x * 0.29, size.y * 0.79), 1.70)
	_draw_sprite("YELLOW_WIND", Vector2(size.x * 0.73, size.y * 0.68), 2.50)
	_draw_battle_marks()

func _draw_sprite(kind: String, base: Vector2, scale_factor: float) -> void:
	var tex := sprite_textures.get(kind) as Texture2D
	if tex == null:
		return
	var target_size := Vector2(tex.get_width(), tex.get_height()) * scale_factor
	var rect := Rect2(base - Vector2(target_size.x * 0.5, target_size.y), target_size)
	draw_texture_rect(tex, rect, false)

func _draw_pixel_path() -> void:
	var y := size.y * 0.86
	for i in range(12):
		var x := size.x * (0.08 + float(i) * 0.075)
		draw_rect(Rect2(x, y + (i % 2) * 4.0, 22.0, 4.0), Color("c9a65f", 0.36))

func _draw_battle_marks() -> void:
	var left := Vector2(size.x * 0.56, size.y * 0.58)
	var right := Vector2(size.x * 0.66, size.y * 0.49)
	draw_rect(Rect2(left - Vector2(2, 34), Vector2(4, 68)), Color(GOLD, 0.54))
	draw_rect(Rect2(left - Vector2(18, 2), Vector2(36, 4)), Color(GOLD, 0.54))
	draw_rect(Rect2(right - Vector2(2, 25), Vector2(4, 50)), Color(RED, 0.60))
	draw_rect(Rect2(right - Vector2(16, 2), Vector2(32, 4)), Color(RED, 0.60))

func _draw_title_ornament() -> void:
	var y := size.y * 0.12
	draw_rect(Rect2(size.x * 0.05, y, size.x * 0.22, 3), Color(GOLD, 0.55))
	draw_rect(Rect2(size.x * 0.73, y, size.x * 0.22, 3), Color(GOLD, 0.55))
	draw_rect(Rect2(size.x * 0.47, y - 4, 12, 12), Color(GOLD, 0.75))
	draw_rect(Rect2(size.x * 0.49, y - 8, 8, 8), Color(PAPER, 0.75))

func _draw_map_details() -> void:
	for p in [Vector2(0.18,0.72),Vector2(0.32,0.60),Vector2(0.45,0.69),Vector2(0.59,0.52),Vector2(0.73,0.62),Vector2(0.84,0.46)]:
		var center := Vector2(size.x * p.x, size.y * p.y)
		draw_rect(Rect2(center - Vector2(7,7), Vector2(14,14)), Color(INK, 0.82))
		draw_rect(Rect2(center - Vector2(3,3), Vector2(6,6)), Color(GOLD, 0.92))
