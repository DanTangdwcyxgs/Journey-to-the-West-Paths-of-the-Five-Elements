class_name ArtAssetCatalog
extends RefCounted

## Single source of truth for replaceable presentation assets.
## Art generation tools may replace files without changing gameplay code.
## Preferred production formats: PNG/WebP with nearest-neighbour filtering.

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
	var path: String = str(CHARACTER_PATHS.get(character_id.to_upper(), ""))
	return _load_texture(path)

static func scene_texture(scene_id: String) -> Texture2D:
	var path: String = str(SCENE_PATHS.get(scene_id.to_upper(), ""))
	return _load_texture(path)

static func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	return load(path) as Texture2D

static func character_asset_path(character_id: String) -> String:
	return str(CHARACTER_PATHS.get(character_id.to_upper(), ""))

static func scene_asset_path(scene_id: String) -> String:
	return str(SCENE_PATHS.get(scene_id.to_upper(), ""))
