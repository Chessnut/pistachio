local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "ZAZ 968";
ITEM.uniqueID = "vehicle_zaz";
ITEM.model = "models/source_vehicles/car005a.mdl";
ITEM.description = "A subcompact car designed in 1958.";
ITEM.price = 8000;
ITEM.vehicleScript = "hl2_cars";
ITEM.seats = {
	{ offset = Vector(-17, 40, 26), rotation = Angle(0, 0, 0), exit = Vector(-87, 62, 59) },
	{ offset = Vector(16, 40, 26), rotation = Angle(0, 0, 0), exit = Vector(71, 59, 59) },
	{ offset = Vector(16, 4, 26), rotation = Angle(0, 0, 0), exit = Vector(74, 0, 59) }
};

pistachio.item:Register(ITEM);