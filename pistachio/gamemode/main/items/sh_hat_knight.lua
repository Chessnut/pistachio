local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "White Knight";
ITEM.uniqueID = "hat_knight";
ITEM.model = "models/props_phx/games/chess/white_knight.mdl";
ITEM.description = "It goes in the 'L' shape.";
ITEM.price = 500;
ITEM.offset = {1, 5.5, 0.25};
ITEM.rotation = {90, 180, 90};
ITEM.scale = 0.5;

pistachio.item:Register(ITEM);