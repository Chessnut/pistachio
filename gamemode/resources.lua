for k, v in pairs( file.Find("materials/pistachio/particles/*", "GAME") ) do
	resource.AddFile("materials/pistachio/particles/"..v);
end;

for k, v in pairs( file.Find("models/pistachio/hats/*.mdl", "GAME") ) do
	resource.AddFile("models/pistachio/hats/"..v);
end;

for k, v in pairs( file.Find("materials/pistachio/hats/tophat/*", "GAME") ) do
	resource.AddFile("materials/pistachio/hats/tophat/"..v);
end;

for k, v in pairs( file.Find("models/source_vehicles/*", "GAME") ) do
	resource.AddFile("models/source_vehicles/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/"..v);
end;

for k, v in pairs( file.Find("models/source_vehicles/69_dodge_chargerrt/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/69_dodge_chargerrt/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/69chargerrt/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/69chargerrt/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/69fury/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/69fury/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/78chevrolet/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/78chevrolet/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/genlee/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/genlee/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/junk_cars/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/junk_cars/"..v);
end;

for k, v in pairs( file.Find("materials/source_vehicles/zapor/*", "GAME") ) do
	resource.AddFile("materials/source_vehicles/zapor/"..v);
end;

for k, v in pairs( file.Find("sound/vehicles/apc/*", "GAME") ) do
	resource.AddFile("sound/vehicles/zapor/"..v);
end;

for k, v in pairs( file.Find("sound/vehicles/crane/*", "GAME") ) do
	resource.AddFile("sound/vehicles/crane/"..v);
end;

for k, v in pairs( file.Find("sound/vehicles/junker/*", "GAME") ) do
	resource.AddFile("sound/vehicles/junker/"..v);
end;

for k, v in pairs( file.Find("sound/vehicles/truck/*", "GAME") ) do
	resource.AddFile("sound/vehicles/v8/"..v);
end;

resource.AddFile("sound/vehicles/vu_horn_double.wav");
resource.AddFile("sound/vehicles/vu_horn_old.wav");
resource.AddFile("sound/vehicles/vu_horn_quick.wav");
resource.AddFile("sound/vehicles/vu_horn_simple.wav");

resource.AddFile("materials/pistachio/skin3.png");

print("Included resources.");