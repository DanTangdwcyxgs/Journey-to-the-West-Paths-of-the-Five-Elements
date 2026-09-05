extends SceneTree

## Integration-style regression coverage for the real CombatEngine path used by shared encounters.
## This deliberately avoids BattleUI/save I/O so it can validate combat deterministically.
func _initialize() -> void:
	var encounter_manager := EncounterManager.new()
	for encounter_id in ["SHARED_EAGLE_SORROW", "SHARED_GAOJIAZHUANG", "SHARED_FLOWING_SANDS"]:
		_run_shared_encounter(encounter_manager, encounter_id)
	print("ALL SHARED ENCOUNTER COMBAT TESTS PASSED")
	quit(0)

func _run_shared_encounter(encounter_manager: EncounterManager, encounter_id: String) -> void:
	var enemies := encounter_manager.build_enemies(encounter_id)
	_assert(enemies.size() == 2, "%s should build two enemies" % encounter_id)

	# Overpowered but formation-valid party: the test is about combat rules, not balance.
	var tang := Combatant.new("tangseng", "Tang Sanzang", 500, 80, 1, 30, 30, {"fire": true, "strike": true, "ice": true, "water": true}, "front")
	var wukong := Combatant.new("wukong", "Sun Wukong", 500, 90, 1, 35, 29, {"fire": true, "strike": true, "ice": true, "water": true}, "front")
	var bajie := Combatant.new("bajie", "Zhu Bajie", 500, 85, 1, 30, 28, {"fire": true, "strike": true, "ice": true, "water": true}, "front")
	var allies := [tang, wukong, bajie]
	var engine := CombatEngine.new()
	var finished := ""
	engine.combat_finished.connect(func(winner: String): finished = winner)
	engine.setup(allies, enemies)

	var turns := 0
	while finished == "" and turns < 100:
		var actor := engine.advance_turn()
		_assert(actor != null, "%s should always have a living actor before battle ends" % encounter_id)
		if actor in allies:
			var target := _first_living(enemies)
			_assert(target != null, "%s should have a target while battle is active" % encounter_id)
			var action := _weakness_action(target)
			var result := engine.perform_action(actor, target, action)
			_assert(result.get("ok", false), "%s player action should succeed" % encounter_id)
		else:
			var target := _first_living(allies)
			_assert(target != null, "%s enemy should have a living target" % encounter_id)
			var action := encounter_manager.choose_ai_action(actor, allies, engine.turn_number)
			var result := engine.perform_action(actor, target, action)
			_assert(result.get("ok", false), "%s AI action should execute" % encounter_id)
		turns += 1

	_assert(finished == "allies", "%s should end in an ally victory, got=%s" % [encounter_id, finished])
	_assert(enemies.all(func(unit): return not unit.is_alive()), "%s should defeat every enemy" % encounter_id)
	_assert(turns < 100, "%s should resolve deterministically before the safety cap" % encounter_id)

func _first_living(units: Array[Combatant]) -> Combatant:
	for unit in units:
		if unit.is_alive():
			return unit
	return null

func _weakness_action(target: Combatant) -> CombatAction:
	for element in ["fire", "ice", "water", "strike"]:
		if target.weaknesses.get(element, false):
			return CombatAction.new("test_%s" % element, "Test %s" % element, element, 120, 2, 0)
	return CombatAction.new("test_plain", "Test Strike", "strike", 120, 2, 0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: %s" % message)
		quit(1)
