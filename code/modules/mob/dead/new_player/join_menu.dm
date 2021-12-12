GLOBAL_DATUM_INIT(join_menu, /datum/join_menu, new)

/**
 * Global singleton for holding TGUI data for players joining.
 */
/datum/join_menu

/datum/join_menu/proc/queue_update()
	addtimer(CALLBACK(src, /datum/proc/update_static_data), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/join_menu/ui_static_data(mob/user)
	. = ..()

/datum/join_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
