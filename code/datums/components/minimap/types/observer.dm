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
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	if(!length(pixel_coords))
		return

	var/list/view = view_to_pixels(clicker.client.view_size.getView())
	var/x_divide = text2num(view[1]) / world.maxx
	var/y_divide = text2num(view[2]) / world.maxy
	var/the_x = clamp((text2num(pixel_coords[1]) / x_divide), 1, world.maxx)
	var/the_y = clamp((text2num(pixel_coords[2]) / y_divide), 1, world.maxy)

	var/turf/location = locate(the_x, the_y, clicker.z)
	if(!location)
		to_chat(clicker, span_warning("Invalid location!"))
		return

	clicker.abstract_move(location)
