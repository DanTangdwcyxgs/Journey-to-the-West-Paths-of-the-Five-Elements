class_name CharacterPortrait
extends Control

const SPRITES := {
	"WUKONG": "res://assets/art/characters/wukong.svg",
	"TANG": "res://assets/art/characters/tang.svg",
	"BAJIE": "res://assets/art/characters/bajie.svg",
	"WUJING": "res://assets/art/characters/wujing.svg",
	"LONGMA": "res://assets/art/characters/longma.svg",
}

const FRAME := Color("1b1920")
const GOLD := Color("d5ad57")

var character_id := "WUKONG"
var sprite: Texture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_reload_sprite()

func set_character(id: String) -> void:
	character_id = id
	_reload_sprite()
	queue_redraw()

func _reload_sprite() -> void:
	sprite = load(SPRITES.get(character_id, SPRITES["WUKONG"])) as Texture2D
	queue_redraw()

func _draw() -> void:
	var inset := 8.0
	# Pixel-art card: square corners, stepped ornament, no vector faces.
	draw_rect(Rect2(inset, inset, size.x - inset * 2.0, size.y - inset * 2.0), Color(FRAME, 0.92), true)
	draw_rect(Rect2(inset, inset, size.x - inset * 2.0, size.y - inset * 2.0), Color(GOLD, 0.72), false, 2.0)
	for x in [inset + 10.0, size.x - inset - 14.0]:
		draw_rect(Rect2(x, inset + 10.0, 4.0, 14.0), GOLD)
		draw_rect(Rect2(x - 5.0, inset + 15.0, 14.0, 4.0), GOLD)
	if sprite == null:
		return
	var available: Vector2 = Vector2(size.x - 26.0, size.y - 30.0)
	var source: Vector2 = Vector2(sprite.get_width(), sprite.get_height())
	var factor: float = min(available.x / source.x, available.y / source.y)
	var target: Vector2 = source * factor
	var rect: Rect2 = Rect2(Vector2((size.x - target.x) * 0.5, (size.y - target.y) * 0.5 + 4.0), target)
	draw_texture_rect(sprite, rect, false)
