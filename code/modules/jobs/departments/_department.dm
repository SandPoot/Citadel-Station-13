/**
 * Department datums
 * Groups jobs by departments.
 */
/datum/department
	/// name
	var/name = "Unknown Department"
	/// IDs of the jobs in it. NOT references.
	var/list/jobs = list()
	/// SQL name for things like JEXP - defaults to name
	var/SQL_name = "DEFAULT"
	/// ID of the primary supervisor job. NOT reference to datum.
	var/supervisor
	/// Priority - higher = override lower
	var/priority = 0
	/// List in manifest?
	var/unlisted = FALSE
	/// List of channels to announce supervisor joins to
	var/list/supervisor_announce_channels

/datum/department/New()
	if(SQL_name == "DEFAULT")
		SQL_name = name

/datum/department/proc/GetJobs()
	. = list()
	for(var/path in jobs)
		. += SSjob.GetJobType(path)

/datum/department/proc/GetSupervisor()
	return supervisor && SSjob.GetJobType(supervisor)
