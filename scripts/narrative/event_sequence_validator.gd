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

	var data := definition.to_dict()
	var namespace_id := str(data.get("namespace", "SHARED")).to_upper()
	if namespace_id != "ORIGIN" and namespace_id != "SHARED":
		errors.append("invalid namespace: %s" % namespace_id)
		return {"valid": false, "errors": errors}

	var chapter_id := str(data.get("chapter_id", ""))
	var origin_routes := OriginRouteManager.new().definitions
	var origin_route_id := _origin_route_id_for_chapter(origin_routes, chapter_id)
	if chapter_id.is_empty():
		errors.append("sequence missing chapter_id")
	elif namespace_id == "SHARED":
		var shared_chapter := SharedJourneyManager.get_chapter(chapter_id)
		if shared_chapter.is_empty():
			errors.append("shared sequence chapter not found: %s" % chapter_id)
		else:
			for metadata_error in _namespace_metadata_errors(namespace_id, chapter_id, shared_chapter):
				errors.append(metadata_error)
	else:
		if origin_route_id.is_empty():
			errors.append("origin sequence chapter not found: %s" % chapter_id)
		else:
			var origin_chapter := _origin_chapter_for_id(origin_routes, chapter_id)
			for metadata_error in _namespace_metadata_errors(namespace_id, chapter_id, origin_chapter):
				errors.append(metadata_error)

	var encounter_manager := EncounterManager.new()
	var origin_manager := OriginEventManager.new()
	var shared_manager := SharedEventManager.new()
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
			var encounter_definition: Dictionary = encounter_manager.get_definition(encounter_id)
			if encounter_id.is_empty() or encounter_definition.is_empty():
				errors.append("encounter not found %s at node %s" % [encounter_id, node_id])
			var source_chapter_id := str(node.get("source_chapter_id", ""))
			if source_chapter_id.is_empty():
				errors.append("battle node missing source_chapter_id: %s" % node_id)
			elif source_chapter_id != chapter_id:
				errors.append("battle source chapter %s does not match sequence chapter %s" % [source_chapter_id, chapter_id])
			elif namespace_id == "SHARED":
				var shared_chapter := SharedJourneyManager.get_chapter(source_chapter_id)
				if shared_chapter.is_empty():
					errors.append("shared source chapter not found %s at node %s" % [source_chapter_id, node_id])
				elif str(shared_chapter.get("encounter_id", "")) != encounter_id:
					errors.append("battle encounter %s does not match chapter %s" % [encounter_id, source_chapter_id])
			elif namespace_id == "ORIGIN":
				if origin_route_id.is_empty():
					continue
				var source_route_id := str(node.get("source_route_id", ""))
				if source_route_id.is_empty():
					errors.append("origin battle node missing source_route_id: %s" % node_id)
				elif source_route_id != origin_route_id:
					errors.append("origin battle source route %s does not match chapter route %s" % [source_route_id, origin_route_id])
				elif str(encounter_definition.get("source", "")) != origin_route_id:
					errors.append("origin encounter %s source %s does not match route %s" % [encounter_id, str(encounter_definition.get("source", "")), origin_route_id])

	return {"valid": errors.is_empty(), "errors": errors}

static func _namespace_metadata_errors(namespace_id: String, chapter_id: String, chapter: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if chapter.is_empty():
		return errors
	var chapter_type := str(chapter.get("chapter_type", "")).strip_edges().to_upper()
	if namespace_id == "SHARED":
		if chapter_type == "ORIGIN":
			errors.append("shared sequence chapter %s has conflicting chapter_type ORIGIN" % chapter_id)
		if chapter.has("is_origin") and bool(chapter.get("is_origin")):
			errors.append("shared sequence chapter %s is marked is_origin=true" % chapter_id)
		if chapter.has("is_shared") and not bool(chapter.get("is_shared")):
			errors.append("shared sequence chapter %s is marked is_shared=false" % chapter_id)
	elif namespace_id == "ORIGIN":
		if chapter_type == "SHARED_JOURNEY":
			errors.append("origin sequence chapter %s has conflicting chapter_type SHARED_JOURNEY" % chapter_id)
		if chapter.has("is_origin") and not bool(chapter.get("is_origin")):
			errors.append("origin sequence chapter %s is marked is_origin=false" % chapter_id)
		if chapter.has("is_shared") and bool(chapter.get("is_shared")):
			errors.append("origin sequence chapter %s is marked is_shared=true" % chapter_id)
	return errors

static func _origin_chapter_for_id(routes: Dictionary, chapter_id: String) -> Dictionary:
	for route in routes.values():
		if not route is Dictionary:
			continue
		for chapter in route.get("chapters", []):
			if chapter is Dictionary and str(chapter.get("id", "")) == chapter_id:
				return chapter.duplicate(true)
	return {}

static func _origin_chapter_exists(routes: Dictionary, chapter_id: String) -> bool:
	return not _origin_route_id_for_chapter(routes, chapter_id).is_empty()

static func _origin_route_id_for_chapter(routes: Dictionary, chapter_id: String) -> String:
	for route in routes.values():
		if not route is Dictionary:
			continue
		var route_id := str(route.get("route_id", ""))
		for chapter in route.get("chapters", []):
			if str(chapter.get("id", "")) == chapter_id:
				return route_id
	return ""
