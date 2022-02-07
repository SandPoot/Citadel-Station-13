/**
 * returns list of items that need to be placed in backpack/dropped on ground
 */
/datum/controller/subsystem/job/proc/EquipLoadout(mob/living/M, ignore_restrictions = FALSE, datum/job/J, datum/preferences/P, ckey)
	. = list()
	ASSERT(M)
	// allow autodetection of ckey, prefs
	if(!ckey)
		ckey = M.ckey
	if(!P)
		P = GLOB.preferences_datums[ckey]
	ASSERT(P)
	// allow autodetection of job - if you want to ignore job restrictions just have ignore_restrictions = TRUE
	if(!J)
		J = M.mind?.assigned_role
		if(J)
			J = GetJobAuto(J)
	// for chat output
	var/client/C = GLOB.directory[ckey] || M.client

	// failures before this point runtime
	JobDebug("EquipLoadout: [M], ignore [ignore_restrictions], job [J.title], ckey [ckey]")

	if(!ishuman(M))
		JobDebug("Ignoring EquipLoadout for [M]: Not human.")
		return

	if(!LAZYLEN(P.chosen_gear))
		JobDebug("Ignoring EquipLoadout for [M]: No gear chosen.")
		return

	var/list/chosen_gear = P.loadout_data["SAVE_[P.loadout_slot]"]
	for(var/i in P.chosen_gear)
		var/datum/gear/G = istext(i[LOADOUT_ITEM])? text2path(i[LOADOUT_ITEM]) : i[LOADOUT_ITEM]
		G = GLOB.loadout_items[initial(G.category)][initial(G.subcategory)][initial(G.name)]
		if(!G)
			JobDebug("Failed to locate loadout item [i[LOADOUT_ITEM]]")
			continue
		if(!ignore_restrictions && !CanEquipGear(G, ckey, J))
			JobDebug("Ignoring [G.type]: CanEquipGear failed")
			continue
		if(!ispath(G.path))
			stack_trace("Invalid path on [G.type]")
			continue
		// todo: have G.Instantiate(ckey, data) and gear tweaks, refactor fucking loadout
		var/obj/item/I = new G.path
		if(length(i[LOADOUT_COLOR]))
			//handle polychromic items
			if((G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC) && length(G.loadout_initial_colors))
				var/datum/element/polychromic/polychromic = LAZYACCESS(I.comp_lookup, "item_worn_overlays") //stupid way to do it but GetElement does not work for this
				if(polychromic && istype(polychromic))
					var/list/polychromic_entry = polychromic.colors_by_atom[I]
					if(polychromic_entry)
						if(polychromic.suits_with_helmet_typecache[I.type]) //is this one of those toggleable hood/helmet things?
							polychromic.connect_helmet(I,i[LOADOUT_COLOR])
						polychromic.colors_by_atom[I] = i[LOADOUT_COLOR]
						I.update_icon()
			else
				//handle non-polychromic items (they only have one color)
				I.add_atom_colour(i[LOADOUT_COLOR][1], FIXED_COLOUR_PRIORITY)
		//when inputting the data it's already sanitized
		if(i[LOADOUT_CUSTOM_NAME])
			var/custom_name = i[LOADOUT_CUSTOM_NAME]
			I.name = custom_name
		if(i[LOADOUT_CUSTOM_DESCRIPTION])
			var/custom_description = i[LOADOUT_CUSTOM_DESCRIPTION]
			I.desc = custom_description
		I.update_appearance()
		if(G.slot == SLOT_IN_BACKPACK)
			. += I
			continue
		if(!M.equip_to_slot_if_possible(I, G.slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
			. += I
			continue

/datum/controller/subsystem/job/proc/CanEquipGear(datum/gear/G, ckey, datum/job/J)
	. = FALSE
	if(!istype(G))
		CRASH("Bad gear datum")
	if(LAZYLEN(G.restricted_roles) && !(J.title in G.restricted_roles))		// todo: have job ids instead of titles
		JobDebug("CanEquipGear failed [ckey] [G.type] [J? J.title : "NOJOB"]: Wrong job")
		return
	if(G.donoritem && !G.donator_ckey_check(ckey))
		JobDebug("CanEquipGear failed [ckey] [G.type] [J? J.title : "NOJOB"]: Donator item")
		return
	return TRUE

/datum/controller/subsystem/job/proc/HandleLoadoutLeftovers(mob/living/M, list/obj/item/items)


#warn this is dumb and needs redone
/datum/controller/subsystem/job/proc/equip_loadout(mob/dead/new_player/N, mob/living/M, equipbackpackstuff, bypass_prereqs = FALSE, can_drop = TRUE)

			if(!M.equip_to_slot_if_possible(I, G.slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE)) // If the job's dresscode compliant, try to put it in its slot, first
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					var/obj/item/storage/backpack/B = C.back
					if(!B || !SEND_SIGNAL(B, COMSIG_TRY_STORAGE_INSERT, I, null, TRUE, TRUE)) // Otherwise, try to put it in the backpack, for carbons.
						if(can_drop)
							I.forceMove(get_turf(C))
						else
							qdel(I)
				else if(!M.equip_to_slot_if_possible(I, SLOT_IN_BACKPACK, disable_warning = TRUE, bypass_equip_delay_self = TRUE)) // Otherwise, try to put it in the backpack
					if(can_drop)
						I.forceMove(get_turf(M)) // If everything fails, just put it on the floor under the mob.
					else
						qdel(I)
