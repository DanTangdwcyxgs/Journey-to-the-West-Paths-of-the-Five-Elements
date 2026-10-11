class_name BountyRewardService
extends RefCounted

## Resolves one bounty defeat as a single NarrativeState + BountyManager transaction.

static func resolve_defeat(
	manager: NarrativeManager,
	bounty_manager: BountyManager,
	bounty_id: String,
	inventory_after_battle: Dictionary = {}
) -> Dictionary:
	if manager == null or manager.state == null or bounty_manager == null or not bounty_manager.has_bounty(bounty_id):
		return {}

	var narrative_before: Dictionary = manager.serialize().duplicate(true)
	var bounty_before: Dictionary = bounty_manager.to_dict().duplicate(true)
	if not inventory_after_battle.is_empty():
		manager.state.set_inventory(inventory_after_battle)

	var result := bounty_manager.defeat(bounty_id)
	if result.is_empty():
		manager.restore_snapshot(narrative_before)
		bounty_manager.restore(bounty_before)
		return {}

	var definition := bounty_manager.get_definition(bounty_id)
	var target_name := str(definition.get("name", bounty_id))
	var rewards: Array = result.get("rewards", [])
	var world_effects: Array = result.get("world_effects", [])
	var applied := BattleRewardService.apply_victory(manager, bounty_id, target_name, rewards, world_effects)
	if applied.is_empty():
		manager.restore_snapshot(narrative_before)
		bounty_manager.restore(bounty_before)
		return {}

	if not manager.save():
		manager.restore_snapshot(narrative_before)
		bounty_manager.restore(bounty_before)
		return {}

	return {
		"bounty_id": bounty_id,
		"target_name": target_name,
		"rewards": rewards,
		"world_effects": world_effects,
		"memory_hooks": result.get("memory_hooks", []),
		"applied": applied,
	}
