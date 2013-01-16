for k, v in pairs( file.Find("materials/pistachio/particles/*", "GAME") ) do
	resource.AddFile("materials/pistachio/particles/"..v);
end;

for k, v in pairs( file.Find("models/pistachio/hats/*.mdl", "GAME") ) do
	resource.AddFile("models/pistachio/hats/"..v);
end;

for k, v in pairs( file.Find("materials/pistachio/hats/tophat/*", "GAME") ) do
	resource.AddFile("materials/pistachio/hats/tophat/"..v);
end;

resource.AddFile( Model("sound/vehicles/vu_horn_double.wav") );
resource.AddFile( Model("sound/vehicles/vu_horn_old.wav") );
resource.AddFile( Model("sound/vehicles/vu_horn_quick.wav") );
resource.AddFile( Model("sound/vehicles/vu_horn_simple.wav") );

print("Included resources.");