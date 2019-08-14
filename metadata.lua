return PlaceObj('ModDef', {
	'title', "Indoor drone hub",
	'description', "An indoor drone hub, currently uses the sensor tower model.\n\nCosts less metal as it doesn't need to be built to withstand the outdoors.\n\nService radius is centered on the parent dome, rather than on the drone hub itself.\n\nDoesn't include recharge stations, but also costs 2.6 (3 - (0.2 * 2)) electricity to run, discounted by exactly the cost of running two recharge stations.\n\nCan be built from a standard drone hub prefab, in which case it returns 4 Metals, and 2 recharge station prefabs on construction.\n\nPermission is granted to update this mod to support the latest version of the game if I'm not around to do it myself.",
	'last_changes', "Park drones inside in order to prevent them from roaming all over the map.",
	'id', "ZWIkDyT",
	'steam_id', "1820343200",
	'pops_desktop_uuid', "6a5c9ef5-60f8-4caa-8715-7932776e9925",
	'pops_any_uuid', "74f514ba-35b8-4877-b0f1-2a21c216d667",
	'author', "mrudat",
	'version_minor', 2,
	'version', 20,
	'lua_revision', 233360,
	'saved_with_revision', 245618,
	'code', {
		"Code/IndoorDroneHub.lua",
	},
	'saved', 1565306493,
	'TagBuildings', true,
})