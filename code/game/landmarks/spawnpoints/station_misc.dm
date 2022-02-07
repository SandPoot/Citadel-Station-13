/atom/movable/landmark/spawnpoint/latejoin/station
	faction = JOB_FACTION_STATION

/atom/movable/landmark/spawnpoint/latejoin/station/arrivals_shuttle
	method = LATEJOIN_METHOD_ARRIVALS_SHUTTLE

/atom/movable/landmark/spawnpoint/latejoin/station/arrivals_shuttle/OnSpawn(mob/M, client/C)
	. = ..()
	var/obj/structure/chair/C = locate() in GetSpawnLoc()
	if(C && !length(C.buckled_mobs))
		C.buckle_mob(M, FALSE, FALSE)
	if(SSshuttle.arrivals.mode == SHUTTLE_CALL)
		var/atom/movable/screen/splash/Spl = new(character.client, TRUE)
		Spl.Fade(TRUE)
		character.playsound_local(get_turf(character), 'sound/voice/ApproachingTG.ogg', 25)

/atom/movable/landmark/spawnpoint/overflow/station
	faction = JOB_FACTION_STATION
