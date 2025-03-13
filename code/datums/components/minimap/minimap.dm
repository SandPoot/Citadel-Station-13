#define MINIMAP_TYPE /atom/movable/screen/fullscreen/special/minimap

/datum/component/minimap
	var/visible = FALSE
	var/datum/action/minimap/open_minimap
	var/atom/movable/screen/fullscreen/special/minimap/map

	var/obj/effect/abstract/position_marker/marker

	var/mob/holder

/datum/component/minimap/Initialize()
	if(!ismob(parent) && !isitem(parent))
		return COMPONENT_INCOMPATIBLE

	marker = new()
	open_minimap = new(parent)

	if(ismob(parent))
		open_minimap.Grant(parent)
		RegisterSignal(open_minimap, COMSIG_ACTION_TRIGGER, PROC_REF(mob_requesting_map))
		RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGOUT, PROC_REF(on_client_disconnect))
		RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_view))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_position_marker))

	if(isitem(parent))
		RegisterSignal(open_minimap, COMSIG_ACTION_TRIGGER, PROC_REF(obj_requesting_map))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(obj_grabbed))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(obj_dropped))

/datum/component/minimap/UnregisterFromParent()
	if(isitem(parent))
		obj_dropped(parent, holder)

	UnregisterSignal(parent, list(COMSIG_MOB_CLIENT_LOGOUT, COMSIG_MOVABLE_Z_CHANGED, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(open_minimap)
		open_minimap.UnregisterSignal(parent, COMSIG_ACTION_TRIGGER)
		QDEL_NULL(open_minimap)

/datum/component/minimap/Destroy(force, silent)
	if(visible)
		if(isitem(parent))
			close_minimap(holder)
		else
			close_minimap(parent)

	QDEL_NULL(marker)

	return ..()

/datum/component/minimap/proc/mob_requesting_map(datum/action/pressed, mob/owner)
	if(visible)
		close_minimap(owner)
		return

	open_minimap(owner)

/datum/component/minimap/proc/on_client_disconnect(client/client)
	if(!visible)
		return
	close_minimap(parent)

/datum/component/minimap/proc/obj_grabbed(obj/item/item, mob/requester, slot)
	if(holder == requester)
		return
	holder = requester
	open_minimap.Grant(holder)
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_position_marker))
	RegisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_view))
	RegisterSignal(holder, COMSIG_MOB_CLIENT_LOGOUT, PROC_REF(obj_holder_disconnect))

/datum/component/minimap/proc/obj_dropped(obj/item/item, mob/dropper)
	if(!holder)
		return
	open_minimap.Remove(holder)
	close_minimap(holder)
	UnregisterSignal(holder, list(COMSIG_MOB_CLIENT_LOGOUT, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	holder = null

/datum/component/minimap/proc/obj_requesting_map(datum/action/pressed, obj/item/owner)
	if(!ismob(holder))
		return

	if(visible)
		close_minimap(holder)
		return

	open_minimap(holder)

/datum/component/minimap/proc/obj_holder_disconnect(client/client)
	if(!holder)
		return

	close_minimap(holder)

/datum/component/minimap/proc/open_minimap(mob/to_whom)
	visible = TRUE
	map = to_whom.overlay_fullscreen("[REF(src)]", MINIMAP_TYPE)
	update_view(to_whom)

/datum/component/minimap/proc/close_minimap(mob/from_whom)
	visible = FALSE
	if(from_whom)
		from_whom.clear_fullscreen("[REF(src)]", 0)
		from_whom.client?.screen -= marker
	map = null

/datum/component/minimap/proc/update_view(mob/viewer)
	if(!visible)
		return

	var/datum/minimap/correct_map
	for(var/datum/minimap/minimap as anything in SSminimaps.station_minimaps)
		if(minimap.z_level != viewer.z)
			continue
		correct_map = minimap
		break

	if(!correct_map)
		map.icon = 'icons/mob/screen_gen.dmi'
		map.icon_state = "noise"
		map.transform = null
		map.screen_loc = "WEST+1,SOUTH+1 to EAST-1,NORTH-1"
		viewer.client?.screen -= marker
		return
	map.icon = correct_map.map_full_image
	map.icon_state = null
	map.set_appearance()
	map.screen_loc = initial(map.screen_loc)

	viewer.client?.screen += marker
	update_position_marker(viewer)

/datum/component/minimap/proc/update_position_marker(mob/viewer)
	if(!visible)
		return

	if(!map)
		return

	if(holder)
		marker.screen_loc = turf2screenloc_minimap(get_turf(viewer))
		return
	marker.screen_loc = turf2screenloc_minimap(get_turf(viewer))
