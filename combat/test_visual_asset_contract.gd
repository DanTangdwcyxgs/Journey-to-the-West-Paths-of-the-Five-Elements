extends RefCounted

const SPRITES := {
	"WUKONG": "res://assets/art/characters/wukong.svg",
	"TANG": "res://assets/art/characters/tang.svg",
	"BAJIE": "res://assets/art/characters/bajie.svg",
	"WUJING": "res://assets/art/characters/wujing.svg",
	"LONGMA": "res://assets/art/characters/longma.svg",
	"YELLOW_WIND": "res://assets/art/characters/yellow_wind.svg",
}

const SCENES := [
	"res://assets/art/scenes/journey_scenery.svg",
	"res://assets/art/scenes/journey_map.svg",
	"res://assets/art/scenes/yellow_wind_battle.svg",
]

static func run_all() -> Dictionary:
	var failures: Array[String] = []
	for id in SPRITES:
		var path: String = SPRITES[id]
		var texture := load(path) as Texture2D
		if texture == null:
			failures.append("missing sprite: %s -> %s" % [id, path])
		elif texture.get_width() < 32 or texture.get_height() < 48:
			failures.append("sprite too small: %s -> %dx%d" % [id, texture.get_width(), texture.get_height()])
	for path in SCENES:
		var texture := load(path) as Texture2D
		if texture == null:
			failures.append("missing scene texture: %s" % path)
	if failures.is_empty():
		return {"passed": true}
	return {"passed": false, "failures": failures}
