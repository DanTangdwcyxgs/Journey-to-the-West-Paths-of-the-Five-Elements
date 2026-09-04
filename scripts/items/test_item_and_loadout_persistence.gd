extends RefCounted

## Static regression checks for the item economy and saved preparation layer.

static func run() -> Dictionary:
	var results := {}
	var inventory := InventoryManager.new()
	inventory.add_item("HERB", 2)
	results["item_added"] = inventory.has_item("HERB", 2)
	results["remove_one"] = inventory.remove_item("HERB", 1)
	results["one_remains"] = inventory.has_item("HERB", 1) and not inventory.has_item("HERB", 2)

	var manager := NarrativeManager.new()
	manager.start_new_game("WUKONG")
	var loadout := LoadoutManager.new()
	results["has_profiles"] = not loadout.definitions.is_empty()
	results["equip"] = loadout.equip("WUKONG_FIRE_BURST")
	manager.state.set_equipped_loadouts(loadout.to_dict())
	var restored := NarrativeState.from_dict(manager.serialize())
	results["loadout_persists"] = str(restored.get_equipped_loadouts().get("equipped_profiles", {}).get("WUKONG", "")) == "WUKONG_FIRE_BURST"
	return results
