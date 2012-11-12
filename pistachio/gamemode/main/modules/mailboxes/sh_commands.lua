local MODULE = MODULE;

pistachio.command:Create("createmailbox", nil, "Creates a mailbox at where you aim.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local position = trace.HitPos;
	local angle = Angle(0, client:EyeAngles().y, 0);

	angle.y = angle.y + 270;
	angle.y = math.floor(angle.y / 94) * 90;

	if (position) then
		local isValid = MODULE:CreateMailBox(position, angle);

		if (isValid) then
			client:Notify("You have added a mailbox.");
		end;
	end;

	MODULE:SaveMailBoxes();
end, false, "admin");