/datum/controller/subsystem/job/proc/EquipRoundstart(mob/M, datum/job/J, loadout = TRUE, client/C)

/datum/controller/subsystem/job/proc/EquipLatejoin(mob/M, datum/job/J, loadout = TRUE, client/C)

/datum/controller/subsystem/job/proc/EquipPlayer(mob/M, datum/job/J, loadout = TRUE, datum/preferences/prefs)




/datum/controller/subsystem/job/proc/PostJoin(mob/M)

/**
 * Assigns a player to a role.
 * @params
 * - M - mind or mob
 * - J - job , job title, or job type
 * - latejoin - latejoining mob?
 * - force - bypass checks
 */
/datum/controller/subsystem/job/proc/Assign(datum/mind/M, datum/job/J, latejoin = FALSE, force = FALSE)
	if(ismob(M))
		var/mob/_M = M
		M = _M.mind
	if(!istype(M))
		CRASH("Invalid mind.")
	if(!istype(J))
		J = GetJobAuto(J)
	if(!istype(J))
		CRASH("Invalid job.")
	JobDebug("ASSIGN: [M], [J], latejoin: [latejoin]")
	if(!force && !CanAssign(M, J, latejoin))
		JobDebug("ASSIGN: Failed CanAssign")
		return FALSE
	JobDebug("ASSIGN: Passed: JCP: [J.current_positions] (incremented)")
	M.assigned_role = J.title
	// hook into roundstart system so it doesn't have to call this manually
	if(unassigned)
		unassigned -= M.current
	J.current_positions++
	return TRUE

/datum/controller/subsystem/job/proc/CanAssign(M, datum/job/J, latejoin)
	var/mob/checking = ismob(M) && M
	if(!checking)
		if(istype(M, /datum/mind))
			var/datum/mind/_M = M
			checking = _M.current
		if(istype(M, /client))
			var/client/_C = M
			checking = _C.mob
	. = FALSE
	if(!checking)
		CRASH("No mob")
	if(!istype(J))
		CRASH("No job")
	if(jobban_isbanned(checking, J.title))
		return FALSE
	if(!J.player_old_enough(checking.client))
		return FALSE
	if(J.required_playtime_remaining(checking.client))
		return FALSE
	var/position_limit = latejoin? job.total_positions : job.roundstart_positions
	if(job.current_positions + 1 > position_limit)
		return FALSE
	return TRUE

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/M, rank, joined_late = FALSE)
	var/mob/dead/new_player/N
	var/mob/living/H
	if(!joined_late)
		N = M
		H = N.new_character
	else
		H = M

	var/datum/job/job = GetJobName(rank)

	H.job = rank

	//If we joined at roundstart we should be positioned at our workstation
	if(!joined_late)
		var/atom/movable/landmark/spawnpoint/S = GetRoundstartSpawnpoint(H, H.client || N.client, job.type, job.faction)
		if(!S)
			stack_trace("Couldn't find a roundstart spawnpoint for [H] ([H.client || N.client]) - [job.type] ([job.faction]).")
			SendToLateJoin(H)
		else
			var/atom/A = S.GetSpawnLoc()
			H.forceMove(A)
			S.OnSpawn(H, H.client || N.client)

	if(H.mind)
		H.mind.assigned_role = rank

	if(job)
		if(!job.dresscodecompliant)// CIT CHANGE - dress code compliance
			equip_loadout(N, H) // CIT CHANGE - allows players to spawn with loadout items
		var/new_mob = job.equip(H, null, null, joined_late , null, M.client)
		if(ismob(new_mob))
			H = new_mob
			if(!joined_late)
				N.new_character = H
			else
				M = H

		SSpersistence.antag_rep_change[M.client.ckey] += job.GetAntagRep()

/*		if(M.client.holder)
			if(CONFIG_GET(flag/auto_deadmin_players) || (M.client.prefs?.toggles & DEADMIN_ALWAYS))
				M.client.holder.auto_deadmin()
			else
				handle_auto_deadmin_roles(M.client, rank) */

	to_chat(M, "<b>You are the [rank].</b>")
	if(job)
		to_chat(M, "<b>As the [rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
		job.radio_help_message(M)
		if(job.req_admin_notify)
			to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect immediately, please notify the admins via adminhelp. Otherwise put your locker gear back into the locker and cryo out.</b>")
		if(job.custom_spawn_text)
			to_chat(M, "<b>[job.custom_spawn_text]</b>")
		if(CONFIG_GET(number/minimal_access_threshold))
			to_chat(M, "<span class='notice'><B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B></span>")
	if(ishuman(H))
		var/mob/living/carbon/human/wageslave = H
		to_chat(M, "<b><span class = 'big'>Your account ID is [wageslave.account_id].</span></b>")
		H.add_memory("Your account ID is [wageslave.account_id].")
	if(job && H)
		if(job.dresscodecompliant)// CIT CHANGE - dress code compliance
			equip_loadout(N, H) // CIT CHANGE - allows players to spawn with loadout items
		job.after_spawn(H, M, joined_late) // note: this happens before the mob has a key! M will always have a client, H might not.
		equip_loadout(N, H, TRUE)//CIT CHANGE - makes players spawn with in-backpack loadout items properly. A little hacky but it works

	var/list/tcg_cards
	if(ishuman(H))
		if(length(H.client?.prefs?.tcg_cards))
			tcg_cards = H.client.prefs.tcg_cards
		else if(length(N?.client?.prefs?.tcg_cards))
			tcg_cards = N.client.prefs.tcg_cards
	if(tcg_cards)
		var/obj/item/tcgcard_binder/binder = new(get_turf(H))
		H.equip_to_slot_if_possible(binder, SLOT_IN_BACKPACK, disable_warning = TRUE, bypass_equip_delay_self = TRUE)
		for(var/card_type in N.client.prefs.tcg_cards)
			if(card_type)
				if(islist(H.client.prefs.tcg_cards[card_type]))
					for(var/duplicate in N.client.prefs.tcg_cards[card_type])
						var/obj/item/tcg_card/card = new(get_turf(H), card_type, duplicate)
						card.forceMove(binder)
						binder.cards.Add(card)
				else
					var/obj/item/tcg_card/card = new(get_turf(H), card_type, N.client.prefs.tcg_cards[card_type])
					card.forceMove(binder)
					binder.cards.Add(card)
		binder.check_for_exodia()
		if(length(N.client.prefs.tcg_decks))
			binder.decks = N.client.prefs.tcg_decks

	return H

/**
 * Sends a mob to a spawnpoint. Set override = TRUE to disable auto-detect of job.
 */
/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, client/C = M.client, faction, job, method, override)
	if(!override && M.mind?.assigned_role)
		var/datum/job/J = SSjob.GetJobName(M.mind.assigned_role)
		if(J)
			faction = J.faction
			job = J.GetID()

	var/atom/movable/landmark/spawnpoint/S

	S = SSjob.GetLatejoinSpawnpoint(C, job, faction, method)

	if(S)
		M.forceMove(S.GetSpawnLoc())
		S.OnSpawn(M, C)

	var/error_message = "Unable to send [key_name(M)] to latejoin."
	message_admins(error_message)
	subsystem_log(error_message)
	CRASH(error_message)		// this is serious.

/*
/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = GetJobName(rank)
	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && (CONFIG_GET(flag/auto_deadmin_heads) || (C.prefs?.toggles & DEADMIN_POSITION_HEAD)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SECURITY) && (CONFIG_GET(flag/auto_deadmin_security) || (C.prefs?.toggles & DEADMIN_POSITION_SECURITY)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SILICON) && (CONFIG_GET(flag/auto_deadmin_silicons) || (C.prefs?.toggles & DEADMIN_POSITION_SILICON))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()*/
