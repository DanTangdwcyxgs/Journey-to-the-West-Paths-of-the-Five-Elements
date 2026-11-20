class_name BattleTutorial
extends RefCounted

const ORIGIN_DATA_PATH := "res://data/narrative/origin_chapters.json"

const CHARACTER_NOTES := {
	"WUKONG": "孙悟空 · 战意：打出破防窗口，或使用七十二变·分身这类破防爆发招式，可以积累战意；分身招式会消耗战意。",
	"TANG": "唐三藏 · 慈悲：治疗可以积累慈悲；慈悲咒能消耗慈悲强化治疗，护心法则需要慈悲来强化护盾。",
	"BAJIE": "猪八戒 · 怒气：承受直接伤害会增加怒气；倒打一耙可以嘲讽敌人并积累怒气，大口吞食会消耗怒气强化攻防。",
	"WUJING": "沙悟净 · 潮势：使用流沙缚施加减速可以积累潮势；后续控制技能可以消耗潮势延长控制效果。",
	"LONGMA": "白龙马 · 龙息：对后排敌人造成伤害可以积累龙息；龙形变可切换战斗形态，改变攻防与速度表现。"
}

static func normalize_character_id(character_id: String) -> String:
	var normalized := character_id.strip_edges().to_upper()
	if normalized == "TANGSENG" or normalized == "TANG_SANZANG":
		return "TANG"
	if normalized == "SHA_WUJING":
		return "WUJING"
	if normalized == "BAI_LONGMA":
		return "LONGMA"
	return normalized

static func first_battle_for_route(route_id: String) -> Dictionary:
	if route_id.strip_edges().is_empty():
		return {}
	var file := FileAccess.open(ORIGIN_DATA_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return {}
	var routes: Variant = parsed.get("routes", {})
	if not routes is Dictionary:
		return {}
	for route_key in routes.keys():
		var route_value: Variant = routes[route_key]
		if not route_value is Dictionary:
			continue
		if str(route_value.get("route_id", "")) != route_id:
			continue
		var chapters: Variant = route_value.get("chapters", [])
		if not chapters is Array:
			return {}
		for chapter_value in chapters:
			if not chapter_value is Dictionary:
				continue
			var encounter_id := str(chapter_value.get("encounter_id", "")).strip_edges()
			if encounter_id.is_empty():
				continue
			return {
				"character_id": str(route_key),
				"route_id": route_id,
				"chapter_id": str(chapter_value.get("id", "")),
				"encounter_id": encounter_id
			}
	return {}

static func should_show_for(encounter_type: String, source_route_id: String, source_chapter_id: String) -> bool:
	if encounter_type != "origin" or source_chapter_id.strip_edges().is_empty():
		return false
	var first_battle := first_battle_for_route(source_route_id)
	return not first_battle.is_empty() and str(first_battle.get("chapter_id", "")) == source_chapter_id

static func guide_text_for_character(character_id: String) -> String:
	var normalized := normalize_character_id(character_id)
	var character_note := str(CHARACTER_NOTES.get(normalized, "角色专属资源会影响部分技能效果；留意技能说明与状态栏中的资源变化。"))
	return "《第一次战斗 · 快速上手》\n\n" + \
		"1. 选择目标：先点中间的“目标”列表，再选择技能。点击左侧队友，可以把他设为药品/道具目标。\n\n" + \
		"2. 弱点与破防：根据敌人的弱点选择对应属性。命中弱点会额外削减护盾；护盾归零后触发 Break，敌人会短暂无法行动，并承受更高伤害。\n\n" + \
		"3. BP / Boost：角色每次开始行动都会恢复 BP（最多 5 点）。先选技能，再按 Boost 强化这次技能；技能消耗的 BP 越高，Boost 的强化幅度越大。把高消耗技能留给关键回合。\n\n" + \
		"4. 道具与站位：需要治疗或支援时，先点左侧队友再使用道具。留意 HP、护盾和状态；前排更容易承受压力，后排受到的伤害较低。\n\n" + \
		"5. " + character_note + "\n\n" + \
		"不用急着记住所有规则。先观察敌人的护盾和队友状态，找到弱点，再决定什么时候 Boost。"
