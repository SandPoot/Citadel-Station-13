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
	var/static/list/department_by_type = list()
	/// departments by name
	var/static/list/department_by_name = list()
	/// alt titles to real titles lookup
	var/static/list/alt_title_lookup = list()

/datum/controller/subsystem/job/proc/SetupOccupations()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		CRASH("Couldn't setup any job datums.")
	jobs = list()
	departments = list()
	job_type_lookup = list()
	department_by_type = list()
	job_name_lookup = list()
	department_by_name = list()
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
	// instantiate departments
	var/list/departments_temporary = list()
	for(var/path in subtypesof(/datum/department))
		var/datum/department/D = new path
		departments += D
		departments_temporary
		department_by_type[path] = D
		department_by_name[D.name] = D
	// assign departments to jobs and vice versa
	sortTim(departments_temporary, /proc/cmp_department_priority_dsc, FALSE)
	for(var/datum/department/D as anything in departments_temporary)
		for(var/path in D.jobs)
			if(!ispath(path))
				stack_trace("[path] in [D.type] is not a typepath.")
				continue

		if(D.supervisor)
			if(!ispath(D.supervisor))
				stack_trace("[D.supervisor] in [D.type]'s supervisor is not a typepath.")
			else
				var/datum/job/J = job_type_lookup[D.supervisor]
				J.departments_supervised += D.type





	for(var/J in all_jobs)
		var/datum/job/job = new J()
		job.process_map_overrides(SSmapping.config)
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	return 1


