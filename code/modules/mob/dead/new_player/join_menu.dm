GLOBAL_DATUM_INIT(join_menu, /datum/join_menu, new)

/**
 * Global singleton for holding TGUI data for players joining.
 */
/datum/join_menu

/datum/join_menu/proc/queue_update()
	addtimer(CALLBACK(src, /datum/proc/update_static_data), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/join_menu/ui_static_data(mob/user)
	. = ..()

/datum/join_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(href_list["late_join"])
		if(!SSticker || !SSticker.IsRoundInProgress())
			to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
			return

		if(href_list["late_join"] == "override")
			LateChoices()
			return

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
			return
		LateChoices()


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
