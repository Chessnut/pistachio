local ITEM = {};

ITEM.name = "Dye";
ITEM.weight = 1;
ITEM.uniqueID = "dye";
ITEM.model = "models/props_junk/metal_paintcan001a.mdl";
ITEM.description = "A can of colored dye used on fabric.";
ITEM.price = 750;
ITEM.stockLimit = 20;
ITEM.category = "Apparel";

function ITEM:OnUse(entity, client)
	net.Start("ps_ChangeShirt");
	net.Send(client);

	return false, false;
end;

pistachio.item:Register(ITEM);