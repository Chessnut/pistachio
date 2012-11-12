local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Big Slam";
ITEM.uniqueID = "food_bigslam";
ITEM.weight = 0.3;
ITEM.model = "models/props/cs_office/trash_can_p8.mdl";
ITEM.description = "A green can filled with bright green liquid.";
ITEM.price = 75;
ITEM.stockLimit = 10;
ITEM.staminaRestore = 25;

pistachio.item:Register(ITEM);