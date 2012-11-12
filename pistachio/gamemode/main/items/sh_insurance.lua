local ITEM = {};

ITEM.name = "Life Insurance";
ITEM.weight = 1;
ITEM.uniqueID = "insurance";
ITEM.model = "models/props_lab/clipboard.mdl";
ITEM.description = "A peice of paper that saves you from losing money.";
ITEM.price = 450;
ITEM.stockLimit = 10;
ITEM.preventUse = true;

pistachio.item:Register(ITEM);