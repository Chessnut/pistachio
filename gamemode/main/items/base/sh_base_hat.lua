local ITEM = {};

ITEM.isBase = true;
ITEM.weight = 0.1;
ITEM.baseID = "base_hat";
ITEM.category = "Apparel";
ITEM.scale = 1;
ITEM.stockLimit = 5;
ITEM.weight = 0.1;

function ITEM:OnUse(entity, client)
	pistachio.hats:Give(client, self.uniqueID);

	if (SERVER) then
		client:SetPrivateVar("hat", self.uniqueID);
	end;

	return false, false;
end;

function ITEM:OnDrop(entity, client)
	if (client:GetPrivateVar("hat") and client:GetPrivateVar("hat") == self.uniqueID) then
		if ( IsValid(client.hat) ) then
			client.hat:Remove();
		end;

		client:SetPrivateVar("hat", nil);
	end;
end;

pistachio.item:Register(ITEM);