local ITEM = {};

ITEM.base = "base_alcohol";
ITEM.name = "Rum";
ITEM.uniqueID = "alcohol_rum";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/glassjug01.mdl";
ITEM.description = "A clear jug of rum.";
ITEM.price = 60;
ITEM.stockLimit = 10;
ITEM.drunkness = 0.3;
ITEM.damage = 8;

pistachio.item:Register(ITEM);