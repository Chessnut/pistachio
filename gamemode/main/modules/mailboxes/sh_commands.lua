local MODULE = MODULE;

pistachio.command:Create("createmailbox", nil, "Creates a mailbox at where you aim.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local position = trace.HitPos;
	local angle = Angle(0, client:EyeAngles().y, 0);

	angle.y = angle.y + 270;
	angle.y = math.floor(angle.y / 94) * 45;

	if (position) then
		local isValid = MODULE:CreateMailBox(position, angle);

		if (isValid) then
			client:Notify("You have added a mailbox.");
		end;
	end;

	MODULE:SaveMailBoxes();
end, false, "admin");

pistachio.command:Create("removemailbox", nil, "Removes a mailbox at where you aim.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if (IsValid(entity) and entity:GetClass() == "pistachio_mailbox") then
		local amount = 0;

		for k, v in pairs(MODULE.mailBoxes) do
			if (v:GetPos():Distance( entity:GetPos() ) <= 5) then
				amount = amount + 1;

				v:Remove();

				MODULE.mailBoxes[k] = nil;
			end;
		end;

		client:Notify("You have removed "..amount.." mailbox(es).");

		MODULE:SaveMailBoxes();
	end;
end, false, "admin");