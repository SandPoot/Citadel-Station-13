SUBSYSTEM_DEF(minimaps)
	name = "Minimaps"
	flags = SS_NO_FIRE
	/// Associative list, [z] = /datum/minimap
	var/list/minimap_list

/datum/controller/subsystem/minimaps/Initialize()
	if(!CONFIG_GET(flag/minimaps_enabled))
		to_chat(world, span_boldwarning("Minimaps disabled! Skipping init."))
		return ..()
	build_minimaps()
	return ..()

/datum/controller/subsystem/minimaps/proc/build_minimaps()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/datum/space_level/SL = SSmapping.get_level(z)
		var/name = (SL.name == initial(SL.name))? "[z] - Station" : "[z] - [SL.name]"
		LAZYSET(minimap_list, "[z]", new /datum/minimap(z, name = name))
