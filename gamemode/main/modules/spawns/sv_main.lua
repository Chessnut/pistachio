local MODULE = MODULE;

include("sh_commands.lua");
AddCSLuaFile("sh_commands.lua");

MODULE.spawns = MODULE.spawns or {};

function MODULE:SaveSpawns()
	local data = {};

	for k, v in pairs(self.spawns) do
		data[#data + 1] = {
			position = v.position,
			team = v.team
		};
	end;

	pistachio.persist:PersistData("spawns", data);
end;

function MODULE:LoadSpawns()
	local spawns = pistachio.persist:GetData("spawns");

	if (spawns) then
		self.spawns = spawns;
	end;
end;

hook.Add("InitPostEntity", "ps_LoadSpawns", function()
	timer.Simple(5, function()
		MODULE:LoadSpawns();
	end);
end);

hook.Add("PlayerSpawn", "ps_SpawnPosition", function(client)
	local spawns = {};

	for k, v in pairs( pistachio.persist.stored.spawns or {} ) do
		if ( v.position and v.team and v.team == client:Team() ) then
			spawns[#spawns + 1] = v.position;
		end;
	end;

	if (spawns and #spawns > 0) then
		client:SetPos( spawns[ math.random(1, #spawns) ] );
	end;
end);

hook.Add("PlayerInitialSpawn", "ps_InitialSpawnPosition", function(client)
	timer.Simple(5, function()
		local spawns = {};

		for k, v in pairs( pistachio.persist.stored.spawns or {} ) do
			if (v.position and v.team and v.team == TEAM_CITIZEN) then
				spawns[#spawns + 1] = v.position;
			end;
		end;

		if (spawns and #spawns > 0) then
			client:SetPos( spawns[ math.random(1, #spawns) ] );
		end;
	end);
end);