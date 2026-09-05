extends RefCounted

static func run_all() -> Dictionary:
	var manager := NarrativeManager.new()
	assert(manager.start_new_game("TANG"))
	var before := manager.state.get_inventory()
	assert(int(before.get("currencies", {}).get("COIN", 0)) == 0)

	var preview := RewardService.preview(["COIN_LOW", "HERB", {"id":"PILL", "amount":2, "type":"ITEM"}])
	assert(preview.size() == 3)
	assert(int(preview[0].get("amount", 0)) == 100)
	assert(int(preview[1].get("amount", 0)) == 1)
	assert(int(preview[2].get("amount", 0)) == 2)
	assert(int(manager.state.get_inventory().get("currencies", {}).get("COIN", 0)) == 0)

	var applied := RewardService.apply_to_manager(manager, ["COIN_LOW", "HERB", {"id":"PILL", "amount":2, "type":"ITEM"}])
	assert(not applied.is_empty())
	var inventory := manager.state.get_inventory()
	assert(int(inventory.get("currencies", {}).get("COIN", 0)) == 100)
	assert(int(inventory.get("items", {}).get("HERB", 0)) == 1)
	assert(int(inventory.get("items", {}).get("PILL", 0)) == 2)

	return {
		"passed": true,
		"supports_preview": true,
		"supports_noncombat_commit": true,
		"supports_currency_and_item_rewards": true,
	}
