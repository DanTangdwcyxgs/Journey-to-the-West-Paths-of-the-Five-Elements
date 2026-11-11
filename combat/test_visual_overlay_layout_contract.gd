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

const SCENE_STAGE_EXPECTATIONS: Dictionary = {
	"res://ui/main_menu.tscn": "main_menu",
	"res://ui/journey.tscn": "journey",
	"res://ui/battle_ui.tscn": "battle",
	"res://ui/world_map.tscn": "world_map",
	"res://ui/yellow_wind_ridge.tscn": "yellow_wind",
	"res://ui/yellow_wind_cave.tscn": "yellow_wind",
	"res://ui/bounty_prep.tscn": "",
	"res://ui/camp.tscn": "",
	"res://ui/party_screen.tscn": "",
	"res://ui/preparation.tscn": "",
	"res://ui/region_exploration.tscn": "",
	"res://ui/shop.tscn": "",
}

static func run_all() -> Dictionary:
	var failures: Array[String] = []

	for raw_scene_path in SCENE_STAGE_EXPECTATIONS.keys():
		var scene_path: String = str(raw_scene_path)
		var expected_stage: String = str(SCENE_STAGE_EXPECTATIONS[scene_path])
		var actual_stage: String = VisualOverlay.stage_kind_for_scene(scene_path)
		if actual_stage != expected_stage:
			failures.append("unexpected VisualOverlay stage mapping for %s: expected=%s actual=%s" % [scene_path, expected_stage, actual_stage])

	var opaque_background := Color("0b0d12")
	var no_backdrop_background := VisualOverlay.background_color_for_backdrop(opaque_background, false)
	if no_backdrop_background != opaque_background:
		failures.append("scene background opacity changed without a loaded stage texture")

	var revealed_background := VisualOverlay.background_color_for_backdrop(opaque_background, true)
	if absf(revealed_background.a - 0.30) > 0.001:
		failures.append("stage-backed scene background should be capped at 0.30 alpha")

	var existing_shade := Color(0.03, 0.025, 0.04, 0.12)
	var preserved_shade := VisualOverlay.background_color_for_backdrop(existing_shade, true)
	if absf(preserved_shade.a - 0.12) > 0.001:
		failures.append("existing translucent scene shade should not be made more transparent")

	if VisualOverlay.should_reapply_scene_visuals("res://ui/journey.tscn", 17, "res://ui/journey.tscn", 18) == false:
		failures.append("re-instancing the same scene path should reload backdrop visuals")
	if VisualOverlay.should_reapply_scene_visuals("res://ui/journey.tscn", 17, "res://ui/journey.tscn", 17):
		failures.append("unchanged scene instance should not reload backdrop visuals")
	if VisualOverlay.should_reapply_scene_visuals("res://ui/journey.tscn", 17, "res://ui/world_map.tscn", 18) == false:
		failures.append("changing scene path should reload backdrop visuals")

	var active_origin := VisualOverlay.build_presentation_signature("res://ui/journey.tscn", "WUKONG", NarrativeState.ROUTE_IN_PROGRESS)
	var completed_origin := VisualOverlay.build_presentation_signature("res://ui/journey.tscn", "WUKONG", NarrativeState.ROUTE_COMPLETE)
	if active_origin == completed_origin:
		failures.append("Journey overlay signature does not change when the starting route completes")

	var alternate_hero := VisualOverlay.build_presentation_signature("res://ui/journey.tscn", "TANG", NarrativeState.ROUTE_IN_PROGRESS)
	if active_origin == alternate_hero:
		failures.append("Journey overlay signature does not change when the starting character changes")

	var main_menu_before := VisualOverlay.build_presentation_signature("res://ui/main_menu.tscn", "WUKONG", NarrativeState.ROUTE_IN_PROGRESS)
	var main_menu_after := VisualOverlay.build_presentation_signature("res://ui/main_menu.tscn", "WUKONG", NarrativeState.ROUTE_COMPLETE)
	if main_menu_before != main_menu_after:
		failures.append("Non-Journey overlay signature should depend only on scene path")

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
