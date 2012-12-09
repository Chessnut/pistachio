local ITEM = {};

ITEM.isBase = true;
ITEM.baseID = "base_alcohol";
ITEM.stockLimit = 10;
ITEM.category = "Alcohol";
ITEM.weight = 1;

function ITEM:OnUse(entity, client)
	local health = client:Health();
	local drunkness = self.drunkness or 0;
	local damage = self.damage or 0;

	if (drunkness > 0) then
		local drunk = client:GetPrivateVar("drunk") or 0;
		local value = drunk + drunkness;

		client:SetPrivateVar("drunk", value);

		timer.Simple(120, function()
			if ( IsValid(client) ) then
				local drunk = client:GetPrivateVar("drunk") or 0;
				local value = math.max(drunk - drunkness, 0);

				client:SetPrivateVar("drunk", value);
			end;
		end);
	end;

	if (damage > 0) then
		if (health - damage < 1) then
			client:Kill();
		else
			client:SetHealth(health - damage);
		end;
	end;
end;

pistachio.item:Register(ITEM);