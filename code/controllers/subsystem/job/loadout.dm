#warn this is dumb and needs redone
/datum/controller/subsystem/job/proc/equip_loadout(mob/dead/new_player/N, mob/living/M, equipbackpackstuff, bypass_prereqs = FALSE, can_drop = TRUE)
	var/mob/the_mob = N
	if(!the_mob)
		the_mob = M // cause this doesn't get assigned if player is a latejoiner
	var/list/chosen_gear = the_mob.client.prefs.loadout_data["SAVE_[the_mob.client.prefs.loadout_slot]"]
	if(the_mob.client && the_mob.client.prefs && (chosen_gear && chosen_gear.len))
		if(!ishuman(M))//no silicons allowed
			return
		for(var/i in chosen_gear)
			var/datum/gear/G = istext(i[LOADOUT_ITEM]) ? text2path(i[LOADOUT_ITEM]) : i[LOADOUT_ITEM]
			G = GLOB.loadout_items[initial(G.category)][initial(G.subcategory)][initial(G.name)]
			if(!G)
				continue
			var/permitted = TRUE
			if(!bypass_prereqs && G.restricted_roles && G.restricted_roles.len && !(M.mind.assigned_role in G.restricted_roles))
				permitted = FALSE
			if(G.donoritem && !G.donator_ckey_check(the_mob.client.ckey))
				permitted = FALSE
			if(!equipbackpackstuff && G.slot == SLOT_IN_BACKPACK)//snowflake check since plopping stuff in the backpack doesnt work for pre-job equip loadout stuffs
				permitted = FALSE
			if(equipbackpackstuff && G.slot != SLOT_IN_BACKPACK)//ditto
				permitted = FALSE
			if(!permitted)
				continue
			var/obj/item/I = new G.path
			if(I)
				if(length(i[LOADOUT_COLOR])) //handle loadout colors
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
						I.update_icon()
				//when inputting the data it's already sanitized
				if(i[LOADOUT_CUSTOM_NAME])
					var/custom_name = i[LOADOUT_CUSTOM_NAME]
					I.name = custom_name
				if(i[LOADOUT_CUSTOM_DESCRIPTION])
					var/custom_description = i[LOADOUT_CUSTOM_DESCRIPTION]
					I.desc = custom_description
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
