/obj/effect/abstract/position_marker
	icon = 'icons/hud/minimap.dmi'
	icon_state = "locator"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER + 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/position_marker/Initialize(mapload)
	. = ..()
	var/matrix/M = transform
	M.Translate(-4, -4)
	transform = M
