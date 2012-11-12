local _R = debug.getregistry();
local playerMeta = _R.Player;

if (SERVER) then
	util.AddNetworkString("ps_Inventory");
	util.AddNetworkString("ps_InventoryItem");
	util.AddNetworkString("ps_InventoryPanel");

	function playerMeta:SaveInventory()
		if ( IsValid(self) ) then
			self.inventory = self.inventory or {};

			local encoded = util.TableToJSON(self.inventory);
			local pistachioFile, pistachioFolder = file.Find("pistachio", "DATA");

			if ( !pistachioFolder[1] ) then
				file.CreateDir("pistachio");
			end;

			local inventoryFile, inventoryFolder = file.Find("pistachio/inventory", "DATA");

			if ( !inventoryFolder[1] ) then
				file.CreateDir("pistachio/inventory");
			end;

			file.Write("pistachio/inventory/"..self:UniqueID()..".txt", encoded);
		end;
	end;

	function playerMeta:RestoreInventory()
		if ( IsValid(self) ) then
			local pistachioFile, pistachioFolder = file.Find("pistachio", "DATA");

			if ( !pistachioFolder[1] ) then
				file.CreateDir("pistachio");
			end;

			local inventoryFile, inventoryFolder = file.Find("pistachio/inventory", "DATA");
			
			if ( !inventoryFolder[1] ) then
				file.CreateDir("pistachio/inventory");
			end;

			local content = file.Read("pistachio/inventory/"..self:UniqueID()..".txt", "DATA");

			if (content) then
				local decoded = util.JSONToTable(content);

				self.inventory = decoded;

				net.Start("ps_Inventory");
					net.WriteTable(self.inventory);
				net.Send(self);
			else
				self.inventory = self.inventory or {};
			end;
		end;
	end;

	function playerMeta:SyncInventory()
		self.inventory = self.inventory or {};

		net.Start("ps_Inventory");
			net.WriteTable(self.inventory);
		net.Send(self);
	end;

	function playerMeta:AddItem(key, amount)
		if (!amount) then
			amount = 1;
		end;

		if ( pistachio.item:Get(key) ) then
			if (!self.inventory) then
				self:RestoreInventory();
			end;

			local count = self:GetItemCount(key);

			self.inventory[key] = count + amount;

			net.Start("ps_InventoryItem");
				net.WriteString(key);
				net.WriteInt(amount, 8);
			net.Send(self);

			hook.Call("PlayerSaveData", GAMEMODE, self, false, true);
		end;
	end;

	function playerMeta:TakeItem(key, amount)
		if (!amount) then
			amount = 1;
		end;

		if ( pistachio.item:Get(key) ) then
			if (!self.inventory) then
				self:RestoreInventory();
			end;

			local count = self:GetItemCount(key);

			if (count - amount < 1) then
				self.inventory[key] = nil;
			else
				self.inventory[key] = count - amount;
			end;

			net.Start("ps_InventoryItem");
				net.WriteString(key);
				net.WriteInt(-amount, 8);
			net.Send(self);

			hook.Call("PlayerSaveData", GAMEMODE, self, false, true);
		end;
	end;
else
	pistachio.inventory = {};

	net.Receive("ps_Inventory", function(length)
		local inventory = net.ReadTable();

		LocalPlayer().inventory = inventory;

		RunConsoleCommand("ps_rebuildinv");
	end);

	net.Receive("ps_InventoryItem", function(length)
		LocalPlayer().inventory = LocalPlayer().inventory or {};

		local key = net.ReadString();
		local amount = net.ReadInt(8);
		local count = LocalPlayer():GetItemCount(key);

		LocalPlayer().inventory[key] = count + amount;

		RunConsoleCommand("ps_rebuildinv");
	end);
end;

function playerMeta:GetItemCount(key)
	if ( pistachio.item:Get(key) ) then
		if (!self.inventory) then
			self:RestoreInventory();
		end;

		if ( !self.inventory[key] ) then
			return 0;
		else
			return self.inventory[key];
		end;
	end;
end;

function playerMeta:HasItem(key)
	return (self:GetItemCount(key) and self:GetItemCount(key) > 0);
end;

function playerMeta:GetInventory()
	return self.inventory or {};
end;

function playerMeta:GetItemWeight()
	local inventory = self:GetInventory();
	local weight = 0;

	for k, v in pairs(inventory) do
		local itemTable = pistachio.item:Get(k);

		if (itemTable) then
			weight = weight + ( (itemTable.weight or 0) * v) ;
		end;
	end;

	return weight;
end;