local MODULE = MODULE;

MODULE.doors = MODULE.doors or {};
MODULE.teamDoors = MODULE.teamDoors or {};

include("sh_commands.lua");
AddCSLuaFile("sh_commands.lua");

function MODULE:LoadUnownableDoors()
	local doors = pistachio.persist:GetData("unownable_doors");

	for k, v in pairs(doors) do
		local entity = ents.FindInSphere(v.position, 8)[1];

		if ( IsValid(entity) ) then
			entity:SetPublicVar("unownable", true);
			entity:SetPublicVar("title", v.title or "Door");

			self.doors[#self.doors + 1] = v;
		end;
	end;
end;

function MODULE:SaveUnownableDoors()
	local doors = self.doors;
	local data = {};

	for k, v in pairs(doors) do
		if ( IsValid(v) ) then
			local position = v:GetPos();
			local title = v:GetPublicVar("title") or "Door";

			data[#data + 1] = {
				position = position,
				title = title
			};
		end;
	end;

	pistachio.persist:PersistData("unownable_doors", data);
end;

function MODULE:LoadTeamDoors()
	local doors = pistachio.persist:GetData("team_doors");

	for k, v in pairs(doors) do
		local entity = ents.FindInSphere(v.position, 8)[1];

		if ( IsValid(entity) ) then
			entity:SetPublicVar("team", v.doorTeam or TEAM_CITIZEN);
			entity:SetPublicVar("title", v.title or "Door");

			self.teamDoors[#self.teamDoors + 1] = v;
		end;
	end;
end;

function MODULE:SaveTeamDoors()
	local doors = self.teamDoors;
	local data = {};

	for k, v in pairs(doors) do
		if ( IsValid(v) ) then
			local position = v:GetPos();
			local title = v:GetPublicVar("title") or "Door";
			local doorTeam = v:GetPublicVar("team") or TEAM_CITIZEN;

			data[#data + 1] = {
				position = position,
				title = title,
				doorTeam = doorTeam
			};
		end;
	end;

	pistachio.persist:PersistData("team_doors", data);
end;

hook.Add("InitPostEntity", "ps_LoadDoors", function()
	timer.Simple(5, function()
		MODULE:LoadUnownableDoors();
		MODULE:LoadTeamDoors();
	end);
end);