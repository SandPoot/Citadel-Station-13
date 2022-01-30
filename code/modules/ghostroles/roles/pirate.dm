
/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum. The sleeper looks unstable. <i>Perhaps the pirate within can be killed with the right tools...</i>"
	job_description = "Space Pirate"
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton/space
	outfit = /datum/outfit/pirate/space
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	short_desc = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	assignedrole = "Space Pirate"
	var/rank = "Mate"

#warn convert

/obj/effect/mob_spawn/human/pirate/on_attack_hand(mob/living/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(.)
		return
	if(user.mind.has_antag_datum(/datum/antagonist/pirate))
		to_chat(user, "<span class='notice'>Your shipmate sails within their dreams for now. Perhaps they may wake up eventually.</span>")
	else
		to_chat(user, "<span class='notice'>If you want to kill the pirate off, something to pry open the sleeper might be the best way to do it.</span>")


/obj/effect/mob_spawn/human/pirate/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_CROWBAR && user.a_intent != INTENT_HARM)
		if(user.mind.has_antag_datum(/datum/antagonist/pirate))
			to_chat(user,"<span class='warning'>Why would you want to do that to your shipmate? That'd kill them.</span>")
			return
		user.visible_message("<span class='warning'>[user] start to pry open [src]...</span>",
				"<span class='notice'>You start to pry open [src]...</span>",
				"<span class='italics'>You hear prying...</span>")
		W.play_tool_sound(src)
		if(do_after(user, 100*W.toolspeed, target = src))
			user.visible_message("<span class='warning'>[user] pries open [src], disrupting the sleep of the pirate within and killing them.</span>",
				"<span class='notice'>You pry open [src], disrupting the sleep of the pirate within and killing them.</span>",
				"<span class='italics'>You hear prying, followed by the death rattling of bones.</span>")
			log_game("[key_name(user)] has successfully pried open [src] and disabled a space pirate spawner.")
			W.play_tool_sound(src)
			playsound(src.loc, 'modular_citadel/sound/voice/scream_skeleton.ogg', 50, 1, 4, 1.2)
			if(rank == "Captain")
				new /obj/effect/mob_spawn/human/pirate/corpse/captain(get_turf(src))
			else
				new /obj/effect/mob_spawn/human/pirate/corpse(get_turf(src))
			qdel(src)
	else
		..()

/obj/effect/mob_spawn/human/pirate/corpse //occurs when someone pries a pirate out of their sleeper.
	mob_name = "Dead Space Pirate"
	death = TRUE
	instant = TRUE
	random = FALSE

/obj/effect/mob_spawn/human/pirate/corpse/captain
	rank = "Captain"
	mob_name = "Dead Space Pirate Captain"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name()
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Gunner"
