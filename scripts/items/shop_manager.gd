class_name ShopManager
extends RefCounted

const SHOP_PATH := "res://data/items/shop_items.json"

var items: Dictionary = {}

func _init() -> void:
	var file := FileAccess.open(SHOP_PATH, FileAccess.READ)
	if file == null:
		push_error("ShopManager failed to open %s" % SHOP_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("ShopManager invalid JSON")
		return
	for item in parsed.get("items", []):
		if item is Dictionary:
			var id := str(item.get("id", ""))
			if id != "":
				items[id] = item.duplicate(true)

func get_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in items.values():
		result.append(item.duplicate(true))
	result.sort_custom(func(a, b): return int(a.get("price", 0)) < int(b.get("price", 0)))
	return result

func buy(manager: NarrativeManager, item_id: String, amount: int = 1) -> Dictionary:
	if manager == null or amount <= 0 or not items.has(item_id):
		return {}
	var item: Dictionary = items[item_id]
	var total := int(item.get("price", 0)) * amount
	var inventory := InventoryManager.new()
	inventory.restore(manager.state.get_inventory())
	var coins := int(inventory.currencies.get("COIN", 0))
	if coins < total:
		return {"ok": false, "reason": "INSUFFICIENT_COIN", "need": total, "have": coins}
	inventory.currencies["COIN"] = coins - total
	inventory.add_item(item_id, amount)
	manager.state.set_inventory(inventory.to_dict())
	manager.save()
	return {"ok": true, "item_id": item_id, "amount": amount, "spent": total, "inventory": inventory.to_dict()}
