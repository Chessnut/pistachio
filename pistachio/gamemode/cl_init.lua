if (SERVER) then AddCSLuaFile(); return; end;

GM.StartTime = SysTime();

pistachio = pistachio or {};

GM.Name = "PistachioRP";
GM.Author = "Chessnut";

function GM:IncludeDir(directory)
    local files = file.Find(self.FolderName.."/gamemode/"..directory.."/*.lua", "LUA");
 
    for k, v in pairs(files) do
        local path = self.FolderName.."/gamemode/"..directory.."/"..v;

        if (string.sub(v, 1, 3) == "sh_") then
            include(path)
        elseif (string.sub(v, 1, 3) == "cl_") then
            include(path);
        end;
    end;
end;

include("main/cl_main.lua");

DeriveGamemode("sandbox");