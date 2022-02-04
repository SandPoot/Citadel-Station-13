/atom/movable/landmark/spawnpoint/latejoin/station
	faction = JOB_FACTION_STATION

/atom/movable/landmark/spawnpoint/latejoin/station/arrivals_shuttle
	method = LATEJOIN_METHOD_ARRIVALS_SHUTTLE

/atom/movable/landmark/spawnpoint/latejoin/station/arrivals_shuttle/OnSpawn(mob/M, client/C)
	. = ..()
	var/obj/structure/chair/C = locate() in GetSpawnLoc()
	if(C && !length(C.buckled_mobs))
		C.buckle_mob(M, FALSE, FALSE)

/atom/movable/landmark/spawnpoint/overflow/station
	faction = JOB_FACTION_STATION
