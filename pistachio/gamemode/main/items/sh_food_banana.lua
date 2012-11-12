local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Banana";
ITEM.uniqueID = "food_banana";
ITEM.weight = 0.5;
ITEM.model = "models/props/cs_italy/bananna.mdl";
ITEM.description = "A yellow fruit that is in a shape of a curve.";
ITEM.price = 25;
ITEM.stockLimit = 15;
ITEM.restore = 10;

pistachio.item:Register(ITEM);