local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Pistachio Top Hat";
ITEM.uniqueID = "hat_tophat";
ITEM.model = "models/pistachio/hats/tophat.mdl";
ITEM.description = "A black colored top hat.";
ITEM.price = 800;
ITEM.preventBuy = true;
ITEM.offset = {1, 4.8, 0};
ITEM.rotation = {0, -80, 10};

pistachio.item:Register(ITEM);