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
		"TANG-01-SEQUENCE",
	]
	var catalog_errors := EventSequenceManager.get_load_errors()
	assert(catalog_errors.is_empty(), "production sequence catalogs must load without rejected entries: %s" % str(catalog_errors))

	var all_sequence_ids := EventSequenceManager.get_all_ids()
	assert(all_sequence_ids.size() >= sequence_ids.size(), "the complete production catalog should contain all critical sequence IDs")
	for sequence_id in sequence_ids:
		assert(sequence_id in all_sequence_ids, "critical production sequence should load: %s" % sequence_id)

	var validated_count := 0
	for sequence_id in all_sequence_ids:
		var definition := EventSequenceManager.get_definition(sequence_id)
		assert(definition != null, "%s should be present in the runtime catalog" % sequence_id)
		var validation := EventSequenceValidator.validate(definition)
		assert(validation.get("valid", false), "%s -> %s" % [sequence_id, str(validation)])
		validated_count += 1

	var contradictory_shared_metadata := EventSequenceValidator._namespace_metadata_errors("SHARED", "TEST-SHARED", {
		"id": "TEST-SHARED",
		"chapter_type": "ORIGIN",
		"is_origin": true,
		"is_shared": false,
	})
	assert(contradictory_shared_metadata.size() == 3, "shared namespace should reject every explicit origin metadata contradiction: %s" % str(contradictory_shared_metadata))
	assert("chapter_type ORIGIN" in str(contradictory_shared_metadata))
	assert("is_origin=true" in str(contradictory_shared_metadata))
	assert("is_shared=false" in str(contradictory_shared_metadata))

	var contradictory_origin_metadata := EventSequenceValidator._namespace_metadata_errors("ORIGIN", "TEST-ORIGIN", {
		"id": "TEST-ORIGIN",
		"chapter_type": "SHARED_JOURNEY",
		"is_origin": false,
		"is_shared": true,
	})
	assert(contradictory_origin_metadata.size() == 3, "origin namespace should reject every explicit shared metadata contradiction: %s" % str(contradictory_origin_metadata))
	assert("chapter_type SHARED_JOURNEY" in str(contradictory_origin_metadata))
	assert("is_origin=false" in str(contradictory_origin_metadata))
	assert("is_shared=true" in str(contradictory_origin_metadata))

	var invalid := EventSequenceDefinition.new({
		"id": "TEST-EVENT-SEQUENCE-INVALID-REF",
		"chapter_id": "SHARED-03-EAGLE-SORROW",
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

	var chapter_mismatch := EventSequenceDefinition.new({
		"id": "TEST-EVENT-SEQUENCE-CHAPTER-MISMATCH",
		"chapter_id": "SHARED-03-EAGLE-SORROW",
		"namespace": "SHARED",
		"start": "battle",
		"nodes": [
			{"id":"battle", "type":"battle", "encounter_id":"SHARED_EAGLE_SORROW", "source_chapter_id":"SHARED-05-GAOJIAZHUANG", "next":"end"},
			{"id":"end", "type":"end"}
		]
	})
	var mismatch_result := EventSequenceValidator.validate(chapter_mismatch)
	assert(not mismatch_result.get("valid", true))
	assert("does not match sequence chapter" in str(mismatch_result.get("errors", [])))

	var namespace_mismatch := EventSequenceDefinition.new({
		"id": "TEST-EVENT-SEQUENCE-NAMESPACE-MISMATCH",
		"chapter_id": "SHARED-03-EAGLE-SORROW",
		"namespace": "ORIGIN",
		"start": "end",
		"nodes": [{"id":"end", "type":"end"}]
	})
	var namespace_result := EventSequenceValidator.validate(namespace_mismatch)
	assert(not namespace_result.get("valid", true))
	assert("origin sequence chapter not found" in str(namespace_result.get("errors", [])))

	var origin_route_mismatch := EventSequenceDefinition.new({
		"id": "TEST-EVENT-SEQUENCE-ORIGIN-ROUTE-MISMATCH",
		"chapter_id": "WUJING-03",
		"namespace": "ORIGIN",
		"start": "battle",
		"nodes": [
			{"id":"battle", "type":"battle", "encounter_id":"WUJING_ORIGIN_FLOWING_SANDS", "source_chapter_id":"WUJING-03", "source_route_id":"BAJIE_ORIGIN", "next":"end"},
			{"id":"end", "type":"end"}
		]
	})
	var origin_route_result := EventSequenceValidator.validate(origin_route_mismatch)
	assert(not origin_route_result.get("valid", true))
	assert("does not match chapter route" in str(origin_route_result.get("errors", [])))

	var origin_missing_route := EventSequenceDefinition.new({
		"id": "TEST-EVENT-SEQUENCE-ORIGIN-MISSING-ROUTE",
		"chapter_id": "WUJING-03",
		"namespace": "ORIGIN",
		"start": "battle",
		"nodes": [
			{"id":"battle", "type":"battle", "encounter_id":"WUJING_ORIGIN_FLOWING_SANDS", "source_chapter_id":"WUJING-03", "next":"end"},
			{"id":"end", "type":"end"}
		]
	})
	var origin_missing_route_result := EventSequenceValidator.validate(origin_missing_route)
	assert(not origin_missing_route_result.get("valid", true))
	assert("missing source_route_id" in str(origin_missing_route_result.get("errors", [])))

	return {
		"passed": true,
		"production_sequences_validated": validated_count,
		"catalog_load_errors_checked": true,
		"invalid_sequence_rejected": true,
		"chapter_cross_reference_rejected": true,
		"namespace_cross_reference_rejected": true,
		"origin_route_cross_reference_rejected": true,
		"origin_route_presence_rejected": true,
		"route_specific_catalog_validated": true,
		"namespace_metadata_consistency_checked": true,
		"chapter_metadata_mismatches_rejected": true,
	}
