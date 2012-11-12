local MODULE = MODULE;

pistachio.command:Create("setspawn", "<team>", "Creates at where you are.", function(client, arguments)
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