local MODULE = MODULE;

pistachio.command:Create("setjail", nil, "Sets a jail position at where you are.", function(client, arguments)
	pistachio.jails[#pistachio.jails + 1] = client:GetPos() + Vector(0, 0, 8);
	MODULE:SaveJails();

	client:Notify("You've added a jail position.");
end, false, "admin");

pistachio.command:Create("removejail", nil, "Removes a jail position at where you are.", function(client, arguments)
	local amount = 0;

	for k, v in pairs(pistachio.jails) do
		if (v:Distance( client:GetPos() ) <= 96) then
			amount = amount + 1;

			pistachio.jails[k] = nil
		end;
	end;

	MODULE:SaveJails();

	client:Notify("You've removed "..amount.." jail position(s).");
end, false, "admin");