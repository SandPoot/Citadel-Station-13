GLOBAL_DATUM_INIT(join_menu, /datum/join_menu, new)

/**
 * Global singleton for holding TGUI data for players joining.
 */
/datum/join_menu

/datum/join_menu/proc/queue_update()
	addtimer(CALLBACK(src, /datum/proc/update_static_data), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/join_menu/ui_state(mob/user)
	return GLOB.new_player_state

/datum/join_menu/ui_static_data(mob/user)
	. = ..()

/datum/join_menu/ui_data(mob/user)
	. = ..()
	var/level = "green"
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			level = "green"
		if(SEC_LEVEL_BLUE)
			level = "blue"
		if(SEC_LEVEL_AMBER)
			level = "amber"
		if(SEC_LEVEL_RED)
			level = "red"
		if(SEC_LEVEL_DELTA)
			level = "delta"
	.["security_level"] = level
	.["duration"] = DisplayTimeText(world.time - SSticker.round_start_time)
	// 0 = not evaccing, 1 = evacuating, 2 = evacuated
	var/evac = 0
	switch(SSshuttle.emergency?.mode)
		if(SHUTTLE_ESCAPE)
			evac = 2
		if(SHUTTLE_CALL)
			evac = 1
	.["evacuated"] = evac
	.["charname"] = client ? client.prefs.real_name : "Unknown User"
	// position in queue, -1 for not queued, null for no queue active, otherwise number
	.["queue"] = null


/datum/join_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("join")
			if(!SSticker || !SSticker.IsRoundInProgress())
				to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
				return
			if(!CheckQueue())
				return FALSE
			switch(params["jobtype"])
				if("job")

				if("ghostrole")
		if("queue")
			CheckQueue()

/datum/join_menu/proc/CheckQueue()
	if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in GLOB.admin_datums)))
		to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")
		var/queue_position = SSticker.queued_players.Find(usr)
		if(queue_position == 1)
			to_chat(usr, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
		else if(queue_position)
			to_chat(usr, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
		else
			SSticker.queued_players += usr
			to_chat(usr, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")

/datum/join_menu/proc/CheckPopulation()
	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)


	if(href_list["SelectedJob"])
		if(!SSticker || !SSticker.IsRoundInProgress())
			var/msg = "[key_name(usr)] attempted to join the round using a href that shouldn't be available at this moment!"
			log_admin(msg)
			message_admins(msg)
			to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
			return

		if(!GLOB.enter_allowed)
			to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
			return

		if(SSticker.queued_players.len && !(ckey(key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, "<span class='warning'>Server is full.</span>")
				return

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(href_list["JoinAsGhostRole"])
		if(!GLOB.enter_allowed)
			to_chat(usr, "<span class='notice'> There is an administrative lock on entering the game!</span>")

		if(SSticker.queued_players.len && !(ckey(key) in GLOB.admin_datums))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, "<span class='warning'>Server is full.</span>")
				return

		var/obj/effect/mob_spawn/MS = pick(GLOB.mob_spawners[href_list["JoinAsGhostRole"]])
		if(MS.attack_ghost(src, latejoinercalling = TRUE))
			SSticker.queued_players -= src
			SSticker.queue_delay = 4
			qdel(src)

	else if(!href_list["late_join"])
		new_player_panel()


/mob/dead/new_player/proc/LateChoices()


	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job
	dat += "<center><table><tr><td valign='top'>"
	var/column_counter = 0
	var/free_space = 0
	for(var/list/category in list(GLOB.command_positions) + list(GLOB.supply_positions) + list(GLOB.engineering_positions) + list(GLOB.nonhuman_positions - "pAI") + list(GLOB.civilian_positions) + list(GLOB.medical_positions) + list(GLOB.science_positions) + list(GLOB.security_positions))
		var/cat_color = "fff" //random default
		cat_color = SSjob.name_occupations[category[1]].selection_color //use the color of the first job in the category (the department head) as the category color
		dat += "<fieldset style='width: 185px; border: 2px solid [cat_color]; display: inline'>"
		dat += "<legend align='center' style='color: [cat_color]'>[SSjob.name_occupations[category[1]].exp_type_department]</legend>"

		var/list/dept_dat = list()
		for(var/job in category)
			var/datum/job/job_datum = SSjob.name_occupations[job]
			if(job_datum && IsJobUnavailable(job_datum.title, TRUE) == JOB_AVAILABLE)
				var/command_bold = ""
				if(job in GLOB.command_positions)
					command_bold = " command"
				if(job_datum in SSjob.prioritized_jobs)
					dept_dat += "<a class='job[command_bold]' style='display:block;width:170px'  href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'><span class='priority'>[job_datum.title] ([job_datum.current_positions])</span></a>"
				else
					dept_dat += "<a class='job[command_bold]' style='display:block;width:170px' href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'>[job_datum.title] ([job_datum.current_positions])</a>"
		if(!dept_dat.len)
			dept_dat += "<span class='nopositions'>No positions open.</span>"
		dat += jointext(dept_dat, "")
		dat += "</fieldset><br>"
		column_counter++
		if(free_space <=4)
			free_space++
			if(column_counter > 0 && (column_counter % 3 == 0))
				dat += "</td><td valign='top'>"
		if(free_space >= 5 && (free_space % 5 == 0) && (column_counter % 3 != 0))
			free_space = 0
			column_counter = 0
			dat += "</td><td valign='top'>"

	dat += "</td></tr></table></center></center>"

	var/available_ghosts = 0
	for(var/spawner in GLOB.mob_spawners)
		if(!LAZYLEN(spawner))
			continue
		var/obj/effect/mob_spawn/S = pick(GLOB.mob_spawners[spawner])
		if(!istype(S) || !S.can_latejoin())
			continue
		available_ghosts++
		break

	if(!available_ghosts)
		dat += "<div class='notice red'>There are currently no open ghost spawners.</div>"
	else
		var/list/categorizedJobs = list("Ghost Role" = list(jobs = list(), titles = GLOB.mob_spawners, color = "#ffffff"))
		for(var/spawner in GLOB.mob_spawners)
			if(!LAZYLEN(spawner))
				continue
			var/obj/effect/mob_spawn/S = pick(GLOB.mob_spawners[spawner])
			if(!istype(S) || !S.can_latejoin())
				continue
			categorizedJobs["Ghost Role"]["jobs"] += spawner

		dat += "<center><table><tr><td valign='top'>"
		for(var/jobcat in categorizedJobs)
			if(!length(categorizedJobs[jobcat]["jobs"]))
				continue
			var/color = categorizedJobs[jobcat]["color"]
			dat += "<fieldset style='border: 2px solid [color]; display: inline'>"
			dat += "<legend align='center' style='color: [color]'>[jobcat]</legend>"
			for(var/spawner in categorizedJobs[jobcat]["jobs"])
				dat += "<a class='otherPosition' style='display:block;width:170px' href='byond://?src=[REF(src)];JoinAsGhostRole=[spawner]'>[spawner]</a>"

			dat += "</fieldset><br>"
		dat += "</td></tr></table></center>"
		dat += "</div></div>"

	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 720, 600)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE) // FALSE is passed to open so that it doesn't use the onclose() proc
