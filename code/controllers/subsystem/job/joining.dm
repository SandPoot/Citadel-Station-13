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

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M.mind && M.mind.assigned_role && length(GLOB.jobspawn_overrides[M.mind.assigned_role])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.assigned_role])
		destination.JoinPlayerHere(M, FALSE)
		return

	if(latejoin_trackers.len)
		destination = pick(latejoin_trackers)
		destination.JoinPlayerHere(M, buckle)
		return

	//bad mojo
	var/area/shuttle/arrival/A = GLOB.areas_by_type[/area/shuttle/arrival]
	if(A)
		//first check if we can find a chair
		var/obj/structure/chair/C = locate() in A
		if(C)
			C.JoinPlayerHere(M, buckle)
			return

		//last hurrah
		var/list/avail = list()
		for(var/turf/T in A)
			if(!is_blocked_turf(T, TRUE))
				avail += T
		if(avail.len)
			destination = pick(avail)
			destination.JoinPlayerHere(M, FALSE)
			return

	//pick an open spot on arrivals and dump em
	var/list/arrivals_turfs = shuffle(get_area_turfs(/area/shuttle/arrival))
	if(arrivals_turfs.len)
		for(var/turf/T in arrivals_turfs)
			if(!is_blocked_turf(T, TRUE))
				T.JoinPlayerHere(M, FALSE)
				return
		//last chance, pick ANY spot on arrivals and dump em
		destination = arrivals_turfs[1]
		destination.JoinPlayerHere(M, FALSE)
	else
		var/msg = "Unable to send mob [M] to late join!"
		message_admins(msg)
		CRASH(msg)


/atom/proc/JoinPlayerHere(mob/M, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	M.forceMove(get_turf(src))

/obj/structure/chair/JoinPlayerHere(mob/M, buckle)
	// Placing a mob in a chair will attempt to buckle it, or else fall back to default.
	if (buckle && isliving(M) && buckle_mob(M, FALSE, FALSE))
		return
	..()

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0


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
