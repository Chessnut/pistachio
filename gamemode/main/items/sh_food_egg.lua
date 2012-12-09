local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Raw Egg";
ITEM.uniqueID = "food_egg";
ITEM.weight = 0.5;
ITEM.model = "models/props_phx/misc/egg.mdl";
ITEM.description = "Filled with glorious amount of protein.";
ITEM.price = 10;
ITEM.stockLimit = 15;
ITEM.restore = 5;
ITEM.staminaRestore = 10;

pistachio.item:Register(ITEM);