class_name BattleUI
extends Control

const NAMES := {"tangseng":"唐三藏", "wukong":"孙悟空", "bajie":"猪八戒", "wujing":"沙悟净", "longma":"白龙马", "yellow_wind":"黄风妖王", "sand_guard":"沙甲妖兵", "wind_spirit":"风砂精", "cave_ghoul":"洞窟恶鬼", "stone_imp":"顽石小妖", "crab_guard":"蟹将", "shrimp_spear":"虾兵", "heavenly_soldier":"天兵", "heavenly_archer":"天将弓手"}
const MECHANIC_NAMES := {"tangseng":"慈悲", "wukong":"战意", "bajie":"怒气", "wujing":"潮势", "longma":"龙息"}
const CAVE_PROGRESS_PREFIX := "YELLOW_WIND_CAVE_ROOM_"

var engine := CombatEngine.new()
var party := PartyManager.new()
var boss_runtime := YellowWindBoss.new()
var encounter_manager := EncounterManager.new()
var allies: Array[Combatant] = []
var enemies: Array[Combatant] = []
var current_actor: Combatant
var selected_target: Combatant
var selected_ally: Combatant
var selected_skill: Dictionary = {}
var status_label: Label
var turn_label: Label
var target_list: ItemList
var skill_box: VBoxContainer
var item_box: VBoxContainer
var party_list: ItemList
var log_box: RichTextLabel
var encounter_type := "bounty"
var encounter_id := ""
var source_stage_id := ""
var source_chapter_id := ""
var source_route_id := ""
var bounty_manager := BountyManager.new()
var encounter_resolved := false
var item_catalog: Dictionary = {}
var battle_inventory := InventoryManager.new()
var loadout := LoadoutManager.new()

func _ready() -> void:
	var handoff := BountyEncounterState.get_active_record()
	encounter_type = str(handoff.get("encounter_type", "bounty"))
	encounter_id = str(handoff.get("encounter_id", handoff.get("bounty_id", "")))
	source_stage_id = str(handoff.get("source_stage_id", ""))
	source_chapter_id = str(handoff.get("source_chapter_id", ""))
	source_route_id = str(handoff.get("source_route_id", ""))
	_load_bounty_definitions()
	_load_item_catalog()
	var narrative := NarrativeManager.new()
	if narrative.load():
		battle_inventory.restore(narrative.state.get_inventory())
		loadout.restore_from_narrative(narrative)
	party.initialize_from_recruited(narrative.state.recruited_characters)
	allies = CombatPartyBuilder.build_active_party(party)
	_apply_loadout_modifiers()
	if encounter_type == "normal" or encounter_type == "origin" or encounter_type == "shared":
		enemies = encounter_manager.build_enemies(encounter_id)
	else:
		var boss := boss_runtime.create_boss()
		boss_runtime.begin_encounter(boss)
		enemies = [boss]
	engine.combat_log.connect(_on_combat_log)
	engine.combat_finished.connect(_on_combat_finished)
	engine.setup(allies, enemies)
	current_actor = engine.advance_turn()
	selected_ally = current_actor
	if not enemies.is_empty(): selected_target = enemies[0]
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
		ally.combat_modifiers = effects.duplicate(true)
		if effects.has("defense_multiplier"): ally.defense = maxi(int(round(ally.defense * float(effects["defense_multiplier"]))), 1)
		if effects.has("damage_multiplier"): ally.attack = maxi(int(round(ally.attack * float(effects["damage_multiplier"]))), 1)
		if effects.has("speed_modifier"):
			ally.speed = maxi(int(round(ally.speed * float(effects["speed_modifier"]))), 1)
			ally.base_speed = ally.speed

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new(); bg.color = Color("0d0d12"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var margin := MarginContainer.new(); margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); margin.add_theme_constant_override("margin_left",36); margin.add_theme_constant_override("margin_right",36); margin.add_theme_constant_override("margin_top",28); margin.add_theme_constant_override("margin_bottom",28); add_child(margin)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation",10); margin.add_child(root)
	turn_label = Label.new(); turn_label.add_theme_font_size_override("font_size",24); root.add_child(turn_label)
	status_label = Label.new(); root.add_child(status_label)
	var body := HBoxContainer.new(); body.size_flags_vertical = Control.SIZE_EXPAND_FILL; body.add_theme_constant_override("separation",14); root.add_child(body)
	var left := VBoxContainer.new(); left.custom_minimum_size = Vector2(340,0); body.add_child(left)
	var allies_title := Label.new(); allies_title.text = "队伍（点击队友作为道具目标）"; allies_title.add_theme_font_size_override("font_size",18); left.add_child(allies_title)
	party_list = ItemList.new(); party_list.size_flags_vertical = Control.SIZE_EXPAND_FILL; party_list.item_selected.connect(_on_ally_selected); left.add_child(party_list)
	var middle := VBoxContainer.new(); middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL; body.add_child(middle)
	var target_title := Label.new(); target_title.text = "目标"; target_title.add_theme_font_size_override("font_size",18); middle.add_child(target_title)
	target_list = ItemList.new(); target_list.custom_minimum_size = Vector2(0,110); target_list.item_selected.connect(_on_target_selected); middle.add_child(target_list)
	var action_title := Label.new(); action_title.text = "技能"; action_title.add_theme_font_size_override("font_size",18); middle.add_child(action_title)
	skill_box = VBoxContainer.new(); skill_box.custom_minimum_size = Vector2(0,170); middle.add_child(skill_box)
	var item_title := Label.new(); item_title.text = "战斗道具"; middle.add_child(item_title)
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
	var encounter_title := "普通遭遇：%s" % encounter_id
	if encounter_type == "origin": encounter_title = "个人战斗：%s" % encounter_id
	elif encounter_type == "shared": encounter_title = "共享主线：%s" % encounter_id
	elif encounter_type == "bounty":
		var definition := bounty_manager.get_definition(encounter_id)
		if not definition.is_empty(): encounter_title = "悬赏：%s · 推荐Lv.%d" % [str(definition.get("name", encounter_id)), int(definition.get("recommended_level", 0))]
	turn_label.text = "行动：%s · Turn %d · %s" % [_name(current_actor), engine.turn_number, encounter_title]
	status_label.text = "HP %d/%d · BP %d · %s %d/%d · 护盾 %d/%d · %s · %s排 · 道具 %d · 道具目标：%s" % [current_actor.hp,current_actor.max_hp,current_actor.bp,MECHANIC_NAMES.get(current_actor.id,"专属资源"),current_actor.mechanic_resource,current_actor.mechanic_max,current_actor.shield,current_actor.max_shield,current_actor.get_status_summary(),"前" if current_actor.row == "front" else "后",battle_inventory.items.size(),_name(selected_ally) if selected_ally != null else _name(current_actor)]
	party_list.clear()
	for ally in allies:
		var selected_mark := "◆ " if ally == selected_ally else ""
		party_list.add_item("%s%s  HP %d/%d  ATK %d DEF %d SPD %d  BP %d · %s %d/%d · %s排\n%s" % [selected_mark,_name(ally),ally.hp,ally.max_hp,ally.attack,ally.defense,ally.speed,ally.bp,MECHANIC_NAMES.get(ally.id,"资源"),ally.mechanic_resource,ally.mechanic_max,"前" if ally.row == "front" else "后",ally.get_status_summary()])
	target_list.clear()
	for enemy in enemies:
		if enemy.is_alive(): target_list.add_item("%s  HP %d/%d  Shield %d/%d\n%s" % [_name(enemy),enemy.hp,enemy.max_hp,enemy.shield,enemy.max_shield,enemy.get_status_summary()])
	_clear_skills(); _clear_items()
	if current_actor in allies:
		for skill in SkillCatalog.get_character_skills(current_actor.id.to_upper()): _add_skill_button(skill)
	_add_item_buttons()

func _add_skill_button(skill: Dictionary) -> void:
	var button := Button.new(); var cost := int(skill.get("bp_cost",0)); var mechanic_cost := int(skill.get("mechanic_cost",0)); var text := "%s  BP %d · %s" % [str(skill.get("name","Skill")),cost,str(skill.get("kind","damage"))]
	if mechanic_cost > 0: text += " · 专属资源 %d" % mechanic_cost
	if bool(skill.get("scale_with_mechanic", false)): text += " · 当前资源强化"
	if bool(skill.get("consume_mechanic_if_available", false)): text += " · 可消耗资源强化"
	button.text = text; button.disabled = current_actor.bp < cost or current_actor.mechanic_resource < mechanic_cost; button.pressed.connect(func(): _use_skill(skill,false)); skill_box.add_child(button)

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
	selected_skill = skill
	var result := SkillRuntime.perform(engine,current_actor,selected_target,skill,boosted)
	if not result.get("ok",false): status_label.text = "技能失败：%s" % result.get("reason","unknown"); return
	if result.has("form_name"): _on_combat_log("白龙马变身：%s · 持续 %d 回合" % [str(result.get("form_name","")),int(result.get("form_duration",0))])
	if result.get("mechanic_spent_extra",0) > 0: _on_combat_log("%s 消耗 %d 点%s强化效果。" % [_name(current_actor),int(result.get("mechanic_spent_extra",0)),MECHANIC_NAMES.get(current_actor.id,"专属资源")])
	if encounter_type == "bounty": boss_runtime.after_action(_boss())
	_end_turn()

func _use_item(item_id: String) -> void:
	if current_actor == null or not current_actor.is_alive() or not battle_inventory.has_item(item_id): return
	var item:Dictionary = item_catalog.get(item_id, {}); var item_type := str(item.get("type","")); var amount := int(item.get("amount",0)); var target:Combatant = selected_ally if selected_ally != null and selected_ally.is_alive() else current_actor
	if item_type == "HEAL":
		var living := allies.filter(func(unit): return unit.is_alive()); if living.is_empty(): return
		if not target in living: target = living[0]
		var healed := target.heal(amount); if healed <= 0: status_label.text = "%s 已满血。" % _name(target); return
	elif item_type == "BP": target.bp = mini(target.bp + amount,5)
	elif item_type == "BARRIER": target.gain_barrier(amount)
	else: status_label.text = "这个物品目前只能用于出战前准备。"; return
	battle_inventory.remove_item(item_id,1); _save_battle_inventory(); _on_combat_log("使用道具：%s → %s" % [str(item.get("name",item_id)),_name(target)]); _end_turn()

func _save_battle_inventory() -> void:
	var narrative := NarrativeManager.new(); if narrative.load(): narrative.state.set_inventory(battle_inventory.to_dict()); narrative.save()

func _boost_selected() -> void:
	if current_actor == null or selected_target == null or not selected_target.is_alive(): return
	if selected_skill.is_empty(): status_label.text = "先选择一个技能再使用 Boost。"; return
	_use_skill(selected_skill,true)

func _on_ally_selected(index: int) -> void:
	var living:Array[Combatant] = []
	for ally in allies:
		if ally.is_alive(): living.append(ally)
	if index >= 0 and index < living.size(): selected_ally = living[index]; _refresh()

func _on_target_selected(index: int) -> void:
	var alive:Array[Combatant] = []; for enemy in enemies: if enemy.is_alive(): alive.append(enemy)
	if index >= 0 and index < alive.size(): selected_target = alive[index]

func _end_turn() -> void:
	if enemies.all(func(unit): return not unit.is_alive()): _refresh(); return
	current_actor = engine.advance_turn()
	if current_actor != null and current_actor.is_alive() and current_actor in allies: selected_ally = current_actor
	while current_actor != null and current_actor in enemies:
		_enemy_turn(current_actor)
		if enemies.all(func(unit): return not unit.is_alive()): break
		current_actor = engine.advance_turn()
	if current_actor != null and current_actor.is_alive() and current_actor in allies: selected_ally = current_actor
	_refresh()

func _enemy_turn(enemy: Combatant) -> void:
	var living := allies.filter(func(unit): return unit.is_alive())
	if living.is_empty(): return
	var attack: CombatAction
	if encounter_type == "bounty":
		boss_runtime.on_turn_start(enemy)
		attack = boss_runtime.choose_action(enemy,allies)
	else:
		attack = encounter_manager.choose_ai_action(enemy,allies,engine.turn_number)
	var target: Combatant
	if encounter_type == "bounty":
		var taunted := living.filter(func(unit): return unit.aggro_turns > 0)
		target = taunted[0] if not taunted.is_empty() else living[0]
	else:
		target = encounter_manager.choose_ai_target(enemy,allies,attack)
	if target == null: return
	var result := engine.perform_action(enemy,target,attack)
	if encounter_type == "bounty": boss_runtime.apply_action_effects(attack.id,enemy)
	if result.get("ok",false): _on_combat_log("%s：%s → %s" % [_name(enemy),attack.display_name,_name(target)])

func _on_combat_log(message:String) -> void:
	if log_box != null: log_box.append_text(message + "\n")

func _on_combat_finished(winner:String) -> void:
	if encounter_resolved: return
	var narrative := NarrativeManager.new()
	if winner != "allies":
		status_label.text = "战斗失败。可以返回重新准备。"
		return
	if not narrative.load():
		status_label.text = "战斗胜利，但存档读取失败。"
		return
	if encounter_type == "normal" or encounter_type == "origin" or encounter_type == "shared":
		var definition := encounter_manager.get_definition(encounter_id)
		if definition.is_empty():
			status_label.text = "战斗胜利，但找不到遭遇定义。"
			return
		var applied := BattleRewardService.apply_victory(narrative, encounter_id, str(definition.get("name", encounter_id)), definition.get("rewards", []), definition.get("world_effects", []))
		if applied.is_empty():
			status_label.text = "战斗胜利，但奖励写入失败。"
			return
		battle_inventory.restore(applied.get("inventory", {}))
		if encounter_type == "normal" and not source_stage_id.is_empty(): narrative.state.add_world_rumor(CAVE_PROGRESS_PREFIX + source_stage_id)
		if encounter_type == "origin":
			if source_chapter_id.is_empty() or source_route_id.is_empty():
				status_label.text = "个人战斗胜利，但章节来源信息缺失。"
				return
			var origin := OriginRouteManager.new()
			var chapter := origin.get_current_chapter(narrative, str(narrative.state.starting_character))
			if str(chapter.get("id", "")) != source_chapter_id:
				status_label.text = "个人战斗胜利，但当前章节已发生变化。"
				return
			origin.complete_current(narrative, str(narrative.state.starting_character))
		elif encounter_type == "shared":
			if source_chapter_id.is_empty() or source_route_id != "SHARED_JOURNEY":
				status_label.text = "共享战斗胜利，但章节来源信息缺失。"
				return
			var shared_chapter := SharedJourneyManager.get_chapter(source_chapter_id)
			if shared_chapter.is_empty() or not SharedJourneyManager.can_enter(source_chapter_id, narrative.state):
				status_label.text = "共享战斗胜利，但当前章节状态已经变化。"
				return
			if not SharedJourneyManager.complete(source_chapter_id, narrative):
				status_label.text = "共享战斗胜利，但主线推进失败。"
				return
		narrative.save()
		BountyEncounterState.clear()
		encounter_resolved = true
		if encounter_type == "origin": status_label.text = "个人章节完成：%s · 获得 %s" % [str(definition.get("name", encounter_id)),_format_rewards(applied.get("granted", []))]
		elif encounter_type == "shared": status_label.text = "共享章节完成：%s · 获得 %s" % [str(definition.get("name", encounter_id)),_format_rewards(applied.get("granted", []))]
		else: status_label.text = "遭遇胜利：%s · 获得 %s" % [str(definition.get("name", encounter_id)),_format_rewards(applied.get("granted", []))]
	else:
		narrative.state.set_inventory(battle_inventory.to_dict())
		var applied := BountyRewardService.resolve_defeat(narrative,bounty_manager,encounter_id)
		if applied.is_empty():
			status_label.text = "战斗胜利，但悬赏状态写入失败。"
			return
		BountyEncounterState.clear()
		if not source_stage_id.is_empty():
			var ridge := YellowWindRidgeManager.new()
			ridge.complete_stage(narrative, source_stage_id)
		narrative.save()
		encounter_resolved = true
		status_label.text = "悬赏完成：%s · 奖励 %s" % [str(applied.get("target_name",encounter_id)),_format_rewards(applied.get("applied",{}).get("granted",[]))]

func _format_rewards(rewards:Array) -> String:
	if rewards.is_empty(): return "无"
	var parts:Array[String] = []
	for reward in rewards: parts.append("%s×%d" % [str(reward.get("id","")),int(reward.get("amount",0))])
	return "、".join(parts)

func _return_from_battle() -> void:
	if not encounter_resolved: BountyEncounterState.clear()
	if encounter_type == "origin" or encounter_type == "shared": get_tree().change_scene_to_file("res://ui/journey.tscn")
	elif encounter_type == "normal" and not source_stage_id.is_empty(): get_tree().change_scene_to_file("res://ui/yellow_wind_cave.tscn")
	elif encounter_type == "bounty" and not source_stage_id.is_empty() and encounter_resolved: get_tree().change_scene_to_file("res://ui/yellow_wind_cave.tscn")
	else: get_tree().change_scene_to_file("res://ui/world_map.tscn")

func _boss() -> Combatant: return enemies[0] if not enemies.is_empty() else null
func _name(unit:Combatant) -> String: return NAMES.get(unit.id,unit.display_name)
