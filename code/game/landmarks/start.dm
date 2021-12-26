/atom/movable/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/delete_after_roundstart = TRUE
	var/used = FALSE

/atom/movable/landmark/start/proc/after_round_start()
	if(delete_after_roundstart)
		qdel(src)

/atom/movable/landmark/start/New()
	GLOB.start_landmarks_list += src
	..()
	if(name != "start")
		tag = "start*[name]"

/atom/movable/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		GLOB.jobspawn_overrides[name] -= src
	return ..()

// START LANDMARKS FOLLOW. Don't change the names unless
// you are refactoring shitty landmark code.
/atom/movable/landmark/start/assistant
	name = "Assistant"
	icon_state = "Assistant"

/atom/movable/landmark/start/prisoner
	name = "Prisoner"
	icon_state = "Prisoner"

/atom/movable/landmark/start/assistant/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/atom/movable/landmark/start/janitor
	name = "Janitor"
	icon_state = "Janitor"

/atom/movable/landmark/start/cargo_technician
	name = "Cargo Technician"
	icon_state = "Cargo Technician"

/atom/movable/landmark/start/bartender
	name = "Bartender"
	icon_state = "Bartender"

/atom/movable/landmark/start/clown
	name = "Clown"
	icon_state = "Clown"

/atom/movable/landmark/start/mime
	name = "Mime"
	icon_state = "Mime"

/atom/movable/landmark/start/quartermaster
	name = "Quartermaster"
	icon_state = "Quartermaster"

/atom/movable/landmark/start/atmospheric_technician
	name = "Atmospheric Technician"
	icon_state = "Atmospheric Technician"

/atom/movable/landmark/start/cook
	name = "Cook"
	icon_state = "Cook"

/atom/movable/landmark/start/shaft_miner
	name = "Shaft Miner"
	icon_state = "Shaft Miner"

/atom/movable/landmark/start/security_officer
	name = "Security Officer"
	icon_state = "Security Officer"

/atom/movable/landmark/start/botanist
	name = "Botanist"
	icon_state = "Botanist"

/atom/movable/landmark/start/head_of_security
	name = "Head of Security"
	icon_state = "Head of Security"

/atom/movable/landmark/start/captain
	name = "Captain"
	icon_state = "Captain"

/atom/movable/landmark/start/detective
	name = "Detective"
	icon_state = "Detective"

/atom/movable/landmark/start/warden
	name = "Warden"
	icon_state = "Warden"

/atom/movable/landmark/start/chief_engineer
	name = "Chief Engineer"
	icon_state = "Chief Engineer"

/atom/movable/landmark/start/head_of_personnel
	name = "Head of Personnel"
	icon_state = "Head of Personnel"

/atom/movable/landmark/start/librarian
	name = "Curator"
	icon_state = "Curator"

/atom/movable/landmark/start/lawyer
	name = "Lawyer"
	icon_state = "Lawyer"

/atom/movable/landmark/start/station_engineer
	name = "Station Engineer"
	icon_state = "Station Engineer"

/atom/movable/landmark/start/medical_doctor
	name = "Medical Doctor"
	icon_state = "Medical Doctor"

/atom/movable/landmark/start/paramedic
	name = "Paramedic"
	icon_state = "Paramedic"

/atom/movable/landmark/start/scientist
	name = "Scientist"
	icon_state = "Scientist"

/atom/movable/landmark/start/chemist
	name = "Chemist"
	icon_state = "Chemist"

/atom/movable/landmark/start/roboticist
	name = "Roboticist"
	icon_state = "Roboticist"

/atom/movable/landmark/start/research_director
	name = "Research Director"
	icon_state = "Research Director"

/atom/movable/landmark/start/geneticist
	name = "Geneticist"
	icon_state = "Geneticist"

/atom/movable/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"
	icon_state = "Chief Medical Officer"

/atom/movable/landmark/start/virologist
	name = "Virologist"
	icon_state = "Virologist"

/atom/movable/landmark/start/chaplain
	name = "Chaplain"
	icon_state = "Chaplain"

/atom/movable/landmark/start/cyborg
	name = "Cyborg"
	icon_state = "Cyborg"

/atom/movable/landmark/start/ai
	name = "AI"
	icon_state = "AI"
	delete_after_roundstart = FALSE
	var/primary_ai = TRUE
	var/latejoin_active = TRUE

/atom/movable/landmark/start/ai/after_round_start()
	if(latejoin_active && !used)
		new /obj/structure/AIcore/latejoin_inactive(loc)
	return ..()

/atom/movable/landmark/start/ai/secondary
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "ai_spawn"
	primary_ai = FALSE
	latejoin_active = FALSE

//Department Security spawns

/atom/movable/landmark/start/depsec
	name = "department_sec"
	icon_state = "Security Officer"

/atom/movable/landmark/start/depsec/New()
	..()
	GLOB.department_security_spawns += src

/atom/movable/landmark/start/depsec/Destroy()
	GLOB.department_security_spawns -= src
	return ..()

/atom/movable/landmark/start/depsec/supply
	name = "supply_sec"

/atom/movable/landmark/start/depsec/medical
	name = "medical_sec"

/atom/movable/landmark/start/depsec/engineering
	name = "engineering_sec"

/atom/movable/landmark/start/depsec/science
	name = "science_sec"

/atom/movable/landmark/start/wizard
	name = "wizard"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "wiznerd_spawn"

/atom/movable/landmark/start/wizard/Initialize()
	..()
	GLOB.wizardstart += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/start/nukeop
	name = "nukeop"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"

/atom/movable/landmark/start/nukeop/Initialize()
	..()
	GLOB.nukeop_start += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/start/nukeop_leader
	name = "nukeop leader"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_leader_spawn"

/atom/movable/landmark/start/nukeop_leader/Initialize()
	..()
	GLOB.nukeop_leader_start += loc
	return INITIALIZE_HINT_QDEL

// Must be immediate because players will
// join before SSatom initializes everything.
INITIALIZE_IMMEDIATE(/atom/movable/landmark/start/new_player)

/atom/movable/landmark/start/new_player
	name = "New Player"

/atom/movable/landmark/start/new_player/Initialize()
	..()
	GLOB.newplayer_start += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/start/nuclear_equipment
	name = "bomb or clown beacon spawner"
	var/nukie_path = /obj/item/sbeacondrop/bomb
	var/clown_path = /obj/item/sbeacondrop/clownbomb
	job_spawnpoint = FALSE

/atom/movable/landmark/start/nuclear_equipment/after_round_start()
	var/npath = nukie_path
	if(istype(SSticker.mode, /datum/game_mode/nuclear/clown_ops))
		npath = clown_path
	else if(istype(SSticker.mode, /datum/game_mode/dynamic))
		var/datum/game_mode/dynamic/D = SSticker.mode
		if(locate(/datum/dynamic_ruleset/roundstart/nuclear/clown_ops) in D.current_rules)
			npath = clown_path
	new npath(loc)
	return ..()

/atom/movable/landmark/start/nuclear_equipment/minibomb
	name = "minibomb or bombanana spawner"
	nukie_path = /obj/item/storage/box/minibombs
	clown_path = /obj/item/storage/box/bombananas

/atom/movable/landmark/latejoin
	name = "JoinLate"

/atom/movable/landmark/latejoin/Initialize(mapload)
	..()
	SSjob.latejoin_trackers += loc
	return INITIALIZE_HINT_QDEL
