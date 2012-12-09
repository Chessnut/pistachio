local ITEM = {};

ITEM.base = "base_vehicle";
ITEM.name = "Delivery Van";
ITEM.uniqueID = "vehicle_delivery";
ITEM.model = "models/source_vehicles/deliveryvan.mdl";
ITEM.description = "A white delivery van that has space in the back";
ITEM.price = 9500;
ITEM.vehicleScript = "deliveryvan";
ITEM.honk = "vu_horn_old";
ITEM.seats = {
	{ offset = Vector(26, -48, 52), rotation = Angle(0, 0, 0), exit = Vector(98, -48, 74) }
};

pistachio.item:Register(ITEM);