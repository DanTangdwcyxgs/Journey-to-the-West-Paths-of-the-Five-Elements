class_name PixelFrame
extends PanelContainer

const INK := Color("0a1018")
const INNER := Color("111b25")
const CYAN := Color("72d8d2")
const CYAN_DIM := Color("315d67")
const GOLD := Color("d8aa57")
const EDGE := Color("20323d")

@export var accent := CYAN
@export var cut := 14.0
@export var panel_alpha := 0.94

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var empty: StyleBoxEmpty = StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", empty)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _poly(w: float, h: float, inset: float = 0.0) -> PackedVector2Array:
	var c: float = maxf(4.0, cut - inset * 0.45)
	return PackedVector2Array([
		Vector2(inset + c, inset),
		Vector2(w - inset - c, inset),
		Vector2(w - inset, inset + c),
		Vector2(w - inset, h - inset - c),
		Vector2(w - inset - c, h - inset),
		Vector2(inset + c, h - inset),
		Vector2(inset, h - inset - c),
		Vector2(inset, inset + c)
	])

func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var outer: PackedVector2Array = _poly(size.x, size.y)
	var inner: PackedVector2Array = _poly(size.x, size.y, 4.0)
	draw_colored_polygon(outer, Color(INK, panel_alpha))
	draw_colored_polygon(inner, Color(INNER, minf(panel_alpha, 0.92)))
	draw_polyline(outer + PackedVector2Array([outer[0]]), Color(EDGE, 0.98), 2.0, true)
	draw_polyline(inner + PackedVector2Array([inner[0]]), Color(accent, 0.78), 1.0, true)
	var line_y: float = 7.0
	draw_line(Vector2(cut + 8.0, line_y), Vector2(size.x - cut - 8.0, line_y), Color(accent, 0.28), 1.0, true)
	for x in range(int(cut + 14.0), int(maxf(cut + 14.0, size.x - cut - 8.0)), 10):
		draw_rect(Rect2(float(x), line_y + 3.0, 3.0, 2.0), Color(accent, 0.20))
	for p in [Vector2(8, size.y * 0.5 - 1), Vector2(size.x - 11, size.y * 0.5 - 1)]:
		draw_rect(Rect2(p, Vector2(3, 3)), Color(accent, 0.42))
	for p in [Vector2(cut + 3, size.y - 8), Vector2(size.x - cut - 6, size.y - 8)]:
		draw_rect(Rect2(p, Vector2(3, 3)), Color(GOLD, 0.45))
