/atom/movable/spawnpoint/latejoin/station
	faction = JOB_FACTION_STATION

/atom/movable/spawnpoint/latejoin/station/arrivals_shuttle
	method = LATEJOIN_METHOD_ARRIVALS_SHUTTLE

/atom/movable/spawnpoint/latejoin/station/arrivals_shuttle/OnSpawn(mob/M, client/C)
	. = ..()
	var/obj/structure/chair/C = locate() in GetSpawnLoc()
	if(C && !length(C.buckled_mobs))
		C.buckle_mob(M, TRUE, FALSE)

/atom/movable/spawnpoint/overflow/station
	faction = JOB_FACTION_STATION
