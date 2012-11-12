local MODULE = MODULE;

pistachio.command:Create("setjail", nil, "Sets a jail position at where you are.", function(client, arguments)
	pistachio.jails[#pistachio.jails + 1] = client:GetPos() + Vector(0, 0, 8);
	MODULE:SaveJails();

	client:Notify("You've added a jail position.");
end, false, "admin");