local ITEM = {};

ITEM.isBase = true;
ITEM.weight = 0;
ITEM.baseID = "base_vehicle";
ITEM.category = "Vehicles";
ITEM.preventDrop = true;
ITEM.honk = "vu_horn_simple";

function ITEM:OnUse(entity, client)
	if (self.vehicleScript) then
		local content = file.Read("scripts/vehicles/"..self.vehicleScript..".txt", "GAME");

		if (!content or content == "") then
			MsgC(Color(255, 0, 0, 255), "[Pistachio] Invalid vehiclescript for '"..self.uniqueID.."' ("..self.vehiclescript..")\n");

			return;
		end;
	else
		MsgC(Color(255, 0, 0, 255), "[Pistachio] Missing vehiclescript for '"..self.uniqueID.."'\n");

		return;
	end;

	client:Notify( pistachio:CreateItemVehicle(client, self) );

	return false, false;
end;

function ITEM:LayoutEntity(entity)
	-- Override me.
end;

pistachio.item:Register(ITEM);