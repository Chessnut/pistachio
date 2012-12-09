local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Tester's Hat";
ITEM.uniqueID = "hat_tester";
ITEM.model = "models/props_junk/CinderBlock01a.mdl";
ITEM.description = "A brick you can wear.";
ITEM.preventBuy = true;
ITEM.offset = {0.5, 15.5, 0.5};
ITEM.rotation = {90, 180, 90};

pistachio.item:Register(ITEM);