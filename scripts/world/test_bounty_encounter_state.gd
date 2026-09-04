extends RefCounted

## Static checks for the world-map -> battle scene handoff.
## The handoff itself is intentionally transient and separate from the narrative save schema.

static func run() -> void:
	BountyEncounterState.clear()
	assert(BountyEncounterState.get_active() == "")
	assert(BountyEncounterState.start("BOUNTY_YELLOW_FANG"))
	assert(BountyEncounterState.get_active() == "BOUNTY_YELLOW_FANG")
	BountyEncounterState.clear()
	assert(BountyEncounterState.get_active() == "")
