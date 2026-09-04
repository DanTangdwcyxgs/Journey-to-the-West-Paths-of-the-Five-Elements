class_name InventoryManager
extends RefCounted

## Minimal persistent inventory used by battle rewards and world content.

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

func has_item(item_id: String, amount: int = 1) -> bool:
	return int(items.get(item_id, 0)) >= amount

func to_dict() -> Dictionary:
	return {"currencies": currencies.duplicate(true), "items": items.duplicate(true)}

func restore(data: Dictionary) -> void:
	currencies = data.get("currencies", {"COIN": 0}).duplicate(true)
	items = data.get("items", {}).duplicate(true)
	if not currencies.has("COIN"):
		currencies["COIN"] = 0
