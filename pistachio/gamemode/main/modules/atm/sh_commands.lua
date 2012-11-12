local MODULE = MODULE;

pistachio.command:Create("createatm", nil, "Creates an ATM machine at where you aim.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local position = trace.HitPos;
	local angle = Angle(0, client:EyeAngles().y, 0);

	angle.y = angle.y + 270;
	angle.y = math.floor(angle.y / 94) * 90;

	if (position) then
		local isValid = MODULE:CreateATM(position, angle);

		if (isValid) then
			client:Notify("You have added a mailbox.");
		end;
	end;

	MODULE:SaveATM();
end, false, "admin");