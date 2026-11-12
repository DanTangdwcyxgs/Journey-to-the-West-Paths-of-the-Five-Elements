extends RefCounted

## Keeps the narrative Bible aligned with the executable Shared chapter catalog.
const SHARED_CHAPTERS_PATH := "res://data/narrative/shared_chapters.json"
const SHARED_SEQUENCES_PATH := "res://data/narrative/event_sequences.json"
const BIBLE_PATH := "res://docs/shared_pilgrimage_chapter_bible.md"

static func run_all() -> Dictionary:
	var chapters_data := _read_json(SHARED_CHAPTERS_PATH)
	var sequences_data := _read_json(SHARED_SEQUENCES_PATH)
	var bible := _read_text(BIBLE_PATH)
	var chapters: Array = chapters_data.get("chapters", [])
	var sequences: Array = sequences_data.get("sequences", [])
	assert(chapters.size() == 9, "Shared Bible alignment gate expects the current nine registered Shared chapters")

	var shared_sequences: Dictionary = {}
	for sequence_variant in sequences:
		if not sequence_variant is Dictionary:
			continue
		var sequence: Dictionary = sequence_variant
		if str(sequence.get("namespace", "")).to_upper() != "SHARED":
			continue
		var chapter_id := str(sequence.get("chapter_id", ""))
		shared_sequences[chapter_id] = str(sequence.get("id", ""))

	var previous_next := ""
	var visited_ids: Dictionary = {}
	for index in range(chapters.size()):
		var chapter: Dictionary = chapters[index]
		var chapter_id := str(chapter.get("id", ""))
		var title := str(chapter.get("title", ""))
		var timeline := int(chapter.get("timeline", -1))
		var next_id := str(chapter.get("next", "")) if not str(chapter.get("next", "")).is_empty() else "无"
		assert(not chapter_id.is_empty(), "Shared chapter should have a stable ID")
		assert(not visited_ids.has(chapter_id), "Shared chapter IDs must remain unique")
		visited_ids[chapter_id] = true
		assert(not title.is_empty(), "%s should have a registered title" % chapter_id)
		assert(timeline >= 0, "%s should have a valid timeline" % chapter_id)
		assert(shared_sequences.has(chapter_id), "%s should have a matching Shared EventSequence" % chapter_id)
		var row := "| %s | %s | %d | %s | %s |" % [
			chapter_id,
			title,
			timeline,
			shared_sequences[chapter_id],
			next_id
		]
		assert(bible.contains(row), "Shared Bible runtime table is stale or mismatched: %s" % row)
		if index > 0:
			assert(previous_next == chapter_id, "Shared chapter next-link chain should remain continuous at %s" % chapter_id)
		previous_next = str(chapter.get("next", ""))

	assert(previous_next.is_empty(), "The current final Shared chapter should remain an explicit open-ended entry until the next chapter is registered")
	assert(bible.contains("SHARED-06A-YELLOW-WIND"), "The Bible should preserve the documented Yellow Wind insertion proposal")
	assert(bible.contains("当前它还不是正式 Shared chapter"), "The Bible must not overstate the Yellow Wind vertical slice as a registered Shared chapter")
	assert(not bible.contains("### SHARED-01 黑风山前"), "Obsolete Shared-01 / Black Wind numbering must not return")
	assert(not bible.contains("### SHARED-02 黑风山与观音禅院"), "Obsolete Shared-02 / Black Wind numbering must not return")
	assert(not bible.contains("### SHARED-04 鹰愁涧后的旅程"), "Obsolete Shared-04 / Eagle Sorrow numbering must not return")

	return {
		"passed": true,
		"shared_chapters_verified": chapters.size(),
		"shared_sequences_verified": shared_sequences.size(),
		"chapter_id_title_timeline_next_aligned": true,
		"yellow_wind_gap_documented": true,
		"obsolete_heading_ids_rejected": true
	}

static func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "Required JSON should open: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary, "Required JSON root should be an object: %s" % path)
	return parsed

static func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "Required text file should open: %s" % path)
	return file.get_as_text()
