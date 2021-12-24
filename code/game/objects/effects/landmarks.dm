/atom/movable/landmark
	name = "landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	layer = MID_LANDMARK_LAYER
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/atom/movable/landmark/singularity_act()
	return

// Please stop bombing the Observer-Start landmark.
/atom/movable/landmark/ex_act(severity, target, origin)
	return

/atom/movable/landmark/singularity_pull()
	return

INITIALIZE_IMMEDIATE(/atom/movable/landmark)

/atom/movable/landmark/Initialize()
	. = ..()
	GLOB.landmarks_list += src

/atom/movable/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()

/atom/movable/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE
	var/used = FALSE
	var/job_spawnpoint = TRUE //Is it a potential job spawnpoint or should we skip it?

/atom/movable/landmark/start/proc/after_round_start()
	if(delete_after_roundstart)
		qdel(src)

/atom/movable/landmark/start/New()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		if(!GLOB.jobspawn_overrides[name])
			GLOB.jobspawn_overrides[name] = list()
		GLOB.jobspawn_overrides[name] += src
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

// carp.
/atom/movable/landmark/carpspawn
	name = "carpspawn"
	icon_state = "carp_spawn"

// lone op (optional)
/atom/movable/landmark/loneopspawn
	name = "loneop+ninjaspawn"
	icon_state = "snukeop_spawn"

// observer-start.
/atom/movable/landmark/observer_start
	name = "Observer-Start"
	icon_state = "observer_start"

// xenos.
/atom/movable/landmark/xeno_spawn
	name = "xeno_spawn"
	icon_state = "xeno_spawn"

/atom/movable/landmark/xeno_spawn/Initialize(mapload)
	..()
	GLOB.xeno_spawn += loc
	return INITIALIZE_HINT_QDEL

// blobs.
/atom/movable/landmark/blobstart
	name = "blobstart"
	icon_state = "blob_start"

/atom/movable/landmark/blobstart/Initialize(mapload)
	..()
	GLOB.blobstart += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/secequipment
	name = "secequipment"
	icon_state = "secequipment"

/atom/movable/landmark/secequipment/Initialize(mapload)
	..()
	GLOB.secequipment += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/prisonwarp
	name = "prisonwarp"
	icon_state = "prisonwarp"

/atom/movable/landmark/prisonwarp/Initialize(mapload)
	..()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/ert_spawn
	name = "Emergencyresponseteam"
	icon_state = "ert_spawn"

/atom/movable/landmark/ert_spawn/Initialize(mapload)
	..()
	GLOB.emergencyresponseteamspawn += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/holding_facility
	name = "Holding Facility"
	icon_state = "holding_facility"

/atom/movable/landmark/holding_facility/Initialize(mapload)
	..()
	GLOB.holdingfacility += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/thunderdome/observe
	name = "tdomeobserve"
	icon_state = "tdome_observer"

/atom/movable/landmark/thunderdome/observe/Initialize(mapload)
	..()
	GLOB.tdomeobserve += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/thunderdome/one
	name = "tdome1"
	icon_state = "tdome_t1"

/atom/movable/landmark/thunderdome/one/Initialize(mapload)
	..()
	GLOB.tdome1	+= loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/thunderdome/two
	name = "tdome2"
	icon_state = "tdome_t2"

/atom/movable/landmark/thunderdome/two/Initialize(mapload)
	..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/atom/movable/landmark/thunderdome/admin
	name = "tdomeadmin"
	icon_state = "tdome_admin"

/atom/movable/landmark/thunderdome/admin/Initialize(mapload)
	..()
	GLOB.tdomeadmin += loc
	return INITIALIZE_HINT_QDEL

//Servant spawn locations
/atom/movable/landmark/servant_of_ratvar
	name = "servant of ratvar spawn"
	icon_state = "clockwork_orange"
	layer = MOB_LAYER

/atom/movable/landmark/servant_of_ratvar/Initialize(mapload)
	..()
	GLOB.servant_spawns += loc
	return INITIALIZE_HINT_QDEL

//City of Cogs entrances
/atom/movable/landmark/city_of_cogs
	name = "city of cogs entrance"
	icon_state = "city_of_cogs"

/atom/movable/landmark/city_of_cogs/Initialize(mapload)
	..()
	GLOB.city_of_cogs_spawns += loc
	return INITIALIZE_HINT_QDEL

//generic event spawns
/atom/movable/landmark/event_spawn
	name = "generic event spawn"
	icon_state = "generic_event"
	layer = HIGH_LANDMARK_LAYER


/atom/movable/landmark/event_spawn/New()
	..()
	GLOB.generic_event_spawns += src

/atom/movable/landmark/event_spawn/Destroy()
	GLOB.generic_event_spawns -= src
	return ..()

/atom/movable/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/atom/movable/landmark/ruin/New(loc, my_ruin_template)
	name = "ruin_[GLOB.ruin_landmarks.len + 1]"
	..(loc)
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/atom/movable/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()

//------Station Rooms Landmarks------------//
/atom/movable/landmark/stationroom
	var/list/templates = list()
	layer = BULLET_HOLE_LAYER
	plane = ABOVE_WALL_PLANE

/atom/movable/landmark/stationroom/New()
	..()
	GLOB.stationroom_landmarks += src

/atom/movable/landmark/stationroom/Destroy()
	if(src in GLOB.stationroom_landmarks)
		GLOB.stationroom_landmarks -= src
	return ..()

/atom/movable/landmark/stationroom/proc/load(template_name)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!template_name)
		for(var/t in templates)
			if(!SSmapping.station_room_templates[t])
				log_world("Station room spawner placed at ([T.x], [T.y], [T.z]) has invalid ruin name of \"[t]\" in its list")
				templates -= t
		template_name = pickweight(templates, 0)
	if(!template_name)
		GLOB.stationroom_landmarks -= src
		qdel(src)
		return FALSE
	var/datum/map_template/template = SSmapping.station_room_templates[template_name]
	if(!template)
		return FALSE
	testing("Room \"[template_name]\" placed at ([T.x], [T.y], [T.z])")
	template.load(T, centered = FALSE, orientation = dir, rotate_placement_to_orientation = TRUE)
	template.loaded++
	GLOB.stationroom_landmarks -= src
	qdel(src)
	return TRUE

// The landmark for the Engine on Box

/atom/movable/landmark/stationroom/box/engine
	templates = list("Engine SM" = 3, "Engine Singulo" = 3, "Engine Tesla" = 3)
	icon = 'icons/rooms/box/engine.dmi'

/atom/movable/landmark/stationroom/box/engine/New()
	. = ..()
	templates = CONFIG_GET(keyed_list/box_random_engine)

// Landmark for the mining station
/atom/movable/landmark/stationroom/lavaland/station
	templates = list("Public Mining Base" = 3)
	icon = 'icons/rooms/Lavaland/Mining.dmi'

// handled in portals.dm, id connected to one-way portal
/atom/movable/landmark/portal_exit
	name = "portal exit"
	icon_state = "portal_exit"
	var/id
