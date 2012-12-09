local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Hooked";
ITEM.uniqueID = "hat_hook";
ITEM.model = "models/props_junk/meathook001a.mdl";
ITEM.description = "A rusty hook that goes through the head.";
ITEM.price = 500;
ITEM.offset = {0.5, 4.5, 0.5};
ITEM.rotation = {45, 0, 90};
ITEM.scale = 0.5;

pistachio.item:Register(ITEM);