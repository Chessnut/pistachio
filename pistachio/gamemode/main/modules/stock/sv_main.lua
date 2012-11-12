local MODULE = MODULE;

pistachio.stockDates = pistachio.stockDates or {};

util.AddNetworkString("ps_StockData");

include("sh_main.lua");
AddCSLuaFile("sh_main.lua");

hook.Add("CanPlayerOrderItem", "ps_StockCheck", function(client, itemTable)
	if (itemTable.stockLimit) then
		local uniqueID = itemTable.uniqueID;
		local stock = MODULE:GetItemStock(uniqueID) - 1;

		if (stock >= 0) then
			return true;
		else
			client:Notify("This item isn't in stock!");

			return false;
		end;
	end;
end);

hook.Add("PlayerOrderItem", "ps_LowerStock", function(client, itemTable)
	if (itemTable.stockLimit) then
		local uniqueID = itemTable.uniqueID;
		local stock = MODULE:GetItemStock(uniqueID) - 1;

		MODULE:SetItemStock(itemTable, stock);
	end;
end);

hook.Add("Tick", "ps_StockThink", function()
	for k, v in pairs(pistachio.stockDates) do
		local itemTable = pistachio.item:Get(k);

		if (itemTable and itemTable.stockLimit) then
			if ( v < os.time() ) then
				local currentStock = MODULE:GetItemStock(k);
				local date = ( (itemTable.fillDay or 1) * 86400 ) + v;
				local amount = itemTable.fillAmount or math.random(1, 3);

				MODULE:SetItemStock(itemTable, currentStock + amount, date);
			end;
		end;			
	end;
end);

function MODULE:SetItemStock(itemTable, amount, stockDate, noSave)
	if (itemTable.stockLimit) then
		local uniqueID = itemTable.uniqueID;
		local value = math.Clamp(amount, 0, itemTable.stockLimit);

		pistachio.stocks[uniqueID] = value;
		pistachio.stockDates[uniqueID] = stockDate;

		net.Start("ps_StockData");
			net.WriteTable(pistachio.stocks);
		net.Broadcast();

		if (itemTable.basePrice and itemTable.price) then
			local stock = self:GetItemStock(uniqueID);
			local percentage = (itemTable.stockLimit - stock) / itemTable.stockLimit;
			local price = math.floor( itemTable.basePrice + (itemTable.basePrice * percentage) );

			pistachio.item:SetPrice(uniqueID, price);
		end;

		if (!noSave) then
			self:SaveStocks();
		end;
	end;
end;

function MODULE:SaveStocks()
	local data = {};

	for k, v in pairs(pistachio.item.stored) do
		if (v.stockLimit) then
			local uniqueID = v.uniqueID;
			local stockDate = os.time() + ( (v.fillDay or 1) * 86400 );
			local stock = self:GetItemStock(uniqueID);

			if ( pistachio.stockDates[uniqueID] ) then
				stockDate = pistachio.stockDates[uniqueID];
			end;

			data[#data + 1] = {
				uniqueID = uniqueID,
				stock = stock,
				stockDate = stockDate
			};
		end;
	end;

	pistachio.persist:PersistData("stock", data, true);
end;

function MODULE:LoadStocks()
	local info = pistachio.persist:GetData("stock", true);

	if (info) then
		for k, v in pairs(info) do
			local uniqueID = v.uniqueID;
			local stock = v.stock;
			local stockDate = v.stockDate or os.time();
			local itemTable = pistachio.item:Get(uniqueID);

			self:SetItemStock(itemTable, stock, stockDate, true);
		end;
	end;

	for k, itemTable in pairs(pistachio.item.stored) do
		if (itemTable.stockLimit) then
			local uniqueID = itemTable.uniqueID;
			local fillDate = ( (itemTable.fillDay or 1) * 86400 ) + os.time();

			if ( !self:GetItemStock(uniqueID, true) ) then
				self:SetItemStock(itemTable, 5, fillDate);
			end;
		end;
	end;
end;

hook.Add("InitPostEntity", "ps_LoadStockData", function()
	MODULE:LoadStocks();
end);