extends RefCounted

## Runtime regression for executable narrative content cross-references.

static func run_all() -> Dictionary:
	var sequence_ids := [
		"SHARED-03-EAGLE-SORROW-SEQUENCE",
		"SHARED-04-EARLY-DEMON-TALES-SEQUENCE",
		"SHARED-05-GAOJIAZHUANG-SEQUENCE",
		"SHARED-06-FOUR-PERSON-JOURNEY-SEQUENCE",
		"SHARED-07-FLOWING-SANDS-SEQUENCE",
		"SHARED-08-PARTY-FULL-SEQUENCE",
		"SHARED-09-FULL-PILGRIMAGE-SEQUENCE",
	]
	for sequence_id in sequence_ids:
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, sequence_id)
		var validation := EventSequenceValidator.validate(definition)
		assert(validation.get("valid", false), "%s -> %s" % [sequence_id, str(validation)])

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
		"shared_sequences_validated": sequence_ids.size(),
		"invalid_sequence_rejected": true,
	}