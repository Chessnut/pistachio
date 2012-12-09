local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Utility Truck";
ITEM.uniqueID = "vehicle_util";
ITEM.model = "models/source_vehicles/utility_truck.mdl";
ITEM.description = "A medium sized white truck capable of carrying two people.";
ITEM.price = 9250;
ITEM.vehicleScript = "utilitytruck";
ITEM.honk = "vu_horn_old";
ITEM.seats = {
	{ offset = Vector(21, 14, 26), rotation = Angle(0, 0, 0), exit = Vector(90, 11, 55) }
};

pistachio.item:Register(ITEM);