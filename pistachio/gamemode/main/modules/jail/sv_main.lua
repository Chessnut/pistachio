local MODULE = MODULE;

include("sh_commands.lua");
AddCSLuaFile("sh_commands.lua");

pistachio.jails = pistachio.jails or {};

function MODULE:SaveJails()
	pistachio.persist:PersistData("jails", pistachio.jails);
end;

function MODULE:LoadJails()
	local jails = pistachio.persist:GetData("jails");

	if (jails) then
		pistachio.jails = jails;
	end;
end;

function MODULE:GetPosition()
	if (pistachio.jails and #pistachio.jails > 0) then
		return table.Random(pistachio.jails);
	end;
end;

function pistachio:GetJailPosition()
	if (pistachio.jails and #pistachio.jails > 0) then
		return table.Random(pistachio.jails);
	end;
end;

timer.Simple(10, function()
	MODULE:LoadJails();
end);