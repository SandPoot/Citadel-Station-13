/**
 * Department datums
 * Groups jobs by departments.
 */
/datum/department
	/// name
	var/name = "Unknown Department"
	/// IDs of the jobs in it. NOT references.
	var/list/jobs = list()
	/// SQL name for things like JEXP - null for no SQL capability/departmental JEXP
	var/SQL_name
	/// ID of the primary supervisor job. NOT reference to datum.
	var/supervisor
	/// Priority - higher = override lower
	var/priority = 0
	/// List in manifest?
	var/unlisted = FALSE
	/// List of channels to announce supervisor joins to
	var/list/supervisor_announce_channels
