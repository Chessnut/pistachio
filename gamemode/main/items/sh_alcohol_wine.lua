local ITEM = {};

ITEM.base = "base_alcohol";
ITEM.name = "Wine";
ITEM.uniqueID = "alcohol_wine";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/GlassBottle01a.mdl";
ITEM.description = "A bottle of red wine.";
ITEM.price = 65;
ITEM.stockLimit = 10;
ITEM.drunkness = 0.4;
ITEM.damage = 10;

pistachio.item:Register(ITEM);