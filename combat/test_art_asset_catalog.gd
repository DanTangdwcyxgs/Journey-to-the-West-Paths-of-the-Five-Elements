extends RefCounted

## Presentation contract test: every registered art key must resolve to a loadable texture.
static func run_all() -> Dictionary:
	var character_count: int = 0
	for raw_id in ArtAssetCatalog.CHARACTER_PATHS.keys():
		var character_id: String = str(raw_id)
		var texture: Texture2D = ArtAssetCatalog.character_texture(character_id)
		assert(texture != null, "character texture missing: %s" % character_id)
		assert(texture.get_width() > 0 and texture.get_height() > 0, "invalid character texture: %s" % character_id)
		character_count += 1

	var scene_count: int = 0
	for raw_id in ArtAssetCatalog.SCENE_PATHS.keys():
		var scene_id: String = str(raw_id)
		var texture: Texture2D = ArtAssetCatalog.scene_texture(scene_id)
		assert(texture != null, "scene texture missing: %s" % scene_id)
		assert(texture.get_width() > 0 and texture.get_height() > 0, "invalid scene texture: %s" % scene_id)
		scene_count += 1

	return {
		"passed": true,
		"characters": character_count,
		"scenes": scene_count,
	}
