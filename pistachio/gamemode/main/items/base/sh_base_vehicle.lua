local ITEM = {};

ITEM.isBase = true;
ITEM.weight = 0;
ITEM.baseID = "base_vehicle";
ITEM.category = "Vehicles";
ITEM.preventDrop = true;
ITEM.honk = "vu_horn_simple";

function ITEM:OnUse(entity, client)
	client:Notify( pistachio:CreateItemVehicle(client, self) );

	return false, false;
end;

function ITEM:LayoutEntity(entity)
	-- Override me.
end;

pistachio.item:Register(ITEM);