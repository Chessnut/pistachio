local ITEM = {};

ITEM.base = "base_food";
ITEM.name = "Watermelon";
ITEM.uniqueID = "food_melon";
ITEM.weight = 2.5;
ITEM.model = "models/props_junk/watermelon01.mdl";
ITEM.description = "A large green colored fruit with red insides.";
ITEM.price = 50;
ITEM.stockLimit = 10;
ITEM.restore = 25;

pistachio.item:Register(ITEM);