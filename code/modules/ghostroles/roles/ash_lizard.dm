/datum/ghostrole/ashwalker
	name = "Ashwalker"
	instantiator = /datum/ghostrole_instantiator/human/random/species/ashwalker
	desc = "You are an ash walker. Your tribe worships the Necropolis."
	spawntext = "The wastes are sacred ground, its monsters a blessed bounty. You would never willingly leave your homeland behind. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders to your domain. \
	Ensure your nest remains protected at all costs."
	assigned_role = "Ash Walker"
	allow_pick_spawner = TRUE

/datum/ghostrole/ashwalker/Greet(mob/created)
	. = ..()
	if(is_mining_level(get_turf(created).z))
		to_chat(new_spawn, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Necropolis!</b>")
		to_chat(new_spawn, "<b>You can expand the weather proof area provided by your shelters by using the 'New Area' key near the bottom right of your HUD.</b>")
	else
		to_chat(new_spawn, "<span class='userdanger'>You have been born outside of your natural home! Whether you decide to return home, or make due with your new home is your own decision.</span>")

/datum/ghostrole_instantiator/human/random/species/ashwalker
	possible_species = list(
		/datum/species/lizard/ashwalker
	)
	outfit = /datum/outfit/ashwalker

/datum/ghostrole_instantiator/human/random/species/ashwalker/Randomize(mob/living/carbon/human/H)
	. = ..()
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	H.update_body()

/obj/structure/ghost_role_spawner/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	role_type = /datum/ghsotrole/ashwalker
	role_spawns = 1

/obj/structure/ghost_role_spawner/ash_walker/on_spawn(mob/created, datum/ghostrole/role, list/params)
	. = ..()
	qdel(src)

/datum/outfit/ashwalker
	name ="Ashwalker"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker
