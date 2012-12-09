local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Potato";
ITEM.uniqueID = "food_potato";
ITEM.weight = 0.5;
ITEM.model = "models/props_phx/misc/potato.mdl";
ITEM.description = "A large thing of starch.";
ITEM.price = 15;
ITEM.stockLimit = 15;
ITEM.restore = 15;

pistachio.item:Register(ITEM);