//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.
#warn convert

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	mob_name = "a lifebringer"
	job_description = "Lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	short_desc = "You are a sentient ecosystem, an example of the mastery over life that your creators possessed."
	flavour_text = "Your masters, benevolent as they were, created uncounted seed vaults and spread them across \
	the universe to every planet they could chart. You are in one such seed vault. \
	Your goal is to cultivate and spread life wherever it will go while waiting for contact from your creators. \
	Estimated time of last contact: Deployment, 5000 millennia ago."
	assignedrole = "Lifebringer"

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/carbon/human/new_spawn)
	ADD_TRAIT(new_spawn,TRAIT_EXEMPT_HEALTH_EVENTS,GHOSTROLE_TRAIT)
	var/plant_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.real_name = plant_name //why this works when moving it from one function to another is beyond me
	new_spawn.underwear = "Nude" //You're a plant, partner
	new_spawn.undershirt = "Nude" //changing underwear/shirt/socks doesn't seem to function correctly right now because of some bug elsewhere?
	new_spawn.socks = "Nude"
	new_spawn.update_body(TRUE)
	new_spawn.language_holder.selected_language = /datum/language/sylvan
