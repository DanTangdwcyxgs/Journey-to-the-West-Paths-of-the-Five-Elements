class_name PixelUI
extends RefCounted

const FONT_PATH := "res://fonts/NotoSansSC-Regular.otf"
const INK := Color("091019")
const CYAN := Color("72d8d2")
const CYAN_DIM := Color("315d67")
const GOLD := Color("d8aa57")
const PAPER := Color("d9eee9")
const MUTED := Color("81979a")

static func _box(bg: Color, border: Color, width := 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.corner_radius_top_left = 0
	box.corner_radius_top_right = 0
	box.corner_radius_bottom_right = 0
	box.corner_radius_bottom_left = 0
	box.anti_aliasing = false
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

static func build_theme() -> Theme:
	var theme := Theme.new()
	var font := load(FONT_PATH) as Font
	if font != null:
		theme.default_font = font
	theme.default_font_size = 18

	theme.set_color("font_color", "Button", PAPER)
	theme.set_color("font_hover_color", "Button", CYAN)
	theme.set_color("font_pressed_color", "Button", GOLD)
	theme.set_color("font_focus_color", "Button", CYAN)
	theme.set_color("font_disabled_color", "Button", MUTED)
	theme.set_font_size("font_size", "Button", 16)
	theme.set_stylebox("normal", "Button", _box(Color(0.025, 0.05, 0.065, 0.94), Color(CYAN_DIM, 0.95), 1))
	theme.set_stylebox("hover", "Button", _box(Color(0.07, 0.16, 0.18, 0.98), Color(CYAN, 1.0), 2))
	theme.set_stylebox("pressed", "Button", _box(Color(0.15, 0.11, 0.06, 0.99), Color(GOLD, 1.0), 2))
	theme.set_stylebox("focus", "Button", _box(Color(0.05, 0.11, 0.12, 0.98), Color(CYAN, 1.0), 2))
	theme.set_stylebox("disabled", "Button", _box(Color(0.035, 0.045, 0.05, 0.62), Color(0.18, 0.23, 0.24, 0.72), 1))

	theme.set_color("font_color", "ItemList", PAPER)
	theme.set_color("font_selected_color", "ItemList", GOLD)
	theme.set_font_size("font_size", "ItemList", 15)
	theme.set_stylebox("panel", "ItemList", _box(Color(0.012, 0.025, 0.036, 0.90), Color(CYAN_DIM, 0.90), 1))
	theme.set_stylebox("focus", "ItemList", _box(Color(0.04, 0.09, 0.10, 0.95), Color(CYAN, 0.90), 1))
	return theme

static func apply(root: Control) -> void:
	if root == null:
		return
	root.theme = build_theme()
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
