/datum/controller/subsystem/job
	/// Job spawnpoints keyed to job id/typepath
	var/list/job_spawnpoints
	/// Generic latejoin spawnpoints, nested list faction = list()
	var/list/latejoin_spawnpoints
	/// Generic overflow spawnpoints, nested list faction = list()
	var/list/overflow_spawnpoints
	/// Custom spawnpoints, nested list key = list()
	var/list/custom_spawnpoints

/**
 * Fully resets spawnpoints list and ensures validity
 */
/datum/controller/subsystem/job/proc/ReconstructSpawnpoint()
	job_spawnpoints = list()
	latejoin_spawnpoints = list()
	overflow_spawnpoints = list()
	custom_spawnpoints = list()
	for(var/atom/movable/landmark/spawnpoint/job/S in GLOB.landmarks_list)
		if(!S.job_path)
			continue
		LAZYOR(job_spawnpoints[S.job_path], S)
	for(var/atom/movable/landmark/spawnpoint/latejoin/S in GLOB.landmarks_list)
		if(!S.faction)
			continue
		LAZYOR(latejoin_spawnpoints[S.faction], S)
	for(var/atom/movable/landmark/spawnpoint/overflow/S in GLOB.landmarks_list)
		if(!S.faction)
			continue
		LAZYOR(latejoin_spawnpoints[S.faction], S)
	for(var/atom/movable/landmark/spawnpoint/custom/S in GLOB.landmarks_list)
		if(!S.key)
			continue
		LAZYOR(custom_spawnpoints[S.key], S)

/**
 * Gets a valid spawnpoint to use
 *
 * This is not a random pick, this is first priority-availability first server and fully deterministic.
 *
 * @params
 * - M - the mob being spawned
 * - job_path - path to job
 * - roundstart - is it roundstart or latejoin
 * - faction - what faction the player is in terms of job factions
 */
/datum/controller/subsystem/job/proc/GetJobSpawnpoint(mob/M, job_path, roundstart, faction)
	if(!ispath(job_path, /datum/job))
		CRASH("Invalid job path [job_path]")
	// Priority 1: Job specific spawnpoints
	if(length(job_spawnpoints[job_path]))
		for(var/atom/movable/landmark/spawnpoint/job/J as anything in job_spawnpoints[job_path])
			if((roundstart && !J.roundstart) || (!roundstart && !J.latejoin)
				continue
			if(J.Available(M))
				continue
			return J
	// Priority 2: Latejoin spawnpoints, if latejoin
	if(!roundstart && length(latejoin_spawnpoints[faction]))
		for(var/atom/movable/landmark/spawnpoint/latejoin/S as anything in latejoin_spawnpoints[faction])
			if(!S.Available(M))
				continue
			return S
	// Priority 3: OVerflow spawnpoints as a last resort
	if(length(overflow_spawnpoints[faction]))
		for(var/atom/movable/landmark/spawnpoint/overflow/S as anything in overflow_spawnpoints[faction])
			if(!S.Available(M))
				continue
			return S

/**
 * Gets a valid custom spawnpoint to use by key
 */
/datum/controller/subsystem/job/proc/GetCustomSpawnpoint(mob/M, key)
	if(!length(custom_spawnpoints[key]))
		return
	for(var/atom/movable/landmark/spawnpoint/S as anything in custom_spawnpoints[key])
		if(!S.Available(M))
			continue
		return S
