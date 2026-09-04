extends RefCounted

## Regression check for the core canon rule:
## the player may begin from any protagonist, but the shared-world chronology
## always hands off at the same canonical point for that protagonist.
static func run() -> void:
	var expected := {
		"TANG": {"timeline": 100, "chapter": "SHARED-01-FIVE-ELEMENTS", "roster": ["TANG", "WUKONG"]},
		"WUKONG": {"timeline": 100, "chapter": "SHARED-01-FIVE-ELEMENTS", "roster": ["TANG", "WUKONG"]},
		"LONGMA": {"timeline": 110, "chapter": "SHARED-03-EAGLE-SORROW", "roster": ["TANG", "WUKONG", "LONGMA"]},
		"BAJIE": {"timeline": 130, "chapter": "SHARED-05-GAOJIAZHUANG", "roster": ["TANG", "WUKONG", "LONGMA", "BAJIE"]},
		"WUJING": {"timeline": 150, "chapter": "SHARED-07-FLOWING-SANDS", "roster": ["TANG", "WUKONG", "LONGMA", "BAJIE", "WUJING"]
	}

	for character_id in expected.keys():
		var narrative := NarrativeManager.new()
		assert(narrative.start_new_game(character_id))
		assert(narrative.handoff_origin_to_shared(character_id))
		var target: Dictionary = expected[character_id]
		assert(narrative.state.current_global_timeline == int(target["timeline"]))
		assert(narrative.state.current_shared_chapter == str(target["chapter"]))
		assert(narrative.state.recruited_characters == target["roster"])
		assert(narrative.state.current_origin_route == "")
