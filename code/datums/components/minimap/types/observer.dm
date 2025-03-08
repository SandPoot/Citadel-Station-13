/datum/component/minimap/observer

/datum/component/minimap/observer/Initialize()
	if(!isobserver(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(click_on))

/datum/component/minimap/observer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLICKON)
	return ..()

/datum/component/minimap/observer/proc/click_on(mob/clicker, atom/clicked, params)
	if(!visible)
		return

	var/list/modifiers = params2list(params)
	if(!length(modifiers))
		return

	var/turf/location = screenloc2turf_minimap(modifiers[SCREEN_LOC], clicker.z, clicker.client.view_size.getView())
	if(!location)
		to_chat(clicker, span_warning("Invalid location!"))
		return

	clicker.abstract_move(location)
	return COMSIG_MOB_CANCEL_CLICKON
