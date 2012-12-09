local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Moskvitch 2140";
ITEM.uniqueID = "vehicle_moskvitch";
ITEM.model = "models/source_vehicles/car003a.mdl";
ITEM.description = "A small family sized car produced by the Soviets.";
ITEM.price = 8500;
ITEM.vehicleScript = "hl2_cars";
ITEM.seats = {
	{ offset = Vector(16, 38, 21), rotation = Angle(0, 0, 0), exit = Vector(71, 62, 55) },
	{ offset = Vector(-15, 38, 21), rotation = Angle(0, 0, 0), exit = Vector(-67, 38, 55) },
	{ offset = Vector(16, 4, 21), rotation = Angle(0, 0, 0), exit = Vector(71, -17, 55) }
};

pistachio.item:Register(ITEM);