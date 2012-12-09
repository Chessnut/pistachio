local MODULE = MODULE;

pistachio.stocks = pistachio.stocks or {};

function MODULE:GetItemStock(uniqueID, allowNull)
	if ( pistachio.stocks[uniqueID] ) then
		local itemTable = pistachio.item:Get(uniqueID);

		if (itemTable) then
			local value = math.Clamp(pistachio.stocks[uniqueID], 0, itemTable.stockLimit);

			return value;
		end;
	elseif (!allowNull) then
		return 0;
	end;
end;

pistachio.command:Create("setitemstock", "<uniqueID> <amount>", "Set the stock of an item", function(client, arguments)
	local uniqueID = tostring( arguments[1] );
	local amount = tonumber( arguments[2] );

	if (uniqueID) then
		local itemTable = pistachio.item:Get(uniqueID);

		if (itemTable) then
			if (amount) then
				MODULE:SetItemStock(itemTable, amount);

				for k, v in pairs( player.GetAll() ) do
					v:Notify(client:Name().." has changed the "..itemTable.name.."'s stock to "..amount..".");
				end;
			else
				client:Notify("The amount is not valid!");
			end;
		else
			client:Notify("That is not a valid item!");
		end;
	else
		client:Notify("A unique ID was not specified!");
	end;
end, true, "superadmin");