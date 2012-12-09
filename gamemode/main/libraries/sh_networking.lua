local _R = debug.getregistry();
local entityMeta = _R.Entity;

if (SERVER) then
	util.AddNetworkString("ps_PrivateVar");
	util.AddNetworkString("ps_PublicVar");
	util.AddNetworkString("ps_NetworkData");

	function entityMeta:SetPrivateVar(key, value)
		if ( self:IsPlayer() ) then
			self.privateVars = self.privateVars or {};

			if (self.privateVars[key] and self.privateVars[key] == value) then
				return;
			end;

			self.privateVars[key] = value;

			net.Start("ps_PrivateVar");
				net.WriteTable( {key, value} );
			net.Send(self);

			if (key == "money") then
				hook.Call("PlayerSaveData", GAMEMODE, client, false, true);
			end;
		end;
	end;

	function entityMeta:SetPublicVar(key, value)
		self.publicVars = self.publicVars or {};

		if (self.publicVars[key] and self.publicVars[key] == value) then
			return;
		end;

		self.publicVars[key] = value;

		net.Start("ps_PublicVar");
			net.WriteUInt(self:EntIndex(), 16);
			net.WriteTable( {key, value} );
		net.Broadcast();
	end;

	function entityMeta:SendData(client)
		if (self.publicVars) then
			net.Start("ps_NetworkData");
				net.WriteUInt(self:EntIndex(), 16);
				net.WriteTable(self.publicVars);
			net.Send(client);
		end;
	end;

	function entityMeta:GetPrivateVar(key)
		if ( self:IsPlayer() ) then
			self.privateVars = self.privateVars or {};
			
			return self.privateVars[key];
		end;
	end;

	function entityMeta:GetPublicVar(key)
		if (self.publicVars) then
			return self.publicVars[key];
		end;
	end;
else
	pistachio.networking = pistachio.networking or {};

	net.Receive("ps_PrivateVar", function(length)
		local data = net.ReadTable();
		local key = data[1];
		local value = data[2];

		LocalPlayer().privateVars = LocalPlayer().privateVars or {};
		LocalPlayer().privateVars[key] = value;
	end);

	net.Receive("ps_PublicVar", function(length)
		local index = net.ReadUInt(16);
		local data = net.ReadTable();
		local key = data[1];
		local value = data[2];

		pistachio.networking[index] = pistachio.networking[index] or {};
		pistachio.networking[index][key] = value;
	end);

	net.Receive("ps_NetworkData", function(length)
		local index = net.ReadUInt(16);
		local data = net.ReadTable();

		pistachio.networking[index] = data;
	end);

	function entityMeta:GetPrivateVar(key)
		if ( self:IsPlayer() ) then
			if ( LocalPlayer().privateVars and LocalPlayer().privateVars[key] ) then
				return LocalPlayer().privateVars[key];
			end;
		end;
	end;

	function entityMeta:GetPublicVar(key)
		local index = self:EntIndex();

		if ( pistachio.networking[index] ) then
			return pistachio.networking[index][key];
		end;
	end;
end;