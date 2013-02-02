local _R = debug.getregistry();
local playerMeta = _R.Player;

NET_PRIVATE = 1;
NET_PUBLIC = 2;

function playerMeta:PersistVar(key, varType)
	local data;

	if (varType == NET_PRIVATE) then
		data = self:GetPrivateVar(key);
	else
		data = self:GetPublicVar(key);
	end;

	if (data) then
		local dataType = string.lower( type(data) );

		if (PS_USE_MYSQL) then
			local steamID = self:SteamID();

			for k, v in pairs(pistachio.db.tables) do
				if (k == key) then
					local value = data;
					data = pistachio.db.obj:escape( tostring(data) );

					if (v.data == "string") then
						data = "\""..data.."\"";
					end;

					pistachio.db:Query("UPDATE players SET "..v.table.."="..data.." WHERE SteamID=\""..steamID.."\"");

					return;
				end;
			end;
		end;

		self:SetPData( "ps_persist_"..key, dataType..":"..tostring(data) );
	end;
end;

function playerMeta:RestoreVar(key, varType, forcePData)
	if (PS_USE_MYSQL and !forcePData) then
		local steamID = self:SteamID();

		for k, v in pairs(pistachio.db.tables) do
			if (k == key) then
				pistachio.db:Query("SELECT "..v.table.." FROM players WHERE SteamID=\""..steamID.."\"", function(data)
					if ( !data[1] ) then
						self:RestoreVar(key, varType, true);

						return;
					end;

					local value = data[1][v.table];

					if (!value) then
						self:RestoreVar(key, varType, true);
						
						return;
					end;

					if ( _G["to"..v.data] ) then
						value = _G["to"..v.data](value);
					end;

					if (value) then
						if (varType == NET_PRIVATE) then
							self:SetPrivateVar(key, value);
						else
							self:SetPublicVar(key, value);
						end;
					end;
				end);

				return;
			end;
		end;
	end;

	local data = self:GetPData("ps_persist_"..key);

	if (data) then
		local explodedString = string.Explode(":", data);
		local dataType = explodedString[1];
		local value = explodedString[2];

		if (dataType and value) then
			if ( _G["to"..dataType] ) then
				value = _G["to"..dataType](value);
			end;
			
			if (value) then
				if (varType == NET_PRIVATE) then
					self:SetPrivateVar(key, value);
				else
					self:SetPublicVar(key, value);
				end;
			end;
		end;
	end;
end;

pistachio.persist = pistachio.persist or {};
pistachio.persist.stored = pistachio.persist.stored or {};

function pistachio.persist:PersistData(key, value, notMapOnly, merge) -- Merge is now redundant.
	self.stored[key] = self.stored[key] or {};

	if (value and type(value) == "table") then
		self.stored[key] = value;
	end;

	local pistachioFile, pistachioFolder = file.Find("pistachio", "DATA");

	if ( !pistachioFolder[1] ) then
		file.CreateDir("pistachio");
	end;

	local persistFile, persistFolder = file.Find("pistachio/persist", "DATA");

	if ( !persistFolder[1] ) then
		file.CreateDir("pistachio/persist");
	end;

	if (!notMapOnly) then
		local mapFile, mapFolder = file.Find("pistachio/persist/"..game.GetMap(), "DATA");
		
		if ( !mapFolder[1] ) then
			file.CreateDir( "pistachio/persist/"..game.GetMap() );
		end;
	end;

	local encoded = util.Compress( util.TableToJSON( self.stored[key] ) );

	if (!notMapOnly) then
		file.Write("pistachio/persist/"..game.GetMap().."/"..key.."_tier2.txt", encoded);
	else
		file.Write("pistachio/persist/"..key.."_tier2.txt", encoded);
	end;
end;

function pistachio.persist:GetData(key, notMapOnly)
	if ( !self.stored[key] ) then
		return self:RestoreData(key, notMapOnly);
	end;

	return self.stored[key] or {};
end;

function pistachio.persist:RestoreData(key, notMapOnly)
	self.stored[key] = self.stored[key] or {};

	local content;

	if (!notMapOnly) then
		content = util.Decompress(file.Read("pistachio/persist/"..game.GetMap().."/"..key.."_tier2.txt", "DATA") or "");
	else
		content = util.Decompress(file.Read("pistachio/persist/"..key.."_tier2.txt", "DATA") or "");
	end;

	local decoded = util.JSONToTable(content or "");

	if (decoded) then
		self.stored[key] = decoded;
	end;

	return self.stored[key];
end;