extends RefCounted

## Regression tests for the optional bounty loop.
## Intended to be run by the project's test harness once the Godot test runner is wired.

func run() -> Dictionary:
	var manager := BountyManager.new()
	manager.load_definitions({
		"bounties": [
			{
				"id": "B1",
				"retreat_memory": "THREAT_RECORDED",
				"rewards": ["R1"],
				"world_effects_on_defeat": ["E1"],
				"memory_hooks": ["WUKONG"]
			}
		]
	})

	var results := {}
	results["loaded"] = manager.has_bounty("B1")
	results["starts_unknown"] = manager.get_status("B1") == BountyManager.STATUS_UNKNOWN
	results["discover"] = manager.discover("B1", "RUMOR_FOUND")
	results["stores_evidence"] = "RUMOR_FOUND" in manager.get_intelligence("B1")
	results["retreat"] = manager.mark_retreat("B1")
	results["stores_retreat_info"] = "THREAT_RECORDED" in manager.get_intelligence("B1")

	var outcome := manager.defeat("B1")
	results["defeat"] = manager.get_status("B1") == BountyManager.STATUS_DEFEATED
	results["rewards"] = outcome.get("rewards", []) == ["R1"]
	results["world_effects"] = outcome.get("world_effects", []) == ["E1"]
	results["memory_hooks"] = outcome.get("memory_hooks", []) == ["WUKONG"]
	results["second_defeat_rejected"] = manager.defeat("B1").is_empty()
	return results
