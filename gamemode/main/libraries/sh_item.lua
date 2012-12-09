pistachio.item = pistachio.item or {};
pistachio.item.stored = pistachio.item.stored or {};
pistachio.item.base = pistachio.item.base or {};

function pistachio.item:Register(itemTable)
	if ( self.stored[itemTable.uniqueID] ) then
		local changedPrice = self.stored[itemTable.uniqueID].price;

		itemTable.price = changedPrice or itemTable.price;
	end;

	if (itemTable.isBase) then
		self.base[itemTable.baseID] = itemTable;

		return;
	end;

	if (itemTable.base) then
		local baseTable = self.base[itemTable.base];

		if (baseTable) then
			table.Inherit(itemTable, baseTable);
		end;
	end;

	util.PrecacheModel(itemTable.model);

	itemTable.basePrice = itemTable.price;

	if (!itemTable.preventUse) then
		local oldUse = itemTable.OnUse;

		function itemTable:OnUse(entity, client)
			local value;

			if (oldUse) then
				value = oldUse(self, entity, client);
			end;
			
			if (value != false) then
				client:TakeItem(self.uniqueID);
			end;

			return value;
		end;
	end;

	if (!itemTable.preventDrop) then
		local oldDrop = itemTable.OnDrop;

		function itemTable:OnDrop(entity, client)
			local value;

			if (oldDrop) then
				value = oldDrop(self, entity, client);
			end;

			if (value != false) then
				client:TakeItem(self.uniqueID);
			end;

			return !value;
		end;
	end;

	self.stored[itemTable.uniqueID] = itemTable;
end;

function pistachio.item:Get(key)
	return self.stored[key];
end;

if (SERVER) then
	util.AddNetworkString("ps_InvAction");
	util.AddNetworkString("ps_ItemPrice");

	net.Receive("ps_InvAction", function(length, client)
		local action = net.ReadString();
		local key = net.ReadString();
		local itemTable = pistachio.item:Get(key);
		local trace = client:GetEyeTraceNoCursor();

		if (!itemTable) then
			client:Notify("Fault in IA 0x01!");

			return false;
		end;

		if ( client:IsArrested() or client:GetPublicVar("tied") ) then
			return false;
		end;

		if ( !client:HasItem(key) ) then
			client:Notify("Fault in IA 0x02!")

			return false;
		end;

		if (string.sub(action, 1, 2) != "On") then
			return false;
		end;

		local position = trace.HitPos + Vector(0, 0, 8);

		if (position:Distance( client:GetPos() ) > 72) then
			position = client:GetShootPos() + (client:GetAimVector() * 72);
		end;

		local entity = pistachio.item:Create(key, position);

		if ( IsValid(entity) ) then
			local shouldTake, shouldRemove = !itemTable[action](itemTable, entity, client);

			if (shouldRemove or shouldTake) then
				SafeRemoveEntity(entity);
			end;
		end;

		client:SyncInventory();
	end);

	function pistachio.item:Create(key, position, angle)
		if (!key) then
			return;
		end;

		if ( !self:Get(key) ) then
			return;
		end;
		
		local entity = ents.Create("pistachio_item");
		entity:SetPos(position);
		entity:SetAngles( angle or Angle(0, 0, 0) );
		entity:Spawn();
		entity:Activate();
		entity:SetItem(key);

		return entity;
	end;

	function pistachio.item:SetPrice(uniqueID, price)
		local itemTable = self:Get(uniqueID);

		if (itemTable) then
			itemTable.price = math.floor(price);

			net.Start("ps_ItemPrice");
				net.WriteString(uniqueID);
				net.WriteInt(price, 16);
			net.Broadcast();
		end;
	end;

	function pistachio.item:SendPrices(client)
		for k, v in pairs(self.stored) do
			net.Start("ps_ItemPrice");
				net.WriteString(k);
				net.WriteInt(v.price or 0, 16);
			net.Send(client);
		end;
	end;
else
	net.Receive("ps_ItemPrice", function(length)
		local uniqueID = net.ReadString();
		local price = net.ReadInt(16);
		local itemTable = pistachio.item:Get(uniqueID);

		if (itemTable) then
			itemTable.price = math.floor(price);
		end;
	end);
end;