extends RefCounted

## Runtime visual contract: validate the asset selected by the production catalog.
## SVG environment layer checks remain source-level checks; character art quality still
## requires manual screenshot review and is not inferred from texture loadability.

const CHARACTER_IDS := ["WUKONG", "TANG", "BAJIE", "WUJING", "LONGMA", "YELLOW_WIND"]
const SCENES := [
	"res://assets/art/scenes/journey_scenery.svg",
	"res://assets/art/scenes/journey_map.svg",
	"res://assets/art/scenes/yellow_wind_battle.svg",
]

static func run_all() -> Dictionary:
	var failures: Array[String] = []
	for id in CHARACTER_IDS:
		var path: String = ArtAssetCatalog.character_asset_path(id)
		if path.is_empty():
			failures.append("catalog returned empty character path: %s" % id)
			continue
		var texture := ArtAssetCatalog.character_texture(id)
		if texture == null:
			failures.append("catalog texture failed to load: %s -> %s" % [id, path])
		elif texture.get_width() <= 0 or texture.get_height() <= 0:
			failures.append("invalid character texture: %s -> %dx%d" % [id, texture.get_width(), texture.get_height()])
		var stem: String = id.to_lower()
		var final_png := "res://assets/art/characters/final/%s.png" % stem
		var final_webp := "res://assets/art/characters/final/%s.webp" % stem
		var expected: String = final_png if ResourceLoader.exists(final_png) else final_webp if ResourceLoader.exists(final_webp) else "res://assets/art/characters/%s.svg" % stem
		if path != expected:
			failures.append("catalog priority mismatch: %s expected=%s actual=%s" % [id, expected, path])
	for path in SCENES:
		var texture := ArtAssetCatalog.scene_texture(_scene_id_for_path(path))
		if texture == null:
			failures.append("catalog scene texture failed to load: %s" % path)
	var journey_source := FileAccess.get_file_as_string("res://assets/art/scenes/journey_scenery.svg")
	for marker in ["layer-far-ridges", "layer-distant-temple", "layer-midground-cliffs", "layer-foreground-path", "layer-foreground-foliage", "layer-lanterns"]:
		if not journey_source.contains(marker):
			failures.append("Journey scene lost required depth layer: %s" % marker)
	var battle_source := FileAccess.get_file_as_string("res://assets/art/scenes/yellow_wind_battle.svg")
	for marker in ["layer-far-ridges", "layer-sandstorm", "layer-ruined-fortress", "layer-battle-ground", "layer-ember-cracks", "layer-wind-vortex"]:
		if not battle_source.contains(marker):
			failures.append("Battle scene lost required environment layer: %s" % marker)
	if failures.is_empty():
		return {"passed": true}
	return {"passed": false, "failures": failures}

static func _scene_id_for_path(path: String) -> String:
	match path:
		"res://assets/art/scenes/journey_scenery.svg":
			return "JOURNEY"
		"res://assets/art/scenes/journey_map.svg":
			return "WORLD_MAP"
		"res://assets/art/scenes/yellow_wind_battle.svg":
			return "BATTLE_YELLOW_WIND"
	return ""
