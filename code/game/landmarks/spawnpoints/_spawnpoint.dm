/atom/movable/landmark/spawnpoint
	name = "unknown spawnpoint"
	#warn port icons over
	icon = 'icons/mapping/landmarks/spawnpoints.dmi'
	/// prevent stacking of mobs
	var/prevent_mob_stack = TRUE
	/// Spawns left
	var/spawns_left = INFINITY
	/// Number of spawns currently
	var/spawned = 0
	/// Delete post-roundstart
	var/delete_after_roundstart = FALSE
	/// Delete on depletion
	var/delete_after_depleted = FALSE
	/// Priority - landmark is binary inserted on register/unregister. Lower numbers are higher priority.
	var/priority = 0

/atom/movable/landmark/spawnpoint/Initialize(mapload)
	Register()
	return ..()

/atom/movable/landmark/spawnpoint/forceMove(atom/destination)
	Unregister()
	. = ..()
	Register()

/atom/movable/landmark/spawnpoint/vv_edit_var(var_name, var_value, massedit)
	if(var_name == NAMEOF(src, priority))
		Unregister()
	. = ..()
	if(var_name == NAMEOF(src, priority))
		Register()


/atom/movable/landmark/spawnpoint/proc/Register()
	return

/atom/movable/landmark/spawnpoint/proc/Unregister()
	return

/atom/movable/landmark/spawnpoint/proc/AutoListRegister(list/L)
	if(src in L)
		return
	BINARY_INSERT(src, L, /atom/movable/landmark/spawnpoint, src, priority, COMPARE_KEY))

/atom/movable/landmark/spawnpoint/proc/AutoListUnregister(list/L)
	if(!L)
		return
	L -= src

/atom/movable/landmark/spawnpoint/proc/GetSpawnLoc()
	if(!loc)
		stack_race("Landmark: Null loc detected on GetSpawnLoc().")
	return loc

/atom/movable/landmark/spawnpoint/proc/OnSpawn(mob/M)
	spawns_left = max(0, spawns_left - 1)
	++spawned

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

/atom/movable/landmark/spawnpoint/job/Register()
	. = ..()
	if(!job_path)
		return
	LAZYINITLIST(SSjob.job_spawnpoints)
	LAZYINITLIST(SSjob.job_spawnpoints[job_path])
	AutoListRegister(SSjob.job_spawnpoints[job_path])

/atom/movable/landmark/spawnpoint/job/Unregister()
	. = ..()
	if(!job_path)
		return
	AutoListUnregister(SSjob.job_spawnpoints[job_path])

/atom/movable/landmark/spawnpoint/job/vv_edit_var(var_name, var_value, massedit)
	if(var_name == NAMEOF(src, job_path))
		Register()
	. = ..()
	if(var_name == NAMEOF(src, job_path))
		Unregister()

/**
 * Used when there's no job specific latejoin spawnpoints
 */
/atom/movable/landmark/spawnpoint/latejoin
	name = "unknown latejoin spawnpoint"
	/// Faction
	var/faction

/atom/movable/landmark/spawnpoint/latejoin/Register()
	. = ..()
	if(!faction)
		return
	LAZYINITLIST(SSjob.latejoin_spawnpoints)
	LAZYINITLIST(SSjob.latejoin_spawnpoints[faction])
	AutoListRegister(SSjob.latejoin_spawnpoints[faction])

/atom/movable/landmark/spawnpoint/latejoin/Unregister()
	. = ..()
	if(!faction)
		return
	AutoListUnregister(SSjob.latejoin_spawnpoints[faction])

/atom/movable/landmark/spawnpoint/latejoin/vv_edit_var(var_name, var_value, massedit)
	if(var_name == NAMEOF(src, faction))
		Register()
	. = ..()
	if(var_name == NAMEOF(src, faction))
		Unregister()

/**
 * Used when all other spawnpoints are unavailable
 */
/atom/movable/landmark/spawnpoint/overflow
	name = "unknown overflow spawnpoint"
	/// Faction
	var/faction

/atom/movable/landmark/spawnpoint/overflow/Register()
	. = ..()
	if(!faction)
		return
	LAZYINITLIST(SSjob.overflow_spawnpoints)
	LAZYINITLIST(SSjob.overflow_spawnpoints[faction])
	AutoListRegister(SSjob.overflow_spawnpoints[faction])

/atom/movable/landmark/spawnpoint/overflow/Unregister()
	. = ..()
	if(!faction)
		return
	AutoListUnregister(SSjob.overflow_spawnpoints[faction])

/atom/movable/landmark/spawnpoint/overflow/vv_edit_var(var_name, var_value, massedit)
	if(var_name == NAMEOF(src, faction))
		Register()
	. = ..()
	if(var_name == NAMEOF(src, faction))
		Unregister()

/**
 * Custom keyed list spawnpoint supplier
 */
/atom/movable/landmark/spawnpoint/custom
	name = "unknown custom spawnpoint"
	/// Key
	var/key

/atom/movable/landmark/spawnpoint/custom/Register()
	. = ..()
	if(!key)
		return
	LAZYINITLIST(SSjob.custom_spawnpoints)
	LAZYINITLIST(SSjob.custom_spawnpoints[key])
	AutoListRegister(SSjob.custom_spawnpoints[key])

/atom/movable/landmark/spawnpoint/custom/Unregister()
	. = ..()
	if(!key)
		return
	AutoListUnregister(SSjob.custom_spawnpoints[key])

/atom/movable/landmark/spawnpoint/latejoin/vv_edit_var(var_name, var_value, massedit)
	if(var_name == NAMEOF(src, key))
		Register()
	. = ..()
	if(var_name == NAMEOF(src, key))
		Unregister()
