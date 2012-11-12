local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Club Soda";
ITEM.uniqueID = "food_club_soda";
ITEM.weight = 0.5;
ITEM.model = "models/props_junk/PopCan01a.mdl";
ITEM.description = "An aluminum can filled with carbonated water.";
ITEM.price = 20;
ITEM.stockLimit = 15;
ITEM.restore = 20;

pistachio.item:Register(ITEM);