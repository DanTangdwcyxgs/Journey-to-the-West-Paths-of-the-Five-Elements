extends RefCounted

## Runtime regression for executable narrative content cross-references.

static func run_all() -> Dictionary:
	var valid := EventSequenceManager.get_definition("SHARED-03-EAGLE-SORROW-SEQUENCE")
	assert(valid != null)
	var result := EventSequenceValidator.validate(valid)
	assert(result.get("valid", false), str(result))

	var shared_04 := EventSequenceManager.get_definition("SHARED-04-EARLY-DEMON-TALES-SEQUENCE")
	assert(shared_04 != null)
	var shared_04_result := EventSequenceValidator.validate(shared_04)
	assert(shared_04_result.get("valid", false), str(shared_04_result))

	var shared_05 := EventSequenceManager.get_definition("SHARED-05-GAOJIAZHUANG-SEQUENCE")
	assert(shared_05 != null)
	var shared_05_result := EventSequenceValidator.validate(shared_05)
	assert(shared_05_result.get("valid", false), str(shared_05_result))

	var shared_06 := EventSequenceManager.get_definition("SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE")
	assert(shared_06 != null)
	var shared_06_result := EventSequenceValidator.validate(shared_06)
	assert(shared_06_result.get("valid", false), str(shared_06_result))

	var invalid := EventSequenceDefinition.new({
		"id": "TEST-EVENT-SEQUENCE-INVALID-REF",
		"namespace": "SHARED",
		"start": "choice",
		"nodes": [
			{"id":"choice", "type":"choice", "event_id":"MISSING_EVENT", "next":"battle"},
			{"id":"battle", "type":"battle", "encounter_id":"MISSING_ENCOUNTER", "source_chapter_id":"MISSING_CHAPTER", "next":"end"},
			{"id":"end", "type":"end"}
		]
	})
	var invalid_result := EventSequenceValidator.validate(invalid)
	assert(not invalid_result.get("valid", true))
	assert(invalid_result.get("errors", []).size() >= 3)

	return {
		"passed": true,
		"valid_sequence_cross_refs": true,
		"shared_04_sequence_validated": true,
		"shared_05_sequence_validated": true,
		"shared_06_sequence_validated": true,
		"invalid_sequence_rejected": true,
	}