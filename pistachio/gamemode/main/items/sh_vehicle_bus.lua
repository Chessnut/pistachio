local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "City Bus";
ITEM.uniqueID = "vehicle_bus";
ITEM.model = "models/source_vehicles/bus01_2.mdl";
ITEM.description = "A large bus capable of carrying 32 passengers.";
ITEM.preventBuy = true;
ITEM.honk = "vu_horn_old";
ITEM.vehicleScript = "l4d_bus";
ITEM.seats = {
	{ offset = Vector(-12, -163, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-36, -163, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-36, -132, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, -132, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, -96, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, -60, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, -24, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, 11, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, 47, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, 86, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, 126, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, 169, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-12, 210, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(11, 210, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, 210, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, 210, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, 170, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, 86, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, 47, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, 11, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, -22, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, -60, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(-34, -96, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, -96, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, -60, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, -22, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, 14, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, 47, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, 86, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, 126, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, -131, 64), rotation = Angle(0, 0, 0) },
	{ offset = Vector(33, -162, 64), rotation = Angle(0, 0, 0) }
};

pistachio.item:Register(ITEM);