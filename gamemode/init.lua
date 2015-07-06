GM.StartTime = SysTime();

pistachio = pistachio or {};

GM.Name = "PistachioRP";
GM.Author = "Chessnut";

include("resources.lua");
include("cl_init.lua");

function GM:IncludeDir(directory)
    local files = file.Find(self.FolderName.."/gamemode/"..directory.."/*.lua", "LUA");
 
    for k, v in pairs(files) do
    	local path = self.FolderName.."/gamemode/"..directory.."/"..v;

    	if (string.sub(v, 1, 3) == "sh_") then
    	    if (SERVER) then
    		    AddCSLuaFile(path);
    		end;
    		
    		include(path)
    	elseif (string.sub(v, 1, 3) == "sv_" and SERVER) then
    		include(path);
    	elseif (string.sub(v, 1, 3) == "cl_") then
    	    if (SERVER) then
    		    AddCSLuaFile(path);
    		else
                include(path); -- Allows for editting.
            end;
    	end;
    end;
end;

AddCSLuaFile("main/cl_main.lua");
include("main/sv_main.lua");

RunConsoleCommand("mp_falldamage", "1");
RunConsoleCommand("sbox_godmode", "0");
RunConsoleCommand("sbox_noclip", "0");
RunConsoleCommand("physgun_limited", "1");

DeriveGamemode("sandbox");
