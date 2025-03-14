/datum/minimap
	var/name = "minimap"
	var/z_level

	// The map icons
	var/icon/map_icon
	var/image/map_full_image


/datum/minimap/New(z, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy, name = "minimap")
	if(!z)
		CRASH("ERROR: new minimap requested without z level") //CRASH to halt the operation

	src.name = name
	z_level = z

	// do the generating
	map_icon = new('html/blank.png')
	var/icon/background_icon = new('icons/hud/minimap/background.dmi', "test_background")
	map_icon.Scale(x2 - x1 + 1, y2 - y1 + 1) // arrays start at 1

	for(var/turf/T in block(locate(x1, y1, z_level), locate(x2, y2, z_level)))
		var/area/A = T.loc
		var/img_x = T.x - x1 + 1 // arrays start at 1
		var/img_y = T.y - y1 + 1

		if(A.minimap_show_walls && istype(T, /turf/closed/wall))
			map_icon.DrawBox("#000000", img_x, img_y)

		else if(!istype(A, /area/space))
			var/color = (A.minimap_color2 ? (((img_x + img_y) % 2) ? A.minimap_color2 : A.minimap_color ) : A.minimap_color) || "#FF00FF"
			if(A.minimap_show_walls)
				var/overridden
				for(var/obj/structure/O in T)
					if(O.minimap_override_color)
						color = O.minimap_override_color
						overridden = TRUE
						break
					else if(O.density && O.anchored)
						color = BlendRGB(color, "#000000", 0.5)
						overridden = TRUE
						break

				//In an ideal world, we'd be able to get away with just doing for(var/obj/O in T) up there, and calling it a day. However. HOWEVER!
				//Doing that causes the code to also loop through items. and that uh. Kinda bloats minimap gen time. A LOT. We're talking straight-up doubling the time it takes to gen.
				//So instead we take our ctrl+c. We copy the above code. And we ctrl+v. It's awful. We hate it. But it works. It's faster. Funny mapgen go vroom
				if(!overridden)
					for(var/obj/machinery/O in T)
						if(O.minimap_override_color)
							color = O.minimap_override_color
							break
						else if(O.density && O.anchored)
							color = BlendRGB(color, "#000000", 0.25)
							break

			map_icon.DrawBox(color, img_x, img_y)

	map_icon.Scale(480, 480)
	map_icon.Blend(background_icon, ICON_UNDERLAY)
	map_full_image = image(map_icon)
