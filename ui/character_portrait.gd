class_name CharacterPortrait
extends Control

var character_id := "WUKONG"

const PALETTES := {
	"WUKONG": [Color("b45f4a"), Color("d9ad62"), Color("2d2830")],
	"TANG": [Color("d2c4a1"), Color("6b706f"), Color("2f3940")],
	"BAJIE": [Color("a78d72"), Color("5a4c42"), Color("343238")],
	"WUJING": [Color("7b9a9b"), Color("485861"), Color("2b3037")],
	"LONGMA": [Color("e2ddd1"), Color("9ba5a8"), Color("59636c")],
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_character(id: String) -> void:
	character_id = id
	queue_redraw()

func _draw() -> void:
	var palette: Array = PALETTES.get(character_id, PALETTES["WUKONG"])
	var w := size.x
	var h := size.y
	var center := Vector2(w * 0.5, h * 0.47)
	# Soft ground shadow; no texture asset required.
	draw_ellipse(center + Vector2(0, h * 0.33), Vector2(w * 0.26, h * 0.06), Color(0, 0, 0, 0.22))
	# Back glow / silhouette separation.
	draw_circle(center + Vector2(0, -h * 0.17), min(w, h) * 0.18, Color(palette[1], 0.14))
	# Head.
	draw_circle(center + Vector2(0, -h * 0.16), min(w, h) * 0.14, palette[0])
	# Hair/hat silhouette.
	draw_arc(center + Vector2(0, -h * 0.18), min(w, h) * 0.15, PI, TAU, 24, Color(palette[2], 0.95), max(3.0, w * 0.018))
	# Robe/body.
	var body := PackedVector2Array([
		center + Vector2(-w * 0.15, -h * 0.03),
		center + Vector2(w * 0.15, -h * 0.03),
		center + Vector2(w * 0.23, h * 0.23),
		center + Vector2(-w * 0.23, h * 0.23),
	])
	draw_colored_polygon(body, Color(palette[2], 0.96))
	# Waist sash.
	draw_rect(Rect2(center + Vector2(-w * 0.16, h * 0.08), Vector2(w * 0.32, h * 0.04)), palette[1])
	# Arms.
	draw_line(center + Vector2(-w * 0.10, h * 0.02), center + Vector2(-w * 0.28, h * 0.16), palette[2], max(5.0, w * 0.035))
	draw_line(center + Vector2(w * 0.10, h * 0.02), center + Vector2(w * 0.28, h * 0.16), palette[2], max(5.0, w * 0.035))
	# Character-specific prop hint.
	if character_id == "WUKONG":
		draw_line(center + Vector2(w * 0.29, h * 0.20), center + Vector2(w * 0.36, -h * 0.28), palette[1], max(4.0, w * 0.025))
	elif character_id == "BAJIE":
		for dx in [-0.04, 0.0, 0.04]:
			draw_line(center + Vector2(w * (0.28 + dx), h * 0.13), center + Vector2(w * (0.33 + dx), h * -0.12), palette[1], max(2.0, w * 0.014))
	elif character_id == "WUJING":
		draw_circle(center + Vector2(-w * 0.31, h * 0.15), max(4.0, w * 0.035), palette[1])
	elif character_id == "LONGMA":
		draw_arc(center + Vector2(0, -h * 0.03), min(w, h) * 0.24, PI * 0.05, PI * 0.95, 18, Color(palette[0], 0.55), 2.0)
	elif character_id == "TANG":
		draw_line(center + Vector2(-w * 0.18, -h * 0.27), center + Vector2(w * 0.18, -h * 0.27), palette[1], max(4.0, w * 0.02))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var a := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
