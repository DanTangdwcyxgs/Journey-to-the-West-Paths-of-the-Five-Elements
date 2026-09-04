class_name BattleUI
extends Control

const NAMES := {"tangseng":"唐三藏", "wukong":"孙悟空", "bajie":"猪八戒", "wujing":"沙悟净", "longma":"白龙马", "yellow_wind":"黄风妖王"}
const MECHANIC_NAMES := {"tangseng":"慈悲", "wukong":"战意", "bajie":"怒气", "wujing":"潮势", "longma":"龙息"}

var engine := CombatEngine.new()
var party := PartyManager.new()
var boss_runtime := YellowWindBoss.new()
var allies: Array[Combatant] = []
var enemies: Array[Combatant] = []
var current_actor: Combatant
var selected_target: Combatant
var selected_skill: Dictionary = {}
var status_label: Label
var turn_label: Label
var target_list: ItemList
var skill_box: VBoxContainer
var item_box: VBoxContainer
var party_list: ItemList
var log_box: RichTextLabel
var bounty_id := ""
var bounty_manager := BountyManager.new()
var bounty_resolved := false
var item_catalog: Dictionary = {}
var battle_inventory := InventoryManager.new()
var loadout := LoadoutManager.new()

func _ready() -> void:
	bounty_id = BountyEncounterState.get_active()
	_load_bounty_definitions()
	_load_item_catalog()
	var narrative := NarrativeManager.new()
	if narrative.load():
		battle_inventory.restore(narrative.state.get_inventory())
		loadout.restore_from_narrative(narrative)
	party.initialize_from_recruited(["TANG", "WUKONG", "BAJIE", "WUJING", "LONGMA"])
	allies = CombatPartyBuilder.build_active_party(party)
	_apply_loadout_modifiers()
	var boss := boss_runtime.create_boss()
	boss_runtime.begin_encounter(boss)
	enemies = [boss]
	engine.combat_log.connect(_on_combat_log)
	engine.combat_finished.connect(_on_combat_finished)
	engine.setup(allies, enemies)
	current_actor = engine.advance_turn()
	_build_ui()
	_refresh()

func _load_bounty_definitions() -> void:
	var file := FileAccess.open("res://data/world/bounties.json", FileAccess.READ)
	if file == null: return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary: bounty_manager.load_definitions(parsed)

func _load_item_catalog() -> void:
	var file := FileAccess.open("res://data/items/shop_items.json", FileAccess.READ)
	if file == null: return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary: return
	for item in parsed.get("items", []):
		if item is Dictionary:
			var id := str(item.get("id", ""))
			if id != "": item_catalog[id] = item.duplicate(true)

func _apply_loadout_modifiers() -> void:
	for ally in allies:
		var effects := loadout.get_effects(ally.id.to_upper())
		if effects.has("defense_multiplier"): ally.defense = maxi(int(round(ally.defense * float(effects["defense_multiplier"]))), 1)
		if effects.has("damage_multiplier"): ally.attack = maxi(int(round(ally.attack * float(effects["damage_multiplier"]))), 1)
		if effects.has("speed_modifier"): ally.speed = maxi(int(round(ally.speed * float(effects["speed_modifier"]))), 1); ally.base_speed = ally.speed

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new(); bg.color = Color("0d0d12"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); margin.add_theme_constant_override("margin_left",36); margin.add_theme_constant_override("margin_right",36); margin.add_theme_constant_override("margin_top",28); margin.add_theme_constant_override("margin_bottom",28); add_child(margin)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation",10); margin.add_child(root)
	turn_label = Label.new(); turn_label.add_theme_font_size_override("font_size",24); root.add_child(turn_label)
	status_label = Label.new(); root.add_child(status_label)
	var body := HBoxContainer.new(); body.size_flags_vertical = Control.SIZE_EXPAND_FILL; body.add_theme_constant_override("separation",14); root.add_child(body)
	var left := VBoxContainer.new(); left.custom_minimum_size = Vector2(340,0); body.add_child(left)
	var allies_title := Label.new(); allies_title.text = "队伍"; allies_title.add_theme_font_size_override("font_size",18); left.add_child(allies_title)
	party_list = ItemList.new(); party_list.size_flags_vertical = Control.SIZE_EXPAND_FILL; left.add_child(party_list)
	var middle := VBoxContainer.new(); middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL; body.add_child(middle)
	var target_title := Label.new(); target_title.text = "目标"; target_title.add_theme_font_size_override("font_size",18); middle.add_child(target_title)
	target_list = ItemList.new(); target_list.custom_minimum_size = Vector2(0,110); target_list.item_selected.connect(_on_target_selected); middle.add_child(target_list)
	var action_title := Label.new(); action_title.text = "技能"; action_title.add_theme_font_size_override("font_size",18); middle.add_child(action_title)
	skill_box = VBoxContainer.new(); skill_box.custom_minimum_size = Vector2(0,170); middle.add_child(skill_box)
	var item_title := Label.new(); item_title.text = "战斗道具"; item_title.add_theme_font_size_override("font_size",18); middle.add_child(item_title)
	item_box = VBoxContainer.new(); middle.add_child(item_box)
	var right := VBoxContainer.new(); right.custom_minimum_size = Vector2(360,0); body.add_child(right)
	var log_title := Label.new(); log_title.text = "战斗记录"; log_title.add_theme_font_size_override("font_size",18); right.add_child(log_title)
	log_box = RichTextLabel.new(); log_box.bbcode_enabled = true; log_box.fit_content = false; log_box.scroll_following = true; log_box.size_flags_vertical = Control.SIZE_EXPAND_FILL; right.add_child(log_box)
	var bottom := HBoxContainer.new(); root.add_child(bottom)
	var boost := Button.new(); boost.text = "Boost ×"; boost.pressed.connect(_boost_selected); bottom.add_child(boost)
	var end := Button.new(); end.text = "结束回合"; end.pressed.connect(_end_turn); bottom.add_child(end)
	var exit := Button.new(); exit.text = "返回"; exit.pressed.connect(_return_from_battle); bottom.add_child(exit)

func _refresh() -> void:
	if current_actor == null: return
	var boss := _boss(); var encounter_title := "黄风阶段 %d" % boss_runtime.phase
	if bounty_id != "":
		var definition := bounty_manager.get_definition(bounty_id); encounter_title = "悬赏：%s · 推荐Lv.%d" % [str(definition.get("name", bounty_id)), int(definition.get("recommended_level", 0))]
	turn_label.text = "行动：%s · Turn %d · %s" % [_name(current_actor), engine.turn_number, encounter_title]
	status_label.text = "HP %d/%d · BP %d · %s %d/%d · 护盾 %d/%d · Break=%s · %s排 · 道具 %d" % [current_actor.hp,current_actor.max_hp,current_actor.bp,MECHANIC_NAMES.get(current_actor.id,"专属资源"),current_actor.mechanic_resource,current_actor.mechanic_max,current_actor.shield,current_actor.max_shield,str(current_actor.is_broken()),"前" if current_actor.row == "front" else "后",battle_inventory.items.size()]
	party_list.clear()
	for ally in allies: party_list.add_item("%s  HP %d/%d  ATK %d DEF %d SPD %d  BP %d · %s %d/%d · %s排" % [_name(ally),ally.hp,ally.max_hp,ally.attack,ally.defense,ally.speed,ally.bp,MECHANIC_NAMES.get(ally.id,"资源"),ally.mechanic_resource,ally.mechanic_max,"前" if ally.row == "front" else "后"])
	target_list.clear()
	for enemy in enemies:
		if enemy.is_alive():
			target_list.add_item("%s  HP %d/%d  Shield %d/%d  Break=%s" % [_name(enemy),enemy.hp,enemy.max_hp,enemy.shield,enemy.max_shield,str(enemy.is_broken())]); if selected_target == null or not selected_target.is_alive(): selected_target = enemy
	_clear_skills(); _clear_items()
	if current_actor.id in ["tangseng","wukong","bajie","wujing","longma"]:
		for skill in SkillCatalog.get_character_skills(current_actor.id.to_upper()): _add_skill_button(skill)
	_add_item_buttons()

func _add_skill_button(skill: Dictionary) -> void:
	var button := Button.new(); var cost := int(skill.get("bp_cost",0)); var mechanic_cost := int(skill.get("mechanic_cost",0)); button.text = "%s  BP %d · %s%s" % [str(skill.get("name","Skill")),cost,str(skill.get("kind","damage"))," · 专属资源 %d" % mechanic_cost if mechanic_cost > 0 else ""]; button.disabled = current_actor.bp < cost or current_actor.mechanic_resource < mechanic_cost; button.pressed.connect(func(): _use_skill(skill,false)); skill_box.add_child(button)

func _add_item_buttons() -> void:
	for item_id in battle_inventory.items.keys():
		var item := item_catalog.get(str(item_id), {}); if item.is_empty(): continue
		var button := Button.new(); button.text = "%s ×%d · %s" % [str(item.get("name",item_id)),int(battle_inventory.items.get(str(item_id),0)),str(item.get("description",""))]; button.disabled = int(battle_inventory.items.get(str(item_id),0)) <= 0; button.pressed.connect(_use_item.bind(str(item_id))); item_box.add_child(button)

func _clear_skills() -> void:
	for child in skill_box.get_children(): child.queue_free()

func _clear_items() -> void:
	for child in item_box.get_children(): child.queue_free()

func _use_skill(skill: Dictionary, boosted: bool) -> void:
	if current_actor == null or not current_actor.is_alive() or selected_target == null or not selected_target.is_alive(): return
	var result := SkillRuntime.perform(engine,current_actor,selected_target,skill,boosted)
	if not result.get("ok",false): status_label.text = "技能失败：%s" % result.get("reason","unknown"); return
	boss_runtime.after_action(_boss()); _end_turn()

func _use_item(item_id: String) -> void:
	if current_actor == null or not current_actor.is_alive() or not battle_inventory.has_item(item_id): return
	var item:Dictionary = item_catalog.get(item_id, {}); var item_type := str(item.get("type","")); var amount := int(item.get("amount",0)); var target := current_actor
	if item_type == "HEAL":
		var living := allies.filter(func(unit): return unit.is_alive()); if living.is_empty(): return
		target = living[0]; var healed := target.heal(amount); if healed <= 0: status_label.text = "%s 已满血。" % _name(target); return
	elif item_type == "BP": target.bp = mini(target.bp + amount,5)
	elif item_type == "BARRIER": target.gain_barrier(amount)
	else: status_label.text = "这个物品目前只能用于出战前准备。"; return
	battle_inventory.remove_item(item_id,1); _save_battle_inventory(); _on_combat_log("使用道具：%s → %s" % [str(item.get("name",item_id)),_name(target)]); _end_turn()

func _save_battle_inventory() -> void:
	var narrative := NarrativeManager.new(); if narrative.load(): narrative.state.set_inventory(battle_inventory.to_dict()); narrative.save()

func _boost_selected() -> void:
	if selected_skill.is_empty():
		var skills := SkillCatalog.get_character_skills(current_actor.id.to_upper()); if not skills.is_empty(): selected_skill = skills[0]
	if not selected_skill.is_empty(): _use_skill(selected_skill,true)

func _on_target_selected(index: int) -> void:
	var alive:Array[Combatant] = []; for enemy in enemies: if enemy.is_alive(): alive.append(enemy)
	if index >= 0 and index < alive.size(): selected_target = alive[index]

func _end_turn() -> void:
	if enemies.all(func(unit): return not unit.is_alive()): _refresh(); return
	current_actor = engine.advance_turn()
	while current_actor != null and current_actor in enemies:
		_enemy_turn(current_actor); if enemies.all(func(unit): return not unit.is_alive()): break
		current_actor = engine.advance_turn()
	_refresh()

func _enemy_turn(enemy: Combatant) -> void:
	boss_runtime.on_turn_start(enemy); var living := allies.filter(func(unit): return unit.is_alive()); if living.is_empty(): return
	var target:Combatant = living[0]; var taunted := allies.filter(func(unit): return unit.is_alive() and unit.aggro_turns > 0); if not taunted.is_empty(): target = taunted[0]
	var attack := boss_runtime.choose_action(enemy,allies); var result := engine.perform_action(enemy,target,attack); boss_runtime.apply_action_effects(attack.id,enemy); if result.get("ok",false): _on_combat_log("黄风妖王阶段%d：%s" % [boss_runtime.phase,attack.display_name])

func _on_combat_log(message:String) -> void:
	if log_box != null: log_box.append_text(message + "\n")

func _on_combat_finished(winner:String) -> void:
	if winner == "allies" and not bounty_id.is_empty() and not bounty_resolved:
		var narrative := NarrativeManager.new()
		if narrative.load():
			narrative.state.set_inventory(battle_inventory.to_dict()); var applied := BountyRewardService.resolve_defeat(narrative,bounty_manager,bounty_id); bounty_resolved = not applied.is_empty(); BountyEncounterState.clear()
			if bounty_resolved:
				status_label.text = "悬赏完成：%s · 奖励 %s" % [str(applied.get("target_name",bounty_id)),_format_rewards(applied.get("applied",{}).get("granted",[]))]
			else: status_label.text = "战斗胜利，但悬赏状态写入失败。"
	else: status_label.text = "战斗结束：%s" % ("胜利" if winner == "allies" else "失败")

func _format_rewards(rewards:Array) -> String:
	if rewards.is_empty(): return "无"
	var parts:Array[String] = []; for reward in rewards: parts.append("%s×%d" % [str(reward.get("id","")),int(reward.get("amount",0))]); return "、".join(parts)

func _return_from_battle() -> void:
	if not bounty_id.is_empty() and not bounty_resolved: BountyEncounterState.clear()
	get_tree().change_scene_to_file("res://ui/world_map.tscn")

func _boss() -> Combatant: return enemies[0] if not enemies.is_empty() else null
func _name(unit:Combatant) -> String: return NAMES.get(unit.id,unit.display_name)
