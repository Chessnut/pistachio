local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Beans";
ITEM.uniqueID = "food_beans";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl";
ITEM.description = "Mysterious beans in a tin can";
ITEM.price = 25;
ITEM.stockLimit = 15;
ITEM.restore = 15;

pistachio.item:Register(ITEM);