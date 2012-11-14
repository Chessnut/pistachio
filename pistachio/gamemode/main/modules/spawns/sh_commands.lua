local MODULE = MODULE;

pistachio.command:Create("setspawn", "<team>", "Sets a team spawn at where you are.", function(client, arguments)
	local argument = tonumber( arguments[1] );

	if (!argument) then
		client:Notify("That isn't a valid number!");

		return;
	elseif ( !team.Valid(argument) ) then
		client:Notify("That isn't a valid team!");

		return;
	end;

	table.insert( MODULE.spawns, { team = argument, position = client:GetPos() + Vector(0, 0, 16) } );

	client:Notify("You have added a new spawn.");

	MODULE:SaveSpawns();
end, false, "superadmin");

pistachio.command:Create("removespawn", nil, "Removes a team spawn at where you are.", function(client, arguments)
	local amount = 0;

	for k, v in pairs(MODULE.spawns) do
		if (v.position:Distance( client:GetPos() ) <= 128) then
			amount = amount + 1;
			
			MODULE.spawns[k] = nil;
		end;
	end;

	client:Notify("You have removed "..amount.." spawn(s).");

	MODULE:SaveSpawns();
end, false, "superadmin");