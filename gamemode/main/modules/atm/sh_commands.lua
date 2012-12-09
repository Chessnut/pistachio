local MODULE = MODULE;

pistachio.command:Create("createatm", nil, "Creates an ATM machine at where you aim.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local position = trace.HitPos;
	local angle = Angle(0, client:EyeAngles().y, 0);

	angle.y = angle.y + 180;
	angle.y = math.floor(angle.y / 94) * 45;

	if (position) then
		local isValid = MODULE:CreateATM(position, angle);

		if (isValid) then
			client:Notify("You have added an ATM machine.");
		end;
	end;

	MODULE:SaveATM();
end, false, "admin");

pistachio.command:Create("removeatm", nil, "Removes an ATM machine at where you aim.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if (IsValid(entity) and entity:GetClass() == "pistachio_atm") then
		local amount = 0;

		for k, v in pairs(MODULE.atm) do
			if (v:GetPos():Distance( entity:GetPos() ) <= 5) then
				amount = amount + 1;

				v:Remove();

				MODULE.atm[k] = nil;
			end;
		end;

		client:Notify("You have removed "..amount.." ATM machine(s).");

		MODULE:SaveATM();
	else
		client:Notify("That is not a valid entity!");
	end;
end, false, "admin");