local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Bucket Head";
ITEM.uniqueID = "hat_bucket";
ITEM.model = "models/props_junk/MetalBucket01a.mdl";
ITEM.description = "A shiny bucket you place on your head.";
ITEM.price = 500;
ITEM.offset = {0.5, 5, 0.5};
ITEM.rotation = {90, 0, 90};

pistachio.item:Register(ITEM);