local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "GAZ 24";
ITEM.uniqueID = "vehicle_gaz";
ITEM.model = "models/source_vehicles/car004a.mdl";
ITEM.description = "Manufactured by Gorkovsky Avtomobilny Zavod.";
ITEM.price = 7500;
ITEM.vehicleScript = "hl2_cars";
ITEM.seats = {
	{ offset = Vector(-15, 38, 17), rotation = Angle(0, 0, 0), exit = Vector(-72, 35, 55) },
	{ offset = Vector(14, 38, 17), rotation = Angle(0, 0, 0), exit = Vector(78, 35, 55) },
	{ offset = Vector(14, 2, 17), rotation = Angle(0, 0, 0), exit = Vector(78, -5, 55) }
};

pistachio.item:Register(ITEM);