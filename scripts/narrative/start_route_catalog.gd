class_name StartRouteCatalog
extends RefCounted

## Static catalog for the five selectable starting-character campaigns.
## UI can consume this without embedding narrative rules in scenes.

const ROUTES := [
	{
		"id": "WUKONG",
		"name": "孙悟空",
		"subtitle": "齐天大圣",
		"theme": "自由与反抗",
		"origin_route_id": "WUKONG_ORIGIN",
		"origin_end": "WUK-15",
		"handoff_milestone": "WUKONG_RECRUITED",
		"handoff_shared_chapter": "SHARED-01-FIVE-ELEMENTS",
	},
	{
		"id": "TANG",
		"name": "唐僧",
		"subtitle": "取经人",
		"theme": "信仰与现实",
		"origin_route_id": "TANG_ORIGIN",
		"origin_end": "TANG-08",
		"handoff_milestone": "WUKONG_RECRUITED",
		"handoff_shared_chapter": "SHARED-01-FIVE-ELEMENTS",
	},
	{
		"id": "BAJIE",
		"name": "猪八戒",
		"subtitle": "天蓬元帅",
		"theme": "欲望与责任",
		"origin_route_id": "BAJIE_ORIGIN",
		"origin_end": "BAJIE-09",
		"handoff_milestone": "ZHU_BAJIE_RECRUITED",
		"handoff_shared_chapter": "SHARED-05-GAOJIAZHUANG",
	},
	{
		"id": "WUJING",
		"name": "沙悟净",
		"subtitle": "卷帘大将",
		"theme": "罪责与救赎",
		"origin_route_id": "WUJING_ORIGIN",
		"origin_end": "WUJING-08",
		"handoff_milestone": "SHA_WUJING_RECRUITED",
		"handoff_shared_chapter": "SHARED-07-FLOWING-SANDS",
	},
	{
		"id": "LONGMA",
		"name": "白龙马",
		"subtitle": "西海龙子",
		"theme": "身份与使命",
		"origin_route_id": "LONGMA_ORIGIN",
		"origin_end": "LONGMA-06",
		"handoff_milestone": "BAI_LONGMA_RECRUITED",
		"handoff_shared_chapter": "SHARED-03-EAGLE-SORROW",
	},
]

static func all_routes() -> Array:
	return ROUTES.duplicate(true)

static func get_route(character_id: String) -> Dictionary:
	for route in ROUTES:
		if str(route.get("id", "")) == character_id:
			return route.duplicate(true)
	return {}

static func is_valid_start(character_id: String) -> bool:
	return not get_route(character_id).is_empty()
