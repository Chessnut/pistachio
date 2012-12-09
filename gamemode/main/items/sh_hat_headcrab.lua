local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Headcrab";
ITEM.uniqueID = "hat_headcrab";
ITEM.model = "models/headcrabclassic.mdl";
ITEM.description = "An alien creature from Xen.";
ITEM.price = 500;
ITEM.offset = {7.5, -0.5, 0};
ITEM.rotation = {90, 180, 90};

pistachio.item:Register(ITEM);