extends SceneTree

## Production UI/content regression for the read-only discovered-clue journal.
class TestableRegionNotesLogScreen extends RegionNotesLogScreen:
	var fixture_narrative: NarrativeManager

	func _ready() -> void:
		narrative = fixture_narrative
		_initialize_screen(false)


var failures: Array[String] = []

func _initialize() -> void:
	await _run_test()


func _run_test() -> void:
	var packed := load("res://ui/region_notes_log.tscn") as PackedScene
	_record(packed != null, "the production region-notes scene should load")
	if packed != null:
		var production_instance := packed.instantiate()
		_record(production_instance is RegionNotesLogScreen, "the production scene should use RegionNotesLogScreen")
		production_instance.free()

	var fixture := NarrativeManager.new()
	_record(fixture.start_new_game("WUKONG"), "fixture should initialize narrative state")
	fixture.state.current_global_timeline = 120
	fixture.state.set_current_shared_chapter("SHARED-04-EARLY-DEMON-TALES")
	_record(fixture.state.record_region_point_discovered("EAGLE_SORROW_STONE_TRACE"), "first region clue should be recorded once")
	_record(fixture.state.record_region_point_discovered("BLACK_WIND_NORTH_PATH_BROKEN_PINE"), "cross-region clue should be recorded once")
	_record(not fixture.state.record_region_point_discovered("EAGLE_SORROW_STONE_TRACE"), "duplicate discovery should stay idempotent")

	var restored := NarrativeManager.new()
	restored.state = NarrativeState.from_dict(fixture.serialize())
	var manager := RegionExplorationManager.new()
	var notes := manager.get_discovered_notes(restored)
	_record(notes.size() == 2, "the journal projection should include discovered notes from multiple regions")
	var note_ids: Array[String] = []
	for note in notes:
		note_ids.append(str(note.get("id", "")))
	_record("EAGLE_SORROW_STONE_TRACE" in note_ids, "the discovered Eagle Sorrow note should be present")
	_record("BLACK_WIND_NORTH_PATH_BROKEN_PINE" in note_ids, "the discovered Black Wind note should be present")
	_record("EAGLE_SORROW_BACKWATER" not in note_ids, "undiscovered clues must not appear in the journal")
	_record(str(notes[0].get("region_name", "")).contains("鹰愁涧"), "journal items should retain their region label")

	var state_before_review := restored.state.to_dict().duplicate(true)
	var timeline_before := restored.state.current_global_timeline
	var chapter_before := restored.state.current_shared_chapter
	var completed_before := restored.state.completed_chapters.duplicate(true)
	var roster_before := restored.state.recruited_characters.duplicate(true)
	var screen := TestableRegionNotesLogScreen.new()
	screen.fixture_narrative = restored
	root.add_child(screen)
	await process_frame
	_record(screen.note_list != null and screen.note_list.item_count == 2, "the screen should list only the two discovered notes")
	_record(screen.summary_label != null and screen.summary_label.text.contains("2 条线索"), "the summary should report the discovered-note count")
	_record(screen.note_list.get_item_text(0).contains("石岸旧痕"), "the first list item should show the discovered clue name")
	screen._on_note_selected(1)
	_record(screen.detail_label.text.contains("折断的松枝"), "selecting a note should show its clue detail")
	_record(restored.state.to_dict() == state_before_review, "opening and browsing the journal must not mutate persisted narrative state")
	_record(restored.state.current_global_timeline == timeline_before, "review must not advance the world timeline")
	_record(restored.state.current_shared_chapter == chapter_before, "review must not advance the shared chapter")
	_record(restored.state.completed_chapters == completed_before, "review must not complete chapters")
	_record(restored.state.recruited_characters == roster_before, "review must not mutate recruitment")

	screen.queue_free()
	await process_frame

	var empty_fixture := NarrativeManager.new()
	empty_fixture.start_new_game("TANG")
	var empty_screen := TestableRegionNotesLogScreen.new()
	empty_screen.fixture_narrative = empty_fixture
	root.add_child(empty_screen)
	await process_frame
	_record(empty_screen.note_list.item_count == 0, "an empty journal should not list any clues")
	_record(empty_screen.detail_label.text.contains("目前还没有记录区域线索"), "an empty journal should explain how to discover notes")
	empty_screen.queue_free()
	await process_frame

	var map_screen := WorldMapScreen.new()
	map_screen._build_ui()
	_record(map_screen.notes_button != null, "WorldMap should expose a 旅途见闻 entry point")
	_record(map_screen.notes_button.text == "旅途见闻", "the WorldMap journal button should use player-facing text")
	map_screen.free()

	if failures.is_empty():
		print("REGION_NOTES_LOG_TEST_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error("REGION_NOTES_LOG_TEST: " + failure)
		print("REGION_NOTES_LOG_TEST_FAIL failures=%d" % failures.size())
		quit(1)


func _record(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("REGION_NOTES_LOG_TEST: " + message)
