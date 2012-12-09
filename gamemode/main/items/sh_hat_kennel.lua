local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Kennel";
ITEM.uniqueID = "hat_kennel";
ITEM.model = "models/props_lab/kennel_physics.mdl";
ITEM.description = "A dog kennel with a some blood stains.";
ITEM.price = 750;
ITEM.offset = {0.5, -4.5, 0};
ITEM.rotation = {90, 180, 90};
ITEM.scale = 0.65;

pistachio.item:Register(ITEM);