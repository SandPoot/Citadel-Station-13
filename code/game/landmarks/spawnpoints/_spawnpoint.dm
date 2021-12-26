/atom/movable/landmark/spawnpoint
	name = "unknown spawnpoint"
	icon = 'icons/mapping/landmarks/spawnpoints.dmi'
	/// prevent stacking of mobs
	var/prevent_mob_stack = TRUE
	/// Spawns left
	var/spawns_left = INFINITY

/atom/movable/landmark/spawnpoint/Initialize(mapload)
	Register()
	return ..()

/atom/movable/landmark/spawnpoint/forceMove(atom/destination)
	Unregister()
	. = ..()
	Register()

/atom/movable/landmark/spawnpoint/proc/Register()
	CRASH("Attempted to register an abstract landmark")

/atom/movable/landmark/spawnpoint/proc/Unregister()
	CRASH("Attempted to unregister an abstract landmark")

/atom/movable/landmark/spawnpoint/proc/GetSpawnLoc()
	if(!loc)
		stack_race("Landmark: Null loc detected on GetSpawnLoc().")
	return loc

/atom/movable/landmark/spawnpoint/proc/OnSpawn(mob/M)
	spawns_left = max(0, spawns_left - 1)

/atom/movable/landmark/spawnpoint/proc/Available(mob/M)
	if(!spawns_left)
		return FALSE
	if(prevent_mob_stack)
		if(ishuman(M) && (locate(/mob/living/carbon/human) in GetSpawnLoc()))
			return FALSE
		else if(locate(M.type) in GetSpawnLoc())
			return FALSE
	return TRUE

/**
 * Used first priority for job spawning
 */
/atom/movable/landmark/spawnpoint/job
	name = "unknown job spawnpoint"
	spawns_left = 1
	/// Job path
	var/job_path
	/// Roundstart?
	var/roundstart = TRUE
	/// Latejoin?
	var/latejoin = FALSE

/**
 * Used when there's no job specific latejoin spawnpoints
 */
/atom/movable/landmark/spawnpoint/latejoin
	name = "unknown latejoin spawnpoint"
	/// Faction
	var/faction

/**
 * Used when all other spawnpoints are unavailable
 */
/atom/movable/landmark/spawnpoint/overflow
	name = "unknown overflow spawnpoint"
	/// Faction
	var/faction
