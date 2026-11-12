extends RefCounted

## Regression contract for the source-backed canonical 81-trial catalog.
const TRIALS_PATH := "res://data/narrative/reference/canonical_81_trials.json"
const CHAPTER_INDEX_PATH := "res://data/narrative/reference/xiyouji_chapter_index.json"
const SHARED_CHAPTERS_PATH := "res://data/narrative/shared_chapters.json"

static func run_all() -> Dictionary:
	var catalog := _read_json(TRIALS_PATH)
	var chapter_index := _read_json(CHAPTER_INDEX_PATH)
	var shared_catalog := _read_json(SHARED_CHAPTERS_PATH)
	assert(catalog.get("schema_version", 0) == 1, "canonical trial catalog schema should be version 1")
	assert(chapter_index.get("schema_version", 0) == 1, "pinned novel chapter index should load")
	var trials: Array = catalog.get("trials", [])
	var novel_chapters: Array = chapter_index.get("chapters", [])
	assert(trials.size() == 81, "canonical catalog must contain exactly 81 records")
	assert(novel_chapters.size() == 100, "pinned novel index must contain exactly 100 chapters")

	var chapter_numbers: Dictionary = {}
	for chapter in novel_chapters:
		var chapter_number := int(chapter.get("number", 0))
		assert(chapter_number >= 1 and chapter_number <= 100, "novel chapter number must be within 1..100")
		assert(not str(chapter.get("title", "")).strip_edges().is_empty(), "novel chapter title must not be empty")
		assert(not chapter_numbers.has(str(chapter_number)), "novel chapter numbers must be unique")
		chapter_numbers[str(chapter_number)] = true

	var shared_ids: Dictionary = {}
	for chapter in shared_catalog.get("chapters", []):
		shared_ids[str(chapter.get("id", ""))] = true

	var trial_ids: Dictionary = {}
	var listed_count := 0
	var closing_episode_count := 0
	var runtime_evidence_count := 0
	var partial_crosswalk_count := 0
	var vertical_slice_count := 0
	for index in range(trials.size()):
		var trial: Dictionary = trials[index]
		var expected_number := index + 1
		var expected_id := "TRIAL-%03d" % expected_number
		assert(int(trial.get("number", 0)) == expected_number, "%s must be in canonical order" % expected_id)
		assert(str(trial.get("id", "")) == expected_id, "trial ID sequence must be contiguous: %s" % expected_id)
		assert(not str(trial.get("canonical_name", "")).strip_edges().is_empty(), "%s must have a source name" % expected_id)
		assert(not trial_ids.has(expected_id), "%s must be unique" % expected_id)
		trial_ids[expected_id] = true

		var line_range: Array = trial.get("chapter_99_line_range", [])
		assert(line_range.size() == 2, "%s must carry chapter 99 line evidence" % expected_id)
		assert(int(line_range[0]) > 0 and int(line_range[1]) >= int(line_range[0]), "%s line evidence range must be valid" % expected_id)
		var source_status := str(trial.get("source_status", ""))
		if expected_number <= 80:
			listed_count += 1
			assert(source_status == "LISTED_IN_CHAPTER_99_LEDGER", "%s should come from the 80-item ledger" % expected_id)
			var expected_line := 119 + int((expected_number - 1) / 2)
			assert(int(line_range[0]) == expected_line and int(line_range[1]) == expected_line, "%s should point at its paired ledger line" % expected_id)
		else:
			closing_episode_count += 1
			assert(source_status == "DERIVED_FROM_CHAPTER_99_CLOSING_EPISODE", "TRIAL-081 must be explicitly marked as the closing-episode-derived item")
			assert(int(line_range[0]) <= 162 and int(line_range[1]) >= 175, "TRIAL-081 evidence should cover the added ordeal episode")

		var refs: Array = trial.get("novel_chapters", [])
		assert(not refs.is_empty(), "%s must have at least one novel chapter locator" % expected_id)
		for chapter_number in refs:
			assert(chapter_numbers.has(str(int(chapter_number))), "%s references a chapter absent from the pinned 100-chapter index" % expected_id)

		for shared_id_variant in trial.get("game_shared_chapter_ids", []):
			var shared_id := str(shared_id_variant)
			assert(shared_ids.has(shared_id), "%s crosswalk target does not exist in shared_chapters.json: %s" % [expected_id, shared_id])

		match str(trial.get("game_mapping_status", "")):
			"RUNTIME_EVIDENCE": runtime_evidence_count += 1
			"PARTIAL_CROSSWALK": partial_crosswalk_count += 1
			"VERTICAL_SLICE_NOT_MAINLINE_MAPPED": vertical_slice_count += 1
			"UNMAPPED":
				assert(trial.get("game_shared_chapter_ids", []).is_empty(), "%s unmapped record must not claim shared chapter IDs" % expected_id)
			_:
				assert(false, "%s has an unsupported game mapping status" % expected_id)

	assert(listed_count == 80, "the source ledger must preserve exactly 80 numbered entries")
	assert(closing_episode_count == 1, "exactly one final trial should be derived from the closing episode")
	assert(str(trials[80].get("canonical_name", "")) == "通天河补一难", "TRIAL-081 should name the closing Tongtian River episode")
	assert(runtime_evidence_count == 4, "current crosswalk should identify exactly four runtime-evidenced items")
	assert(partial_crosswalk_count == 3, "current crosswalk should identify exactly three partial items")
	assert(vertical_slice_count == 2, "current crosswalk should identify exactly two un-wired vertical-slice items")

	return {
		"passed": true,
		"trials_verified": trials.size(),
		"numbered_ledger_items": listed_count,
		"closing_episode_items": closing_episode_count,
		"novel_chapters_verified": novel_chapters.size(),
		"runtime_evidence_mappings": runtime_evidence_count,
		"partial_mappings": partial_crosswalk_count,
		"unwired_vertical_slices": vertical_slice_count,
		"sequential_ids_unique": true,
		"chapter_references_valid": true,
		"shared_crosswalk_targets_exist": true
	}

static func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "required JSON file should open: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary, "required JSON root should be an object: %s" % path)
	return parsed
