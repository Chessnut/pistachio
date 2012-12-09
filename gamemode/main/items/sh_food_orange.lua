local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Orange";
ITEM.uniqueID = "food_orange";
ITEM.weight = 0.25;
ITEM.model = "models/props/cs_italy/orange.mdl";
ITEM.description = "A small orange fruit.";
ITEM.price = 25;
ITEM.stockLimit = 20;
ITEM.restore = 5;

pistachio.item:Register(ITEM);