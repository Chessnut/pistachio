local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Put Shoe on Head";
ITEM.uniqueID = "hat_shoe";
ITEM.model = "models/props_junk/Shoe001a.mdl";
ITEM.description = "Remember that thing back in 2006?";
ITEM.price = 500;
ITEM.offset = {0.5, 10, 0.5};
ITEM.rotation = {90, 180, 0};

pistachio.item:Register(ITEM);