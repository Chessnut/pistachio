local ITEM = {};

ITEM.base = "base_alcohol";
ITEM.name = "Beer";
ITEM.uniqueID = "alcohol_beer";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/garbage_glassbottle001a.mdl";
ITEM.description = "A large glass bottle of beer.";
ITEM.price = 50;
ITEM.stockLimit = 10;
ITEM.drunkness = 0.3;
ITEM.damage = 5;

pistachio.item:Register(ITEM);