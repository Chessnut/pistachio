local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Cone";
ITEM.uniqueID = "hat_cone";
ITEM.model = "models/props_junk/TrafficCone001a.mdl";
ITEM.description = "An orange colored cone.";
ITEM.price = 600;
ITEM.offset = {0.5, 15, 0};
ITEM.rotation = {90, 180, 90};
ITEM.scale = 0.8;

pistachio.item:Register(ITEM);