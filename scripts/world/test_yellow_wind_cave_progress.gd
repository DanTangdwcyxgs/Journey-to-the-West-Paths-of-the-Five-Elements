extends RefCounted

## Regression checks for dungeon progress stored in the existing journey rumor state.

static func run() -> void:
	var narrative := NarrativeManager.new()
	narrative.start_new_game("WUKONG")
	var world := narrative.state.get_world_state()
	world["heard_rumors"] = [
		"YELLOW_WIND_CAVE_ROOM_CAVE_MOUTH",
		"YELLOW_WIND_CAVE_ROOM_SAND_ALTAR",
	]
	narrative.state.set_world_state(world)
	var heard := narrative.state.get_world_state().get("heard_rumors", [])
	assert("YELLOW_WIND_CAVE_ROOM_CAVE_MOUTH" in heard)
	assert("YELLOW_WIND_CAVE_ROOM_SAND_ALTAR" in heard)
	assert("YELLOW_WIND_CAVE_ROOM_SANDSTORM_HALL" not in heard)
