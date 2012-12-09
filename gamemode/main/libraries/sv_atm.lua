local _R = debug.getregistry();
local playerMeta = _R.Player;

util.AddNetworkString("ps_ATMAction");
util.AddNetworkString("ps_ATMConsoleText");

net.Receive("ps_ATMAction", function(length, client)
	if ( !IsValid(client) ) then
		return;
	end;

	local action = net.ReadString();
	local text = net.ReadString();
	local amount = tonumber(text);
	local entities = ents.FindInSphere(client:GetPos(), 64);
	local foundMachine;

	for k, v in pairs(entities) do
		if (v:GetClass() == "pistachio_atm") then
			foundMachine = true;
		end;
	end;

	if (!foundMachine) then
		return;
	end;

	amount = math.floor(amount);

	if (amount) then
		if (amount < 1) then
			client:SendBankText("Value must be more than 0.");

			return;
		end;

		if (action == "deposit") then
			local money = client:GetPrivateVar("money") or 0;

			if (money - amount >= 0) then
				client:SetPrivateVar("money", money - amount);
				client:SendBankText("Deposited $"..amount.." dollars.");

				local bank = client:GetPrivateVar("bank") or 0;

				client:SetPrivateVar("bank", bank + amount);
			else
				client:SendBankText("Not enough money!");
			end;
		elseif (action == "withdraw") then
			local money = client:GetPrivateVar("money") or 0;
			local bank = client:GetPrivateVar("bank") or 0;

			if (bank - amount >= 0) then
				client:SetPrivateVar("money", money + amount);
				client:SendBankText("Withdrew $"..amount.." dollars.");

				client:SetPrivateVar("bank", bank - amount);
			else
				client:SendBankText("Not enough money!");
			end;
		end;
	else
		client:SendBankText("Invalid amount!");
	end;
end);

function playerMeta:SendBankText(text)
	net.Start("ps_ATMConsoleText");
		net.WriteString(text);
	net.Send(self);
end;