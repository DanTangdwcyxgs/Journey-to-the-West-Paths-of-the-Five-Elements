extends Node

var engine: CombatEngine
var current_actor: Combatant
var sun: Combatant
var tang: Combatant
var sand_fox: Combatant
var basic_attack: CombatAction
var fire_staff: CombatAction

func _ready() -> void:
	sun = Combatant.new("wukong", "Sun Wukong", 220, 42, 16, 28, 4, {"fire": true, "strike": true})
	tang = Combatant.new("tangseng", "Tang Sanzang", 180, 18, 12, 20, 3, {"holy": true, "water": true})
	sand_fox = Combatant.new("yellow_wind", "Yellow Wind Adept", 360, 30, 20, 22, 5, {"fire": true, "strike": true})
	basic_attack = CombatAction.new("staff_strike", "Jin Gu Bang", "strike", 28, 1, 0)
	fire_staff = CombatAction.new("fire_eye", "Fire-Eye Insight", "fire", 34, 1, 0)

	engine = CombatEngine.new()
	engine.combat_log.connect(_on_combat_log)
	engine.combat_finished.connect(_on_combat_finished)
	engine.setup([sun, tang], [sand_fox])
	current_actor = engine.advance_turn()

	print("=== Black Myth JRPG combat prototype ===")
	print("Commands: attack, fire, boost, status, auto")
	_print_status()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			_player_action(basic_attack, false)
		KEY_2:
			_player_action(fire_staff, false)
		KEY_3:
			_player_action(basic_attack, true)
		KEY_ENTER:
			_auto_turn()
		KEY_SPACE:
			_print_status()

func _player_action(action: CombatAction, boosted: bool) -> void:
	if current_actor == null or current_actor == sand_fox:
		return
	var result := engine.perform_action(current_actor, sand_fox, action, boosted)
	if not result.get("ok", false):
		print("Action rejected: %s" % result.get("reason", "unknown"))
		return
	_end_player_turn()

func _end_player_turn() -> void:
	if not sand_fox.is_alive():
		return
	current_actor = engine.advance_turn()
	if current_actor == sand_fox:
		_enemy_turn()
		if sand_fox.is_alive():
			current_actor = engine.advance_turn()
	_print_status()

func _enemy_turn() -> void:
	var target := sun if sun.is_alive() else tang
	var enemy_action := CombatAction.new("wind_slash", "Yellow Wind", "wind", 24, 1, 0)
	engine.perform_action(sand_fox, target, enemy_action, false)

func _auto_turn() -> void:
	if current_actor == null:
		return
	var action := fire_staff if current_actor == sun else basic_attack
	_player_action(action, current_actor.bp >= 2)

func _print_status() -> void:
	print("%s HP %d/%d BP %d | %s HP %d/%d Shield %d/%d Broken=%s" % [sun.display_name, sun.hp, sun.max_hp, sun.bp, sand_fox.display_name, sand_fox.hp, sand_fox.max_hp, sand_fox.shield, sand_fox.max_shield, sand_fox.is_broken()])

func _on_combat_log(message: String) -> void:
	print(message)

func _on_combat_finished(winner: String) -> void:
	print("COMBAT FINISHED: %s" % winner)
