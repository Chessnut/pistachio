--[[
	Seats can be added with:
		ITEM.seats = {
			{offset = <vector>, rotation = <angle>, exit = <vector>}
		}

		exit is optional.
--]]

local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Buggy";
ITEM.uniqueID = "vehicle_buggy";
ITEM.model = "models/buggy.mdl";
ITEM.description = "A red colored dune buggy that seems used.";
ITEM.price = 8500;
ITEM.vehicleScript = "jeep_test";

pistachio.item:Register(ITEM);