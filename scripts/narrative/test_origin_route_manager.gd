extends RefCounted

## Regression checks for the five data-driven origin campaigns.

static func run() -> void:
	var manager := OriginRouteManager.new()
	var routes := ["WUKONG", "TANG", "LONGMA", "BAJIE", "WUJING"]
	var minimum_sizes := {"WUKONG":15, "TANG":8, "LONGMA":6, "BAJIE":9, "WUJING":8}
	for character_id in routes:
		var chapters := manager.get_chapters(character_id)
		assert(chapters.size() == int(minimum_sizes[character_id]))
		assert(not manager.get_route(character_id).get("theme", "").is_empty())
		for chapter in chapters:
			assert(not str(chapter.get("id", "")).is_empty())
			assert(not str(chapter.get("title", "")).is_empty())
			assert(not str(chapter.get("summary", "")).is_empty())

	var narrative := NarrativeManager.new()
	assert(narrative.start_new_game("WUKONG"))
	assert(manager.get_current_index(narrative, "WUKONG") == 0)
	var first := manager.complete_current(narrative, "WUKONG")
	assert(first.get("id", "") == "WUK-01")
	assert(manager.get_current_index(narrative, "WUKONG") == 1)
	assert(narrative.state.current_global_timeline == 0)
	assert(narrative.state.route_progress.get("WUKONG_ORIGIN", "") == "WUK-02")
