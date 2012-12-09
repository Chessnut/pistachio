local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Tired Face";
ITEM.uniqueID = "hat_tire";
ITEM.model = "models/props_vehicles/carparts_tire01a.mdl";
ITEM.description = "A black rubber tire that is applied to the face.";
ITEM.price = 600;
ITEM.offset = {2, 2, 0};
ITEM.rotation = {90, 20, 0};
ITEM.scale = 0.5;

pistachio.item:Register(ITEM);