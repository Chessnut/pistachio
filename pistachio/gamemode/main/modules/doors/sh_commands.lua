local MODULE = MODULE;

pistachio.command:Create("doorsetunownable", "<title>", "Sets a door to be unownable.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) ) then
		local text = table.concat(arguments or "Door", " ");

		for k, v in pairs(MODULE.doors) do
			if (v == entity) then
				MODULE.doors[k] = nil;
			end;
		end;

		MODULE.doors[#MODULE.doors + 1] = entity;

		entity:SetPublicVar("title", text);
		entity:SetPublicVar("unownable", true);

		MODULE:SaveUnownableDoors();
	else
		client:Notify("That isn't a valid entity!");
	end;
end, false, "admin");

pistachio.command:Create("doorsetteam", "<title> <team>", "Sets a door to belong to a team.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) ) then
		local text = tostring( arguments[1] );
		local doorTeam = tonumber( arguments[2] );

		if ( !doorTeam or !team.Valid(doorTeam) ) then
			client:Notify("That isn't a valid team!");

			return;
		end;

		for k, v in pairs(MODULE.teamDoors) do
			if (v == entity) then
				MODULE.teamDoors[k] = nil;
			end;
		end;

		MODULE.teamDoors[#MODULE.teamDoors + 1] = entity;

		entity:SetPublicVar("title", text);
		entity:SetPublicVar("unownable", true);
		entity:SetPublicVar("team", doorTeam);
		
		MODULE:SaveTeamDoors();
	else
		client:Notify("That isn't a valid entity!");
	end;
end, false, "admin");