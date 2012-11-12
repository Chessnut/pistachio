local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Phone";
ITEM.uniqueID = "hat_phone";
ITEM.model = "models/weapons/w_camphone.mdl";
ITEM.description = "An old resilient phone from 2006.";
ITEM.price = 750;
ITEM.offset = {4, 0, 1.75};
ITEM.rotation = {270, -40, 0};
ITEM.scale = 1.5;

pistachio.item:Register(ITEM);