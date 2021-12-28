/datum/controller/subsystem/job
	// Job datum management
	// You'll note that I used static
	// This means that Recover() isn't needed to recover them.
	// But.
	// If things break horribly, this also means there's no way to automatically fix things
	// SHOULD anyone ever fuck up the round so badly we need a Recover(), feel free to yell at me.
	// All the Recover() would need to do is for(job in world) to recover state variables, and then manually recreate everything.
	/// all instantiated job datums
	var/static/list/datum/job/jobs = list()
	/// all instantiated department datums,
	var/static/list/datum/department/departments = list()
	/// job datums by type
	var/static/list/job_type_lookup = list()
	/// job datums by priamry name
	var/static/list/job_name_lookup = list()
	/// departments by type
	var/static/list/department_type_lookup = list()
	/// departments by name
	var/static/list/department_name_lookup = list()
	/// alt titles to real titles lookup
	var/static/list/alt_title_lookup = list()
	/// job types in departments
	var/static/list/job_types_in_department = list()
	/// job names in departments
	var/static/list/job_names_in_department = list()

/datum/controller/subsystem/job/proc/SetupOccupations()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		CRASH("Couldn't setup any job datums.")
	jobs = list()
	departments = list()
	job_type_lookup = list()
	department_type_lookup = list()
	job_name_lookup = list()
	department_name_lookup = list()
	alt_title_lookup = list()
	// instantiate jobs
	for(var/path in subtypesof(/datum/job))
		var/datum/job/J = path
		if(initial(J.abstract_type) == path)
			continue
		J = new J
		if(!job.config_check())
			continue
		if(!J.ProcessMap(SSmapping.config))
			continue
		jobs += J
		job_type_lookup[path] = J
		job_name_lookup[J.name] = J
		J.departments = list()
		J.departments_supervised = list()
		for(var/apath in J.alt_titles)
			if(!ispath(apath, /datum/alt_title))
				stack_trace("[apath] on [path] is not a valid alt title path.")
				continue
			var/datum/alt_title/title = apath
			alt_title_lookup[initial(title.name)] = J.name
	// instantiate departments
	var/list/departments_temporary = list()
	for(var/path in subtypesof(/datum/department))
		var/datum/department/D = new path
		departments += D
		departments_temporary
		department_type_lookup[path] = D
		department_name_lookup[D.name] = D
	// assign departments to jobs and vice versa
	sortTim(departments_temporary, /proc/cmp_department_priority_dsc, FALSE)
	for(var/datum/department/D as anything in departments_temporary)
		for(var/path in D.jobs)
			if(!ispath(path))
				stack_trace("[path] in [D.type] is not a typepath.")
				continue
			var/datum/job/J = job_type_lookup[path]
			J.departments += D.type
			LAZYOR(job_types_in_department[D.type], J.type)
			LAZYOR(job_names_in_department[D.type], J.name)
		if(D.supervisor)
			if(!ispath(D.supervisor))
				stack_trace("[D.supervisor] in [D.type]'s supervisor is not a typepath.")
			else
				var/datum/job/J = job_type_lookup[D.supervisor]
				J.departments_supervised += D.type
	return TRUE

/datum/controller/subsystem/job/proc/GetJobType(path)
	RETURN_TYPE(/datum/job)
	if(!job_type_lookup[path])
		CRASH("Failed to fetch job path: [path]")
	return job_type_lookup[path]

/datum/controller/subsystem/job/proc/GetJobName(name)
	RETURN_TYPE(/datum/job)
	if(!job_name_lookup[name])
		CRASH("Failed to fetch job name: [name]")
	return job_name_lookup[name]

/datum/controller/subsystem/job/proc/GetDepartmentType(Path)
	RETURN_TYPE(/datum/department)
	if(!department_type_lookup[name])
		CRASH("Failed to fetch department path: [name]")
	return department_path_lookup[name]

/datum/controller/subsystem/job/proc/GetDepartmentName(name)
	RETURN_TYPE(/datum/department)
	if(!department_name_lookup[name])
		CRASH("Failed to fetch department name: [name]")
	return department_name_lookup[name]

/datum/controller/subsystem/job/proc/GetDepartmentMinds(path, list/mob_typecache_filter)
	RETURN_TYPE(/datum/mind)
	. = list()
	var/datum/department/D = ispath(path)? GetDepartmentType(path) : GetDepartmentName(path)
	if(!D)
		CRASH("Failed to fetch department [path].")
	for(var/mob/M as anything in GLOB.mob_list)
		if(mob_typecache_filter && !mob_typecache_filter[M.type])
			continue
		if(M.mind?.assigned_role in job_names_in_department[D.type])
			. += M.mind

/datum/controller/subsystem/job/proc/GetLivingDepartmentMinds(path, list/mob_typecache_filter)
	RETURN_TYPE(/datum/mind)
	. = list()
	var/datum/department/D = ispath(path)? GetDepartmentType(path) : GetDepartmentName(path)
	if(!D)
		CRASH("Failed to fetch department [path].")
	for(var/mob/M as anything in GLOB.alive_mob_list)
		if(mob_typecache_filter && !mob_typecache_filter[M.type])
			continue
		if(M.mind?.assigned_role in job_names_in_department[D.type])
			. += M.mind

/datum/controller/subsystem/job/proc/GetJobMinds(path, list/mob_typecache_filter)
	RETURN_TYPE(/datum/mind)
	. = list()
	var/datum/job/J = ispath(path)? GetJobType(path) : GetJobName(path)
	if(!J)
		CRASH("Failed to fetch job [path].")
	for(var/mob/M as anything in GLOB.mob_list)
		if(mob_typecache_filter && !mob_typecache_filter[M.type])
			continue
		if(M.mind?.assigned_role == J.name)
			. += M.mind

/datum/controller/subsystem/job/proc/GetLivingJobMinds(path, list/mob_typecache_filter)
	RETURN_TYPE(/datum/mind)
	. = list()
	var/datum/job/J = ispath(path)? GetJobType(path) : GetJobName(path)
	if(!J)
		CRASH("Failed to fetch job [path].")
	for(var/mob/M as anything in GLOB.alive_mob_list)
		if(mob_typecache_filter && !mob_typecache_filter[M.type])
			continue
		if(M.mind?.assigned_role == J.name)
			. += M.mind

/**
 * Frees a slot
 *
 * Can enter either a path or name.
 */
/datum/controller/subsystem/job/proc/FreeRole(path)
	var/datum/job/J = ispath(path)? GetJobType(path) : GetJobName(path)
	if(!J)
		CRASH("Failed to fetch job [path].")
	J.current_positions = max(0, J.current_positions - 1)
