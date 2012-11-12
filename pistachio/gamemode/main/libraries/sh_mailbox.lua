local _R = debug.getregistry();
local playerMeta = _R.Player;

if (SERVER) then
	util.AddNetworkString("ps_MailBoxUse");
	util.AddNetworkString("ps_MailBoxPanel");
	util.AddNetworkString("ps_MailBoxItemTake");
	util.AddNetworkString("ps_MailBoxItemAdd")

	net.Receive("ps_MailBoxUse", function(length, client)
		local uniqueID = net.ReadString();
		local id = net.ReadUInt(8);
		local quantity = client:GetMailBoxAmount(uniqueID, id);
		local itemTable = pistachio.item:Get(uniqueID);

		if (!itemTable) then
			return;
		end;

		if (quantity <= 0) then
			return;
		end;

		client.mailBox = client.mailBox or {};
		
		if ( client.mailBox[uniqueID] ) then
			client.mailBox[uniqueID][id] = nil;
		end;

		net.Start("ps_MailBoxItemTake");
			net.WriteString(uniqueID);
			net.WriteUInt(id, 8);
		net.Send(client);

		if (itemTable.MailBoxUse) then
			local result = itemTable:MailBoxUse(client, quantity);

			if (result == false) then
				return;
			end;
		end;
		
		client:AddItem(uniqueID, quantity);

		hook.Call("PlayerSaveData", GAMEMODE, client, false, true);
	end);

	function playerMeta:SaveMailBox()
		local pistachioFile, pistachioFolder = file.Find("pistachio", "DATA");

		if ( !pistachioFolder[1] ) then
			file.CreateDir("pistachio");
		end;

		local mailBoxFile, mailBoxFolder = file.Find("pistachio/mailbox", "DATA");

		if ( !mailBoxFolder[1] ) then
			file.CreateDir("pistachio/mailbox");
		end;

		self.mailBox = self.mailBox or {};

		local encoded = util.TableToJSON(self.mailBox);

		file.Write("pistachio/mailbox/"..self:UniqueID()..".txt", encoded);
	end;

	function playerMeta:RestoreMailBox()
		local content = file.Read("pistachio/mailbox/"..self:UniqueID()..".txt", "DATA");

		if (content) then
			local decoded = util.JSONToTable(content);

			for k, v in pairs(decoded) do
				for k2, v2 in pairs(v) do
					if (v2.arrival and v2.quantity) then
						local arrivalTime = v2.arrival - os.time();
						local quantity = v2.quantity;

						if (arrivalTime > 0) then
							self:AddMailBoxItem(k, quantity, arrivalTime);
						else
							self:AddMailBoxItem(k, quantity);
						end;
					end;
				end;
			end;
		end;
	end;

	function playerMeta:AddMailBoxItem(uniqueID, quantity, arrivalTime)
		if (!quantity) then
			quantity = 1;
		end;

		if (!arrivalTime) then
			arrivalTime = 0;
		end;

		if ( !pistachio.item:Get(uniqueID) ) then
			return;
		end;

		self.mailBox = self.mailBox or {};
		self.mailBox[uniqueID] = self.mailBox[uniqueID] or {};

		if (type( self.mailBox[uniqueID] ) != "table") then
			self.mailBox[uniqueID] = nil;
		end;

		local index = table.insert( self.mailBox[uniqueID], {
			arrival = os.time() + arrivalTime,
			quantity = quantity
		} );

		net.Start("ps_MailBoxItemAdd");
			net.WriteString(uniqueID);
			net.WriteUInt(index, 8);
			net.WriteUInt(arrivalTime, 16);
			net.WriteUInt(quantity, 16);
		net.Send(self);

		hook.Call("PlayerSaveData", GAMEMODE, self, false, true);
	end;

	function playerMeta:GetMailBoxAmount(uniqueID, id)
		local count = 0;
		local mailTable = self.mailBox[uniqueID];

		if (!id) then
			if (mailTable) then
				for k, v in pairs(mailTable) do
					if ( ( (v.arrival or 0) - os.time() ) <= 0 ) then
						count = count + v.quantity;
					end;
				end;
			end;
		elseif (mailTable) then
			local item = mailTable[id];

			if (item) then
				if ( (item.arrival or 0) - os.time() <= 0 ) then
					return item.quantity or 0;
				end;
			end;

			return 0;
		end;

		return count;
	end;

	function playerMeta:GetMailBox()
		return self.mailBox or {};
	end;
else
	pistachio.mailBox = pistachio.mailBox or {};

	net.Receive("ps_MailBoxItemAdd", function(length)
		local uniqueID = net.ReadString();
		local index = net.ReadUInt(8);
		local delay = net.ReadUInt(16);
		local quantity = net.ReadUInt(16);

		pistachio.mailBox[uniqueID] = pistachio.mailBox[uniqueID] or {};
		pistachio.mailBox[uniqueID][index] = {
			arrival = os.time() + delay,
			quantity = quantity
		}
	end);

	net.Receive("ps_MailBoxItemTake", function(length)
		local uniqueID = net.ReadString();
		local index = net.ReadUInt(8);

		if ( pistachio.mailBox[uniqueID] ) then
			pistachio.mailBox[uniqueID][index] = nil;
		end;
	end);

	function playerMeta:GetMailBoxAmount(uniqueID)
		local count = 0;
		local mailTable = pistachio.mailBox[uniqueID];

		if (mailTable) then
			for k, v in pairs(mailTable) do
				if ( ( (v.arrival or 0) - os.time() ) <= 0 ) then
					count = count + v.quantity;
				end;
			end;
		end;

		return count;
	end;

	function playerMeta:GetMailBox()
		return pistachio.mailBox or {};
	end;
end;