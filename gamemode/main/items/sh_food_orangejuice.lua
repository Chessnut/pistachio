local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Orange Juice";
ITEM.uniqueID = "food_orange_juice";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/garbage_plasticbottle003a.mdl";
ITEM.description = "A bottle of orange juice.";
ITEM.price = 25;
ITEM.stockLimit = 15;
ITEM.staminaRestore = 10;

pistachio.item:Register(ITEM);