class_name RewardService
extends RefCounted

## Canonical non-combat reward executor.
## EventRunner never mutates inventory directly; presentation asks this service to commit.

static func preview(rewards: Array) -> Array:
	var result: Array = []
	for raw_reward in rewards:
		var normalized := _normalize(raw_reward)
		if normalized.is_empty():
			continue
		result.append(normalized)
	return result

static func apply_to_manager(manager, rewards: Array) -> Dictionary:
	if manager == null:
		return {}
	var inventory := InventoryManager.new()
	if manager.state != null:
		inventory.restore(manager.state.get_inventory())
	else:
		return {}
	var granted := preview(rewards)
	for reward in granted:
		var reward_id := str(reward.get("id", ""))
		var amount := int(reward.get("amount", 0))
		if reward_id == "":
			continue
		if reward_id.begins_with("COIN_") or str(reward.get("type", "")).to_upper() == "CURRENCY":
			inventory.add_currency(str(reward.get("currency", "COIN")), amount)
		else:
			inventory.add_item(reward_id, amount)
	manager.state.set_inventory(inventory.to_dict())
	return {
		"granted": granted,
		"inventory": inventory.to_dict(),
	}

static func _normalize(raw_reward) -> Dictionary:
	if raw_reward is String:
		var reward_id := str(raw_reward)
		if reward_id.is_empty():
			return {}
		var amount := _coin_amount(reward_id)
		if amount > 0:
			return {"id": reward_id, "amount": amount, "type": "CURRENCY", "currency": "COIN"}
		return {"id": reward_id, "amount": 1, "type": "ITEM"}
	if raw_reward is Dictionary:
		var reward_id := str(raw_reward.get("id", raw_reward.get("item_id", "")))
		var amount := int(raw_reward.get("amount", 1))
		if reward_id.is_empty() or amount <= 0:
			return {}
		var reward_type := str(raw_reward.get("type", "ITEM")).to_upper()
		var currency := str(raw_reward.get("currency", "COIN"))
		return {"id": reward_id, "amount": amount, "type": reward_type, "currency": currency}
	return {}

static func _coin_amount(reward_id: String) -> int:
	match reward_id:
		"COIN_LOW": return 100
		"COIN_MEDIUM": return 300
		"COIN_HIGH": return 800
		"COIN_LEGENDARY": return 2000
	return 0
