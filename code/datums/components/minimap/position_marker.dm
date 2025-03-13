/atom/movable/screen/position_marker
	icon = 'icons/hud/minimap/markers.dmi'
	icon_state = "locator"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER + 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/position_marker/Initialize(mapload)
	. = ..()
	apply_offsets()

/// Overridable proc to set proper offsets to subtypes
/atom/movable/screen/position_marker/proc/apply_offsets()
	var/matrix/M = transform
	M.Translate(-4, -4)
	transform = M

/atom/movable/screen/position_marker/ai
	icon_state = "ai_eye"
