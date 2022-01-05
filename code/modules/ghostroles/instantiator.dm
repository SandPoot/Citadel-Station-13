/**
 * Handles mob creation, equip, and ckey transfer.
 */
/datum/ghostrole_instantiator

/datum/ghostrole_instantiator/proc/Run(client/C, atom/location)
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

/datum/ghostrole_instantiator/proc/Create(client/C, atom/location)
	CRASH("Base Create() called on ghostrole instantiator datum.")

/datum/ghostrole_instantiator/proc/Equip(client/C, mob/M)
	CRASH("Base Equip() called on ghostrole instantiator datum.")

/datum/ghostrole_instantiator/proc/Transfer(client/C, mob/M)
	CRASH("Base Transfer() called on ghostrole instantiator datum.")

/datum/ghostrole_instantiator/human
	/// outfit to equip
	var/equip_outfit
	/// exempt from midround health events
	var/exempt_health_events = FALSE

/datum/ghostrole_instantiator/human/Create(client/C, atom/location)
	var/mob/living/carbon/human/H = new(location)
	if(exempt_health_events)
		ADD_TRAIT(H, TRAIT_EXEMPT_HEALTH_EVENTS, GHOSTROLE_TRAIT)
	return H

/datum/ghostrole_instantiator/human/Equip(client/C, mob/M)
	if(ispath(equip_outfit, /datum/outfit))
		var/datum/outfit/O = new equip_outfit
		O.equip(M)
	#warn survival gear

/datum/ghostrole_instantiator/human/random

/datum/ghostrole_instantiator/human/random/Create(client/C, atom/location)
	var/mob/living/carbon/human/H = ..()
	Randomize(H)
	return H

/datum/ghostrole_instantiator/human/random/proc/Randomize(mob/living/carbon/human/H)
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

/datum/ghostrole_instantiator/human/random/species/Randomize(mob/living/carbon/human/H)
	. = ..()
	#warn impl

/datum/ghostrole_instantiator/human/player_static
	/// equip loadout
	var/equip_loadout = TRUE
	/// equip traits
	var/equip_traits = TRUE

/datum/ghostrole_instantiator/human/player_static/Create(client/C, atom/location)
	var/mob/living/carbon/human/H = ..()
	LoadSavefile(C, H)
	return H
