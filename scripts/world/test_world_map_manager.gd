extends RefCounted

## Static data/logic checks for the exploration layer.
## Run inside the Godot editor/project test harness when available.

static func run() -> void:
	var state := NarrativeState.new()
	state.initialize_for_start("WUKONG", 100)
	state.record_milestone("WUKONG_RECRUITED", 100)
	var manager := NarrativeManager.new()
	manager.state = state
	var world := WorldMapManager.new()

	assert(not world.get_node("FIVE_ELEMENTS_MOUNTAIN").is_empty())
	assert(world.can_visit(manager, "FIVE_ELEMENTS_MOUNTAIN"))
	assert(world.visit(manager, "FIVE_ELEMENTS_MOUNTAIN"))
	assert(world.get_current_location(manager) == "FIVE_ELEMENTS_MOUNTAIN")
	assert(world.can_visit(manager, "EAGLE_SORROW"))
	assert(world.visit(manager, "EAGLE_SORROW"))

	var rumors := world.get_rumors_at_current_location(manager)
	assert(rumors.size() == 1)
	var rumor_id := str(rumors[0].get("id", ""))
	var bounty_id := str(rumors[0].get("bounty_id", ""))
	assert(not rumor_id.is_empty())
	assert(not bounty_id.is_empty())
	assert(not world.hear_rumor(manager, rumor_id).is_empty())
	assert(bounty_id in state.get_world_state().get("discovered_bounties", []))
	assert(world.get_rumors_at_current_location(manager).is_empty())

	state.current_global_timeline = 100
	assert(not world.can_visit(manager, "GAOJIAZHUANG"))
	state.record_milestone("BAI_LONGMA_RECRUITED", 110)
	state.current_global_timeline = 110
	assert(not world.can_visit(manager, "GAOJIAZHUANG"))
	state.current_global_timeline = 130
	state.record_milestone("ZHU_BAJIE_RECRUITED", 130)
	assert(world.can_visit(manager, "BLACK_WIND_MOUNTAINS") or world.can_visit(manager, "GAOJIAZHUANG"))
