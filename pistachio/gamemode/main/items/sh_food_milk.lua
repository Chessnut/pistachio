local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Milk";
ITEM.uniqueID = "food_milk";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl";
ITEM.description = "A whole gallon of milk.";
ITEM.price = 30;
ITEM.stockLimit = 15;
ITEM.staminaRestore = 15;

pistachio.item:Register(ITEM);