/**
 * Default implementation for ghost role spawners
 */
/obj/structure/ghost_role_spawner
	name = "Ghost Role Spawner"
	desc = "if you're seeing this a coder fucked up"
	resistance_flags = INDESTRUCTIBLE

	/// automatic handling - role type
	var/role_type
	/// automatic handling - allowed spawn count
	var/role_spawns = 1
	/// automatic handling - params. If this is a string at Init, it'll be json_decoded.
	var/list/role_params
	/// automatic handling - qdel on running out
	var/qdel_on_deplete = FALSE

/obj/structure/ghost_role_spawner/Initialize(mapload, params, spawns)
	. = ..()
	if(params)
		role_params = params
	else if(istext(role_params))
		role_params = json_decode(role_params)
	if(spawns)
		role_spawns = spawns
	AddComponent(/datum/component/ghostrole_spawnpoint, role_type, role_spawns, role_params, /obj/structure/ghost_role_spawner/proc/on_spawn)

/obj/structure/ghost_role_spawner/proc/on_spawn(mob/created, datum/ghostrole/role, list/params, datum/component/ghostrole_spawnpoint/spawnpoint)
	if(qdel_on_deplete && !spawnpoint.SpawnsLeft())
		qdel(src)
