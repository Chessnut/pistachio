local ITEM = {};

ITEM.name = "Paper";
ITEM.weight = 0.05;
ITEM.uniqueID = "paper";
ITEM.model = "models/props_c17/paper01.mdl";
ITEM.description = "Paper you can write on.";
ITEM.preventUse = true;
ITEM.price = 25;
ITEM.stockLimit = 25;
ITEM.category = "Miscellaneous";

pistachio.item:Register(ITEM);