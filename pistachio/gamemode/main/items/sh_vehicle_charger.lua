local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Dodge Charger";
ITEM.uniqueID = "vehicle_charger";
ITEM.model = "models/source_vehicles/69_dodge_chargerRT/vehicle.mdl";
ITEM.description = "A yellow colored dodge charger from 1969.";
ITEM.price = 9500;
ITEM.vehicleScript = "muscle";
ITEM.seats = {
	{ offset = Vector(21, 2, 21), rotation = Angle(0, 0, 0), exit = Vector(78, 7, 40) },
	{ offset = Vector(21, 40, 26), rotation = Angle(0, 0, 0), exit = Vector(93, 40, 40) },
	{ offset = Vector(-22, 40, 23), rotation = Angle(0, 0, 0), exit = Vector(-106, 40, 40) }
};

pistachio.item:Register(ITEM);