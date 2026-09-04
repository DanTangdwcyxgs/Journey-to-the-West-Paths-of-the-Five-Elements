class_name BattleUI
extends Control

const NAMES := {"tangseng":"唐三藏", "wukong":"孙悟空", "bajie":"猪八戒", "wujing":"沙悟净", "longma":"白龙马", "yellow_wind":"黄风妖王"}

var engine := CombatEngine.new()
var party := PartyManager.new()
var allies: Array[Combatant] = []
var enemies: Array[Combatant] = []
var current_actor: Combatant
var selected_target: Combatant
var selected_skill: Dictionary = {}
var status_label: Label
var turn_label: Label
var target_list: ItemList
var skill_box: VBoxContainer
var party_list: ItemList
var log_box: RichTextLabel

func _ready() -> void:
	party.initialize_from_recruited(["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"])
	allies = CombatPartyBuilder.build_active_party(party)
	var boss := Combatant.new("yellow_wind", "黄风妖王", 720, 34, 22, 24, 6, {"fire": true, "wind": true}, "front")
	enemies = [boss]
	engine.combat_log.connect(_on_combat_log)
	engine.combat_finished.connect(_on_combat_finished)
	engine.setup(allies, enemies)
	current_actor = engine.advance_turn()
	_build_ui()
	_refresh()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("0d0d12")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)
	turn_label = Label.new()
	turn_label.add_theme_font_size_override("font_size", 24)
	root.add_child(turn_label)
	status_label = Label.new()
	root.add_child(status_label)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	root.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(300, 0)
	body.add_child(left)
	var allies_title := Label.new()
	allies_title.text = "队伍"
	allies_title.add_theme_font_size_override("font_size", 18)
	left.add_child(allies_title)
	party_list = ItemList.new()
	party_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(party_list)
	var middle := VBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(middle)
	var target_title := Label.new()
	target_title.text = "目标"
	target_title.add_theme_font_size_override("font_size", 18)
	middle.add_child(target_title)
	target_list = ItemList.new()
	target_list.custom_minimum_size = Vector2(0, 110)
	target_list.item_selected.connect(_on_target_selected)
	middle.add_child(target_list)
	var action_title := Label.new()
	action_title.text = "技能"
	action_title.add_theme_font_size_override("font_size", 18)
	middle.add_child(action_title)
	skill_box = VBoxContainer.new()
	skill_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_child(skill_box)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(360, 0)
	body.add_child(right)
	var log_title := Label.new()
	log_title.text = "战斗记录"
	log_title.add_theme_font_size_override("font_size", 18)
	right.add_child(log_title)
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.fit_content = false
	log_box.scroll_following = true
	log_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(log_box)
	var bottom := HBoxContainer.new()
	root.add_child(bottom)
	var boost := Button.new()
	boost.text = "Boost ×"
	boost.pressed.connect(_boost_selected)
	bottom.add_child(boost)
	var end := Button.new()
	end.text = "结束回合"
	end.pressed.connect(_end_turn)
	bottom.add_child(end)
	var exit := Button.new()
	exit.text = "返回"
	exit.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/journey.tscn"))
	bottom.add_child(exit)

func _refresh() -> void:
	if current_actor == null:
		return
	turn_label.text = "行动：%s · Turn %d" % [_name(current_actor), engine.turn_number]
	status_label.text = "HP %d/%d · BP %d · 护盾 %d/%d · Break=%s · %s排" % [current_actor.hp, current_actor.max_hp, current_actor.bp, current_actor.shield, current_actor.max_shield, str(current_actor.is_broken()), "前" if current_actor.row == "front" else "后"]
	party_list.clear()
	for ally in allies:
		party_list.add_item("%s  HP %d/%d  BP %d" % [_name(ally), ally.hp, ally.max_hp, ally.bp])
	target_list.clear()
	for enemy in enemies:
		if enemy.is_alive():
			target_list.add_item("%s  HP %d/%d  Shield %d/%d  Break=%s" % [_name(enemy), enemy.hp, enemy.max_hp, enemy.shield, enemy.max_shield, str(enemy.is_broken())])
			if selected_target == null or not selected_target.is_alive():
				selected_target = enemy
	_clear_skills()
	if current_actor.id in ["tangseng", "wukong", "bajie", "wujing", "longma"]:
		for skill in SkillCatalog.get_character_skills(current_actor.id.to_upper()):
			_add_skill_button(skill)

func _add_skill_button(skill: Dictionary) -> void:
	var button := Button.new()
	var cost := int(skill.get("bp_cost", 0))
	button.text = "%s  BP %d · %s" % [str(skill.get("name", "Skill")), cost, str(skill.get("kind", "damage"))]
	button.disabled = current_actor.bp < cost
	button.pressed.connect(func(): _use_skill(skill, false))
	skill_box.add_child(button)

func _clear_skills() -> void:
	for child in skill_box.get_children():
		child.queue_free()

func _use_skill(skill: Dictionary, boosted: bool) -> void:
	if current_actor == null or not current_actor.is_alive():
		return
	if selected_target == null or not selected_target.is_alive():
		return
	var result := SkillRuntime.perform(engine, current_actor, selected_target, skill, boosted)
	if not result.get("ok", false):
		status_label.text = "技能失败：%s" % result.get("reason", "unknown")
		return
	_end_turn()

func _boost_selected() -> void:
	if selected_skill.is_empty():
		var skills := SkillCatalog.get_character_skills(current_actor.id.to_upper())
		if not skills.is_empty():
			selected_skill = skills[0]
	if not selected_skill.is_empty():
		_use_skill(selected_skill, true)

func _on_target_selected(index: int) -> void:
	var alive: Array[Combatant] = []
	for enemy in enemies:
		if enemy.is_alive():
			alive.append(enemy)
	if index >= 0 and index < alive.size():
		selected_target = alive[index]

func _end_turn() -> void:
	if enemies.all(func(unit): return not unit.is_alive()):
		_refresh()
		return
	current_actor = engine.advance_turn()
	while current_actor != null and current_actor in enemies:
		_enemy_turn(current_actor)
		if enemies.all(func(unit): return not unit.is_alive()):
			break
		current_actor = engine.advance_turn()
	_refresh()

func _enemy_turn(enemy: Combatant) -> void:
	var living := allies.filter(func(unit): return unit.is_alive())
	if living.is_empty():
		return
	var target: Combatant = living[0]
	if "BAJIE" in party.front_row:
		for ally in living:
			if ally.id == "bajie":
				target = ally
				break
	var attack := CombatAction.new("boss_strike", "黄风爪", "wind", 30, 1, 0)
	engine.perform_action(enemy, target, attack)

func _on_combat_log(message: String) -> void:
	if log_box != null:
		log_box.append_text(message + "\n")

func _on_combat_finished(winner: String) -> void:
	if status_label != null:
		status_label.text = "战斗结束：%s" % ("胜利" if winner == "allies" else "失败")

func _name(unit: Combatant) -> String:
	return NAMES.get(unit.id, unit.display_name)
