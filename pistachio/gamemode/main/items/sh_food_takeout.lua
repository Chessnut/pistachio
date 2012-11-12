local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Chinese Takeout";
ITEM.uniqueID = "food_takeout";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.description = "A paper container filled with Chinese food.";
ITEM.price = 10;
ITEM.stockLimit = 15;
ITEM.restore = 10;

pistachio.item:Register(ITEM);