GM.Version = "Alpha 1.7.5.2";

MsgN("\n\n\tPistachio "..GM.Version.." loading.\n");

GM:IncludeDir("main/libraries");
GM:IncludeDir("main/items/base");
GM:IncludeDir("main/items");
GM:IncludeDir("main/derma");

local moduleFiles, moduleFolders = file.Find(GM.FolderName.."/gamemode/main/modules/*", "LUA");

for k, v in pairs(moduleFolders) do
	if ( !string.find(v, ".lua") ) then
		local path = GM.FolderName.."/gamemode/main/modules/"..v;

		MODULE = MODULE or {};
			if (SERVER) then
				if ( file.Find(path.."/sv_main.lua", "LUA")[1] ) then
					include(path.."/sv_main.lua", "LUA");
				end;

				if ( file.Find(path.."/cl_main.lua", "LUA")[1] ) then
					AddCSLuaFile(path.."/cl_main.lua", "LUA");
				end;

				if ( file.Find(path.."/cl_main.lua", "LUA")[1] ) then
					include(path.."/cl_main.lua", "LUA");
				end;
			else
				if ( file.Find(path.."/cl_main.lua", "LUA")[1] ) then
					include(path.."/cl_main.lua", "LUA");
				end;
			end;
		MODULE = nil;
	end;
end;

include("sh_commands.lua");
include("sh_vote.lua");

TEAM_CITIZEN = 1;
TEAM_POLICE = 2;
TEAM_MAYOR = 3;
TEAM_ARRESTED = 0;

team.SetUp( TEAM_CITIZEN, "Citizen", Color(0, 200, 0, 255) );
team.SetUp( TEAM_POLICE, "Police Officer", Color(0, 125, 255, 255) );
team.SetUp( TEAM_MAYOR, "Mayor", Color(255, 0, 0, 255) );
team.SetUp( TEAM_ARRESTED, "Criminal", Color(125, 125, 125, 255) );

function GM:PlayerNoClip(client, noclipping)
	return client:IsAdmin();
end;

function GM:GravGunPunt(client, entity)
	if (SERVER) then
		DropEntityIfHeld(entity);

		return false;
	end;
	
	return false;
end;

function GM:CanProperty(client, property, entity)
	return client:IsAdmin();
end;

function pistachio:GetPlayerByName(name)
	local output = {};

	for k, v in pairs( player.GetAll() ) do
		local lowerName = string.lower( v:Name() );

		if ( string.find( lowerName, string.lower(name) ) ) then
			output[#output + 1] = v;
		end;
	end;

	if (#output == 1) then
		return output[1];
	else
		return output;
	end;
end;

function GM:ShouldCollide(entity, entity2)
	if ( entity:IsPlayer() and entity2:IsPlayer() ) then
		return true;
	end;

	return true;
end;

pistachio.playerModels = {};

pistachio.playerModels[TEAM_CITIZEN] = {
	-- Other.
	"models/player/Kleiner.mdl",
	"models/player/alyx.mdl",
	"models/player/gman_high.mdl",

	-- Female models.
	"models/player/Group01/Female_01.mdl",
	"models/player/Group01/Female_02.mdl",
	"models/player/Group01/Female_03.mdl",
	"models/player/Group01/Female_04.mdl",
	"models/player/Group01/Female_06.mdl",
	"models/player/Group01/Female_07.mdl",
	"models/player/Group03/Female_01.mdl",
	"models/player/Group03/Female_02.mdl",
	"models/player/Group03/Female_03.mdl",
	"models/player/Group03/Female_04.mdl",
	"models/player/Group03/Female_06.mdl",
	"models/player/Group03/Female_07.mdl",

	-- Male models.
	"models/player/Group01/male_09.mdl",
	"models/player/Group01/male_08.mdl",
	"models/player/Group01/male_07.mdl",
	"models/player/Group01/male_06.mdl",
	"models/player/Group01/male_05.mdl",
	"models/player/Group01/male_04.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/male_02.mdl",
	"models/player/Group01/male_01.mdl",
	"models/player/Group03/male_02.mdl",
	"models/player/Group03/male_03.mdl",
	"models/player/Group03/male_04.mdl",
	"models/player/Group03/male_05.mdl",
	"models/player/Group03/male_06.mdl",
	"models/player/Group03/male_07.mdl",
	"models/player/Group03/male_08.mdl"
};

pistachio.playerModels[TEAM_POLICE] = {
	"models/player/riot.mdl",
	"models/player/swat.mdl",
	"models/player/urban.mdl",
	"models/player/gasmask.mdl"
	--[[
	"models/player/police.mdl",
	"models/player/combine_soldier.mdl",
	"models/player/combine_soldier_prisonguard.mdl"
	--]]
};

pistachio.playerModels[TEAM_MAYOR] = {
	"models/player/breen.mdl",
	"models/player/mossman.mdl"
}

pistachio.itemColors = {};

pistachio.itemColors["none"] = Color(225, 175, 85, 255);
pistachio.itemColors["Contraband"] = Color(125, 125, 125, 255);

MsgN("\n\tPistachio "..GM.Version.." initialized.\n\t("..math.Round(SysTime() - (GM.StartTime or 0), 3).." seconds)\n");