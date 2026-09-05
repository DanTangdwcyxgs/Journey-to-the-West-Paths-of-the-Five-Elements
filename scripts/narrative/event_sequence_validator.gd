class_name EventSequenceValidator
extends RefCounted

## Cross-reference validator for content CI.
## Structural validation stays in EventSequenceDefinition; this layer checks
## references into event, encounter and chapter content.

static func validate(definition: EventSequenceDefinition) -> Dictionary:
	var errors: Array[String] = []
	if definition == null:
		return {"valid": false, "errors": ["missing sequence definition"]}
	var structure := definition.validate()
	if not structure.get("valid", false):
		for error in structure.get("errors", []):
			errors.append(str(error))
		return {"valid": false, "errors": errors}

	var namespace_id := str(definition.to_dict().get("namespace", "SHARED")).to_upper()
	if namespace_id != "ORIGIN" and namespace_id != "SHARED":
		errors.append("invalid namespace: %s" % namespace_id)
		return {"valid": false, "errors": errors}

	var encounter_manager := EncounterManager.new()
	var origin_manager := OriginEventManager.new()
	var shared_manager := SharedEventManager.new()
	var origin_routes := origin_manager.definitions
	for node in definition.get_nodes():
		if not node is Dictionary:
			continue
		var node_id := str(node.get("id", ""))
		var kind := str(node.get("type", node.get("kind", ""))).to_lower()
		if kind == "choice":
			var event_id := str(node.get("event_id", ""))
			if event_id.is_empty():
				errors.append("choice node missing event_id: %s" % node_id)
			elif namespace_id == "SHARED" and not shared_manager.has_event(event_id):
				errors.append("shared event not found %s at node %s" % [event_id, node_id])
			elif namespace_id == "ORIGIN" and not origin_manager.has_event(event_id):
				errors.append("origin event not found %s at node %s" % [event_id, node_id])
		elif kind == "battle":
			var encounter_id := str(node.get("encounter_id", ""))
			if encounter_id.is_empty() or encounter_manager.get_definition(encounter_id).is_empty():
				errors.append("encounter not found %s at node %s" % [encounter_id, node_id])
			var source_chapter_id := str(node.get("source_chapter_id", ""))
			if source_chapter_id.is_empty():
				errors.append("battle node missing source_chapter_id: %s" % node_id)
			elif namespace_id == "SHARED":
				var chapter := SharedJourneyManager.get_chapter(source_chapter_id)
				if chapter.is_empty():
					errors.append("shared source chapter not found %s at node %s" % [source_chapter_id, node_id])
				elif str(chapter.get("encounter_id", "")) != encounter_id:
					errors.append("battle encounter %s does not match chapter %s" % [encounter_id, source_chapter_id])
			elif namespace_id == "ORIGIN":
				if not _origin_chapter_exists(origin_routes, source_chapter_id):
					errors.append("origin source chapter not found %s at node %s" % [source_chapter_id, node_id])

	return {"valid": errors.is_empty(), "errors": errors}

static func _origin_chapter_exists(routes: Dictionary, chapter_id: String) -> bool:
	for route in routes.values():
		if not route is Dictionary:
			continue
		for chapter in route.get("chapters", []):
			if str(chapter.get("id", "")) == chapter_id:
				return true
	return false
