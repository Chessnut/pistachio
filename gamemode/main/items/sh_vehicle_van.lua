local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Old Van";
ITEM.uniqueID = "vehicle_van";
ITEM.model = "models/source_vehicles/van001a_01.mdl";
ITEM.description = "Not even sure if driving this thing is legal.";
ITEM.price = 10000;
ITEM.vehicleScript = "van001a-vehicle_van";
ITEM.honk = "vu_horn_quick";
ITEM.seats = {
	{ offset = Vector(14, -41, 35), rotation = Angle(0, 0, 0), exit = Vector(102, -48, 69) },
	{ offset = Vector(-24, 23, 38), rotation = Angle(0, 270, 0), exit = Vector(86, 7, 55) },
	{ offset = Vector(28, 43, 31), rotation = Angle(0, 90, 0), exit = Vector(86, 64, 47) }
};

pistachio.item:Register(ITEM);