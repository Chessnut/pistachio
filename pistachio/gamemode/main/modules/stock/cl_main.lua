if (SERVER) then return; end;

local MODULE = MODULE;

include("sh_main.lua");

net.Receive("ps_StockData", function(length)
	pistachio.stocks = net.ReadTable() or {};
end);

hook.Add("GetMarketItemName", "ps_StockItemNames", function(itemTable)
	if (itemTable.stockLimit) then
		local stock = MODULE:GetItemStock(itemTable.uniqueID);

		return itemTable.name.." (Stock: "..stock..")";
	end;
end);

hook.Add("ShouldEnableOrderButton", "ps_StockButton", function(itemTable)
	if (itemTable.stockLimit) then
		local stock = MODULE:GetItemStock(itemTable.uniqueID);

		return (stock > 0);
	end;
end);