class_name BountyRewardService
extends RefCounted

## Resolves a defeated bounty into inventory, journal, and bounty state.

static func resolve_defeat(manager: NarrativeManager, bounty_manager: BountyManager, bounty_id: String) -> Dictionary:
	if manager == null or bounty_manager == null or not bounty_manager.has_bounty(bounty_id):
		return {}
	var result := bounty_manager.defeat(bounty_id)
	if result.is_empty():
		return {}
	var definition := bounty_manager.get_definition(bounty_id)
	var target_name := str(definition.get("name", bounty_id))
	var rewards: Array = result.get("rewards", [])
	var world_effects: Array = result.get("world_effects", [])
	var applied := BattleRewardService.apply_victory(manager, bounty_id, target_name, rewards, world_effects)
	manager.save()
	return {
		"bounty_id": bounty_id,
		"target_name": target_name,
		"rewards": rewards,
		"world_effects": world_effects,
		"memory_hooks": result.get("memory_hooks", []),
		"applied": applied,
	}
