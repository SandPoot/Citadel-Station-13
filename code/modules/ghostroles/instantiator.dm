/**
 * Handles mob creation, equip, and ckey transfer.
 */
/datum/ghostrole_instantiator
	/// traits to add to mob : will be made with GHOSTROLE_TRAIT source
	var/list/mob_traits

/datum/ghostrole_instantiator/proc/Run(client/C, atom/location, list/params)
	RETURN_TYPE(/mob)
	. = Create(C, location)
	if(!.)
		return
	if(!Equip(C, .))
		qdel(.)
		return null
	if(!Transfer(C, .))
		qdel(.)
		return null

/datum/ghostrole_instantiator/proc/Create(client/C, atom/location, list/params)
	CRASH("Base Create() called on ghostrole instantiator datum.")

/datum/ghostrole_instantiator/proc/Equip(client/C, mob/M, list/params)
	CRASH("Base Equip() called on ghostrole instantiator datum.")

/datum/ghostrole_instantiator/proc/Transfer(client/C, mob/M, list/params)
	CRASH("Base Transfer() called on ghostrole instantiator datum.")

/datum/ghostrole_instantiator/human
	/// outfit to equip
	var/equip_outfit
	/// exempt from midround health events
	var/exempt_health_events = FALSE

/datum/ghostrole_instantiator/human/Create(client/C, atom/location, list/params)
	var/mob/living/carbon/human/H = new(location)
	if(exempt_health_events)
		ADD_TRAIT(H, TRAIT_EXEMPT_HEALTH_EVENTS, GHOSTROLE_TRAIT)
	for(var/trait in mob_traits)
		ADD_TRAIT(H, trait, GHOSTROLE_TRAIT)
	return H

/datum/ghostrole_instantiator/human/Equip(client/C, mob/M, list/params)
	var/datum/outfit/O = GetOutfit(C, M, params)
	if(O)
		O.equip(M)
	var/mob/living/carbon/human/H = M

	#warn survival gear

/datum/ghostrole_instantiator/human/proc/GetOutfit(client/C, mob/M, list/params)
	if(ispath(equip_outfit, /datum/outfit))
		return new equip_outfit
	if(istype(equip_outfit, /datum/outfit))
		return equip_outfit

/datum/ghostrole_instantiator/human/random

/datum/ghostrole_instantiator/human/random/Create(client/C, atom/location, list/params)
	var/mob/living/carbon/human/H = ..()
	Randomize(H, params)
	return H

/datum/ghostrole_instantiator/human/random/proc/Randomize(mob/living/carbon/human/H, list/params)
	return			// tgcode does this automatically

/datum/ghostrole_instantiator/human/random/species
	/// allowed species types
	var/list/possible_species = list(
		/datum/species/human,
		/datum/species/lizard,
		/datum/species/plasmaman,
		/datum/species/jelly,
		/datum/species/ipc,
	)

/datum/ghostrole_instantiator/human/random/species/Randomize(mob/living/carbon/human/H, list/params)
	. = ..()
	#warn impl

/datum/ghostrole_instantiator/human/player_static
	/// equip loadout
	var/equip_loadout = TRUE
	/// equip traits
	var/equip_traits = TRUE

/datum/ghostrole_instantiator/human/player_static/Create(client/C, atom/location, list/params)
	var/mob/living/carbon/human/H = ..()
	LoadSavefile(C, H)
	return H

/datum/ghostrole_instantiator/human/player_static/proc/LoadSavefile(client/C, mob/living/carbon/human/H)
	C.prefs.copy_to(H)
	SSjob.EquipLoadout(H, FALSE, null, C.prefs, C.ckey)
	if(CONFIG_GET(flag/roundstart_traits))
		SSquirks.AssignQuirks(H, C, TRUE, FALSE, null, FALSE, C)
