class_name BattleRewardService
extends RefCounted

## Converts a battle reward payload into persistent inventory + journal state.

static func preview_rewards(inventory_data: Dictionary, rewards: Array) -> Dictionary:
	var inventory := InventoryManager.new()
	inventory.restore(inventory_data)
	var granted: Array[Dictionary] = []
	for reward in rewards:
		var reward_id := str(reward)
		match reward_id:
			"COIN_LOW":
				inventory.add_currency("COIN", 100)
				granted.append({"id": reward_id, "amount": 100})
			"COIN_MEDIUM":
				inventory.add_currency("COIN", 300)
				granted.append({"id": reward_id, "amount": 300})
			"COIN_HIGH":
				inventory.add_currency("COIN", 800)
				granted.append({"id": reward_id, "amount": 800})
			"COIN_LEGENDARY":
				inventory.add_currency("COIN", 2000)
				granted.append({"id": reward_id, "amount": 2000})
			_:
				inventory.add_item(reward_id, 1)
				granted.append({"id": reward_id, "amount": 1})
	return {"granted": granted, "inventory": inventory.to_dict()}

static func apply_victory(manager: NarrativeManager, target_id: String, target_name: String, rewards: Array, world_effects: Array = []) -> Dictionary:
	if manager == null or target_id == "":
		return {}
	var preview := preview_rewards(manager.state.get_inventory(), rewards)
	manager.state.set_inventory(preview.get("inventory", {}))
	var journal_entry := manager.record_battle_result(target_id, target_name, "VICTORY", rewards, world_effects)
	return {"granted": preview.get("granted", []), "journal_entry": journal_entry, "inventory": preview.get("inventory", {})}
