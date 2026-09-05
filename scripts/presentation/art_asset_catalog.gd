class_name ArtAssetCatalog
extends RefCounted

## Single source of truth for replaceable presentation assets.
## Final art can be delivered as PNG/WebP without touching gameplay code.
## Resolution order: final PNG -> final WebP -> current SVG placeholder.
## All runtime consumers should ask this catalog for presentation textures.

const CHARACTER_PATHS: Dictionary = {
	"WUKONG": "res://assets/art/characters/wukong.svg",
	"TANG": "res://assets/art/characters/tang.svg",
	"BAJIE": "res://assets/art/characters/bajie.svg",
	"WUJING": "res://assets/art/characters/wujing.svg",
	"LONGMA": "res://assets/art/characters/longma.svg",
	"YELLOW_WIND": "res://assets/art/characters/yellow_wind.svg",
}

const SCENE_PATHS: Dictionary = {
	"JOURNEY": "res://assets/art/scenes/journey_scenery.svg",
	"BATTLE_YELLOW_WIND": "res://assets/art/scenes/yellow_wind_battle.svg",
	"WORLD_MAP": "res://assets/art/scenes/journey_map.svg",
}

static func character_texture(character_id: String) -> Texture2D:
	return _resolve_texture("characters", character_id, CHARACTER_PATHS)

static func scene_texture(scene_id: String) -> Texture2D:
	return _resolve_texture("scenes", scene_id, SCENE_PATHS)

static func character_asset_path(character_id: String) -> String:
	return _resolve_asset_path("characters", character_id, CHARACTER_PATHS)

static func scene_asset_path(scene_id: String) -> String:
	return _resolve_asset_path("scenes", scene_id, SCENE_PATHS)

static func _resolve_asset_path(kind: String, asset_id: String, fallback_paths: Dictionary) -> String:
	var normalized_id: String = asset_id.to_upper()
	var stem: String = normalized_id.to_lower()
	var final_candidates: Array[String] = [
		"res://assets/art/%s/final/%s.png" % [kind, stem],
		"res://assets/art/%s/final/%s.webp" % [kind, stem],
	]
	for candidate in final_candidates:
		if ResourceLoader.exists(candidate):
			return candidate
	return str(fallback_paths.get(normalized_id, ""))

static func _resolve_texture(kind: String, asset_id: String, fallback_paths: Dictionary) -> Texture2D:
	var path: String = _resolve_asset_path(kind, asset_id, fallback_paths)
	if path.is_empty():
		return null
	return load(path) as Texture2D
