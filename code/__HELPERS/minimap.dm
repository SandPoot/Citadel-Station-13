/// Converts a turf to a x,y coordinate pixel on the screen (does not support widescreen, will do letterboxing instead)
/proc/turf2screenloc_minimap(turf/turf)
	if(QDELETED(turf))
		return

	var/x = FLOOR(turf.x * ((MINIMAP_SIZE * world.icon_size) / world.maxx), 1)
	var/y = FLOOR(turf.y * ((MINIMAP_SIZE * world.icon_size) / world.maxy), 1)

	return "CENTER-7:[x],CENTER-7:[y]"

/// Converts a x,y coordinate pixel with provided z on the screen to a turf
/proc/screenloc2turf_minimap(screen_loc, z, view = MINIMAP_SIZE)
	if(!screen_loc)
		return

	if(!z)
		return

	var/list/view_list = getviewsize(view)
	var/adjust_for_irregular_size = (view_list[1] > MINIMAP_SIZE) ? (view_list[1] - MINIMAP_SIZE) : 0

	view_list[1] -= adjust_for_irregular_size
	view_list[1] = clamp(view_list[1], 1, MINIMAP_SIZE)

	view_list[1] *= world.icon_size
	view_list[2] *= world.icon_size

	var/list/pixel_coords = params2screenpixel(screen_loc)

	pixel_coords[1] -= adjust_for_irregular_size * world.icon_size

	var/x_divide = text2num(view_list[1]) / world.maxx
	var/y_divide = text2num(view_list[2]) / world.maxy
	var/the_x = clamp((text2num(pixel_coords[1]) / x_divide), 1, world.maxx)
	var/the_y = clamp((text2num(pixel_coords[2]) / y_divide), 1, world.maxy)

	var/turf/location = locate(the_x, the_y, z)
	if(!location)
		return
	return location
