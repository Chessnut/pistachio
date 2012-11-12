local ITEM = {};

ITEM.isBase = true;
ITEM.baseID = "base_weapon";
ITEM.stockLimit = 10;
ITEM.category = "Weapons";
ITEM.weight = 1;

function ITEM:OnUse(entity, client)
	if ( client:HasWeapon(self.uniqueID) ) then
		client:Notify("You already have this weapon equipped!");

		return false;
	else
		client:Give(self.uniqueID);
	end;
end;

pistachio.item:Register(ITEM);