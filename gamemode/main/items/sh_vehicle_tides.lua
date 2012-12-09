local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Tides Truck";
ITEM.uniqueID = "vehicle_tides";
ITEM.model = "models/source_vehicles/de_tides_truck.mdl";
ITEM.description = "A large truck that is capable of carrying cargo.";
ITEM.price = 15000;
ITEM.vehicleScript = "de_tides_truck";
ITEM.honk = "vu_horn_old";
ITEM.seats = {
	{ offset = Vector(21, -79, 46), rotation = Angle(0, 0, 0), exit = Vector(81, -79, 66) }
};

pistachio.item:Register(ITEM);