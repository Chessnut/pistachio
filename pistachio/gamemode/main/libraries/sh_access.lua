local _R = debug.getregistry();
local entityMeta = _R.Entity;

if (SERVER) then
	util.AddNetworkString("ps_AccessData");
	util.AddNetworkString("ps_OwnEntity");

	function entityMeta:GiveAccess(client, isOwner)
		self.access = self.access or {};
		self.access[client] = true;

		if (isOwner) then
			self.access.owner = client;
		end;

		net.Start("ps_AccessData");
			net.WriteUInt(self:EntIndex(), 16);
			net.WriteTable(self.access);
		net.Broadcast();
	end;

	function entityMeta:TakeAccess(client)
		if ( IsValid(client) ) then
			self.access = self.access or {};
			self.access[client] = nil;
		end;
	end;

	function entityMeta:RemoveAccess()
		self.access = nil;

		net.Start("ps_AccessData");
			net.WriteUInt(self:EntIndex(), 16);
			net.WriteTable( {} );
		net.Broadcast();
	end;

	function entityMeta:SendAccess(client)
		if ( self.access and table.Count(self.access) > 0 and IsValid(client) ) then
			net.Start("ps_AccessData");
				net.WriteUInt(self:EntIndex(), 16);
				net.WriteTable(self.access);
			net.Send(client);
		end;
	end;

	net.Receive("ps_OwnEntity", function(length, client)
		local entity = net.ReadEntity();

		if ( IsValid(entity) ) then
			if ( entity:GetPublicVar("unownable") or entity:GetPublicVar("team") ) then
				client:Notify("This entity is unownable!");
				
				return;
			end;

			local price = 50;

			if ( entity:IsVehicle() and !entity:IsAccessed() ) then
				price = 100;
			end;

			local money = client:GetPrivateVar("money") or 0;

			if (money - price >= 0) then
				entity:GiveAccess(client, true);

				client:SetPrivateVar("money", money - price);
				client:Notify("You've now purchased this entity.");
			else
				client:Notify("You cannot afford this entity!");
			end;
		end;
	end);
else
	pistachio.access = pistachio.access or {};

	net.Receive("ps_AccessData", function(length)
		local entity = net.ReadUInt(16);
		local access = net.ReadTable();

		if (access) then
			pistachio.access[entity] = access;
		else
			pistachio.access[entity] = nil;
		end;
	end);
end;

function entityMeta:GetAccessOwner()
	if (SERVER) then
		self.access = self.access or {};

		return self.access.owner;
	else
		if ( pistachio.access[ self:EntIndex() ] ) then
			return pistachio.access[ self:EntIndex() ].owner;
		end;
	end;
end;

function entityMeta:HasAccess(client)
	if (SERVER) then
		if ( IsValid(client) ) then
			if ( self:GetPublicVar("team") and self:GetPublicVar("team") <= client:Team() ) then
				return true;
			else
				self.access = self.access or {};

				if ( self.access[client] ) then
					return self.access[client];
				end;
			end;
		end;

		return false;
	else
		if ( self:GetPublicVar("team") and self:GetPublicVar("team") <= client:Team() ) then
			return true;
		elseif ( pistachio.access[ self:EntIndex() ] and pistachio.access[ self:EntIndex() ][client] ) then
			return pistachio.access[ self:EntIndex() ][client];
		end;

		return false;
	end;

	return false;
end;

function entityMeta:IsAccessed()
	if (SERVER) then
		if (!self.access) then
			return false;
		end;

		if (table.Count(self.access) < 1) then
			return false;
		end;

		return true;
	else
		if ( !pistachio.access[ self:EntIndex() ] ) then
			return false;
		end;

		if (table.Count( pistachio.access[ self:EntIndex() ] ) < 1) then
			return false;
		end;

		return true;
	end;
end;