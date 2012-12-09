local ITEM = {};

ITEM.base = "base_storage";
ITEM.name = "Crate";
ITEM.uniqueID = "crate";
ITEM.model = "models/Items/item_item_crate.mdl";
ITEM.description = "An empty crate that stores items.";
ITEM.price = 150;
ITEM.maxWeight = 8;

pistachio.item:Register(ITEM);