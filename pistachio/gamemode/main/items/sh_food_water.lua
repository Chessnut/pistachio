local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Water";
ITEM.uniqueID = "food_water";
ITEM.weight = 0.25;
ITEM.model = "models/props/cs_office/Water_bottle.mdl";
ITEM.description = "A plastic water bottle containing H2O.";
ITEM.price = 50;
ITEM.stockLimit = 20;
ITEM.restore = 5;
ITEM.staminaRestore = 10;

pistachio.item:Register(ITEM);