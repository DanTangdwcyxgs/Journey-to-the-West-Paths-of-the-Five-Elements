class_name InventoryManager
extends RefCounted

## Persistent inventory used by shops, consumables, battle rewards, and world content.

var currencies: Dictionary = {"COIN": 0}
var items: Dictionary = {}

func add_currency(currency_id: String, amount: int) -> int:
	if currency_id == "" or amount == 0:
		return int(currencies.get(currency_id, 0))
	currencies[currency_id] = maxi(int(currencies.get(currency_id, 0)) + amount, 0)
	return int(currencies[currency_id])

func add_item(item_id: String, amount: int = 1) -> int:
	if item_id == "" or amount <= 0:
		return int(items.get(item_id, 0))
	items[item_id] = int(items.get(item_id, 0)) + amount
	return int(items[item_id])

func remove_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or not has_item(item_id, amount):
		return false
	items[item_id] = int(items.get(item_id, 0)) - amount
	if int(items[item_id]) <= 0:
		items.erase(item_id)
	return true

func has_item(item_id: String, amount: int = 1) -> bool:
	return amount > 0 and int(items.get(item_id, 0)) >= amount

func to_dict() -> Dictionary:
	return {"currencies": currencies.duplicate(true), "items": items.duplicate(true)}

func restore(data: Dictionary) -> void:
	currencies = data.get("currencies", {"COIN": 0}).duplicate(true)
	items = data.get("items", {}).duplicate(true)
	if not currencies.has("COIN"):
		currencies["COIN"] = 0
