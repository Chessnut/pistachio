local ITEM = {};

ITEM.base = "base_alcohol";
ITEM.name = "Brandy";
ITEM.uniqueID = "alcohol_brandy";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.description = "A bottle of brandy.";
ITEM.price = 35;
ITEM.stockLimit = 10;
ITEM.drunkness = 0.25;
ITEM.damage = 8;

pistachio.item:Register(ITEM);