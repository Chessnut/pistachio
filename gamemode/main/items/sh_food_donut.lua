local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Supreme Donut";
ITEM.uniqueID = "food_donut";
ITEM.weight = 0.5;
ITEM.model = "models/noesis/donut.mdl";
ITEM.description = "A huge pink frosted donut that causes diabetes.";
ITEM.price = 25;
ITEM.stockLimit = 5;
ITEM.staminaRestore = 25;

pistachio.item:Register(ITEM);