extends RefCounted

static func can_present(event_value, state_owner, scope):
	return event_value != null and state_owner != null and scope != ""
