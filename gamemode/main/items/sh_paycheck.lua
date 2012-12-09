local ITEM = {};

ITEM.name = "Paycheck";
ITEM.uniqueID = "paycheck";
ITEM.weight = 0.1;
ITEM.model = "models/props/cs_assault/Money.mdl";
ITEM.description = "Some money you earned in a bundle.";
ITEM.preventBuy = true;
ITEM.category = "Miscellaneous";

function ITEM:OnUse(entity, client)
	client:Notify("You've collected $50 dollars!");

	local money = client:GetPrivateVar("money") or 0;
	client:SetPrivateVar("money", money + 50);
end;

function ITEM:MailBoxUse(client, quantity)
	local pay = quantity * 50;

	client:Notify("You've collected $"..pay.." dollars!");

	local money = client:GetPrivateVar("money") or 0;
	client:SetPrivateVar("money", money + pay);

	return false;
end;

pistachio.item:Register(ITEM);