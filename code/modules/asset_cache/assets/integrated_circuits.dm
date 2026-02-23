/datum/asset/spritesheet/integrated_circuits
	name = "integrated_circuits"

/datum/asset/spritesheet/integrated_circuits/register()
	for(var/category in SScircuit.circuit_fabricator_recipe_list)
		for(var/obj/item/item as anything in SScircuit.circuit_fabricator_recipe_list[category])
			var/icon/icon = icon(initial(item.icon), initial(item.icon_state))
			var/item_id = replacetext("[item]", "/", "-")
			Insert(item_id, icon)
	return ..()
