extends RefCounted

## Regression checks for Bai Longma's temporary four-form system.

static func run() -> void:
	var manager := LongmaFormManager.new()
	var longma := Combatant.new("longma", "白龙马", 120, 20, 10, 12, 2, {})
	longma.mechanic_resource = 2

	var first := manager.shift(longma)
	assert(first.get("id", "") == "eagle")
	assert(longma.longma_form == "eagle")
	assert(longma.longma_form_turns == 3)
	assert(longma.mechanic_resource == 1)
	assert(longma.attack == 23)
	assert(longma.defense == 8)
	assert(longma.speed == 20)

	longma.begin_turn()
	assert(longma.longma_form == "eagle")
	assert(longma.longma_form_turns == 2)
	longma.begin_turn()
	longma.begin_turn()
	assert(longma.longma_form == "horse")
	assert(longma.longma_form_turns == 0)
	assert(longma.attack == 20)
	assert(longma.defense == 10)
	assert(longma.speed == 12)

	longma.mechanic_resource = 1
	var second := manager.shift(longma)
	assert(second.get("id", "") == "eagle")
	longma.mechanic_resource = 0
	assert(manager.shift(longma).is_empty())
