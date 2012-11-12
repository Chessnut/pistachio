local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Trabbi";
ITEM.uniqueID = "vehicle_trabant";
ITEM.model = "models/source_vehicles/car002a.mdl";
ITEM.description = "Previously a common vehicle in Eastern Europe.";
ITEM.price = 6250;
ITEM.vehicleScript = "hl2_hatchback";
ITEM.honk = "vu_horn_quick";
ITEM.seats = {
	{ offset = Vector(9, 0, 15), rotation = Angle(0, 0, 0), exit = Vector(74, 0, 59) }
};

pistachio.item:Register(ITEM);