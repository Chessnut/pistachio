local ITEM = {};

ITEM.base = "base_weapon";
ITEM.price = 100;
ITEM.name = "Camera";
ITEM.model = "models/maxofs2d/camera.mdl";
ITEM.description = "A small, flashing rectangular prism of mass photography.";
ITEM.uniqueID = "gmod_camera";

pistachio.item:Register(ITEM);