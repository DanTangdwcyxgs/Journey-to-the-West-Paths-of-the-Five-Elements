extends RefCounted

## Runtime presentation contract: every registered key resolves, and final files match the documented paths.
const EXPECTED_SCENE_FINAL_STEMS: Dictionary = {
	"JOURNEY": "journey_scenery",
	"BATTLE_YELLOW_WIND": "yellow_wind_battle",
	"WORLD_MAP": "world_map",
}

static func run_all() -> Dictionary:
	var failures: Array[String] = []
	var character_count: int = 0
	for raw_id in ArtAssetCatalog.CHARACTER_PATHS.keys():
		var character_id: String = str(raw_id)
		var texture: Texture2D = ArtAssetCatalog.character_texture(character_id)
		if texture == null:
			failures.append("character texture missing: %s" % character_id)
		elif texture.get_width() <= 0 or texture.get_height() <= 0:
			failures.append("invalid character texture: %s" % character_id)
		character_count += 1

	var scene_count: int = 0
	for raw_id in ArtAssetCatalog.SCENE_PATHS.keys():
		var scene_id: String = str(raw_id)
		var expected_stem: String = str(EXPECTED_SCENE_FINAL_STEMS.get(scene_id, ""))
		var catalog_stem: String = str(ArtAssetCatalog.SCENE_FINAL_STEMS.get(scene_id, ""))
		if expected_stem.is_empty() or catalog_stem != expected_stem:
			failures.append("scene final filename mismatch: %s expected stem=%s catalog stem=%s" % [scene_id, expected_stem, catalog_stem])

		var final_png: String = "res://assets/art/scenes/final/%s.png" % expected_stem
		var final_webp: String = "res://assets/art/scenes/final/%s.webp" % expected_stem
		var expected_path: String = final_png if ResourceLoader.exists(final_png) else final_webp if ResourceLoader.exists(final_webp) else str(ArtAssetCatalog.SCENE_PATHS[scene_id])
		var actual_path: String = ArtAssetCatalog.scene_asset_path(scene_id)
		if actual_path != expected_path:
			failures.append("scene catalog priority/path mismatch: %s expected=%s actual=%s" % [scene_id, expected_path, actual_path])

		var texture: Texture2D = ArtAssetCatalog.scene_texture(scene_id)
		if texture == null:
			failures.append("scene texture missing: %s -> %s" % [scene_id, actual_path])
		elif texture.get_width() <= 0 or texture.get_height() <= 0:
			failures.append("invalid scene texture: %s" % scene_id)
		elif texture.get_width() * 9 != texture.get_height() * 16:
			failures.append("scene canvas must be 16:9: %s is %dx%d at %s" % [scene_id, texture.get_width(), texture.get_height(), actual_path])
		scene_count += 1

	if not failures.is_empty():
		return {"passed": false, "failures": failures}
	return {
		"passed": true,
		"characters": character_count,
		"scenes": scene_count,
	}
