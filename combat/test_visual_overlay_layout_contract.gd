extends RefCounted

## Geometry regression for the fixed 1280×720 presentation canvas.
## This tests the same scale and baseline constants consumed by VisualOverlay.

const VIEWPORT_SIZE := Vector2(1280.0, 720.0)
const ORIGIN_CANVASES: Dictionary = {
	"WUKONG": Vector2i(128, 192),
	"TANG": Vector2i(128, 192),
	"BAJIE": Vector2i(128, 192),
	"WUJING": Vector2i(128, 192),
	"LONGMA": Vector2i(160, 128),
}

static func run_all() -> Dictionary:
	var failures: Array[String] = []

	for raw_id in ORIGIN_CANVASES.keys():
		var character_id: String = str(raw_id)
		var canvas: Vector2i = ORIGIN_CANVASES[character_id]
		var rect := _sprite_rect(
			canvas,
			VisualOverlay.ORIGIN_HERO_SCALE,
			VIEWPORT_SIZE.x * 0.50,
			VIEWPORT_SIZE.y * VisualOverlay.ORIGIN_HERO_BASELINE_RATIO
		)
		if not _rect_inside_viewport(rect):
			failures.append("origin hero is cropped: %s rect=%s" % [character_id, str(rect)])

	var origin_baseline: float = VIEWPORT_SIZE.y * VisualOverlay.ORIGIN_HERO_BASELINE_RATIO
	var shadow_center: float = VIEWPORT_SIZE.y * VisualOverlay.ORIGIN_HERO_SHADOW_RATIO
	if absf(shadow_center - origin_baseline) > 8.0:
		failures.append("origin hero shadow is detached from ground baseline: baseline=%f shadow=%f" % [origin_baseline, shadow_center])

	var battle_boss := _sprite_rect(
		Vector2i(144, 192),
		2.65,
		VIEWPORT_SIZE.x * 0.76,
		VIEWPORT_SIZE.y * VisualOverlay.BATTLE_BOSS_BASELINE_RATIO
	)
	if not _rect_inside_viewport(battle_boss, 8.0):
		failures.append("Yellow Wind boss is cropped in battle UI: %s" % str(battle_boss))

	var ridge_boss := _sprite_rect(
		Vector2i(144, 192),
		2.50,
		VIEWPORT_SIZE.x * 0.73,
		VIEWPORT_SIZE.y * VisualOverlay.YELLOW_WIND_BOSS_BASELINE_RATIO
	)
	if not _rect_inside_viewport(ridge_boss):
		failures.append("Yellow Wind boss is cropped in ridge/cave stage: %s" % str(ridge_boss))

	if not failures.is_empty():
		return {"passed": false, "failures": failures}
	return {
		"passed": true,
		"origin_characters": ORIGIN_CANVASES.size(),
		"battle_layouts": 2,
	}

static func _sprite_rect(canvas: Vector2i, scale_factor: float, center_x: float, baseline_y: float) -> Rect2:
	var target_size := Vector2(float(canvas.x), float(canvas.y)) * scale_factor
	return Rect2(Vector2(center_x - target_size.x * 0.5, baseline_y - target_size.y), target_size)

static func _rect_inside_viewport(rect: Rect2, margin: float = 0.0) -> bool:
	return (
		rect.position.x >= margin
		and rect.position.y >= margin
		and rect.end.x <= VIEWPORT_SIZE.x - margin
		and rect.end.y <= VIEWPORT_SIZE.y - margin
	)
