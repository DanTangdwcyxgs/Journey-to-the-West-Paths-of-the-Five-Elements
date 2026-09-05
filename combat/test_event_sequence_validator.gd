extends RefCounted

## Runtime regression for executable narrative content cross-references.

static func run_all() -> Dictionary:
	var valid := EventSequenceManager.get_definition("SHARED-03-EAGLE-SORROW-SEQUENCE")
	assert(valid != null)
	var result := EventSequenceValidator.validate(valid)
	assert(result.get("valid", false), str(result))

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
		"invalid_sequence_rejected": true,
	}