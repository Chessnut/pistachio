local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Cinderblock";
ITEM.uniqueID = "hat_block";
ITEM.model = "models/props_junk/CinderBlock01a.mdl";
ITEM.description = "A block of concrete.";
ITEM.offset = {0.5, 15.5, 0.5};
ITEM.rotation = {90, 180, 90};

pistachio.item:Register(ITEM);