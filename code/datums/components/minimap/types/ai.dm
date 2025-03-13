/datum/component/minimap/ai
	var/mob/camera/aiEye/tracked_eye
	var/atom/movable/screen/position_marker/ai/eye_marker

/datum/component/minimap/ai/Initialize()
	if(!isAI(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	eye_marker = new()

	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(click_on))
	RegisterSignal(parent, COMSIG_AI_EYE_CREATED, PROC_REF(on_eye_creation))

	// We might have an eye already, so we must try to force it
	var/mob/living/silicon/ai/AI = parent
	if(AI.eyeobj)
		on_eye_creation(AI, AI.eyeobj)

/datum/component/minimap/ai/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLICKON)
	return ..()

/datum/component/minimap/ai/Destroy(force, silent)
	QDEL_NULL(eye_marker)
	return ..()

/datum/component/minimap/ai/proc/click_on(mob/living/silicon/ai/clicker, atom/clicked, params)
	if(!visible)
		return

	var/list/modifiers = params2list(params)
	if(!length(modifiers))
		return

	var/turf/location = screenloc2turf_minimap(modifiers[SCREEN_LOC], clicker.z, clicker.client?.view_size.getView())
	if(!location)
		to_chat(clicker, span_warning("Invalid location!"))
		return

	location.move_camera_by_click(clicker)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/component/minimap/ai/proc/on_eye_creation(mob/living/silicon/ai/AI, mob/camera/aiEye/eye)
	if(tracked_eye)
		detach_old_eye()

	tracked_eye = eye
	RegisterSignal(tracked_eye, COMSIG_MOVABLE_MOVED, PROC_REF(eye_moved))
	RegisterSignal(tracked_eye, COMSIG_PARENT_QDELETING, PROC_REF(detach_old_eye))

/datum/component/minimap/ai/proc/detach_old_eye()
	UnregisterSignal(tracked_eye, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	tracked_eye = null

/datum/component/minimap/ai/proc/eye_moved(mob/eye)
	if(!visible)
		return

	if(!map)
		return

	eye_marker.screen_loc = turf2screenloc_minimap(get_turf(eye))

/datum/component/minimap/ai/close_minimap(mob/from_whom)
	. = ..()
	if(from_whom)
		from_whom.client?.screen -= eye_marker

/datum/component/minimap/ai/update_view(mob/viewer)
	. = ..()
	if(!visible)
		return

	if(map.icon_state == "noise")
		viewer.client?.screen -= eye_marker
		return

	viewer.client?.screen += eye_marker
