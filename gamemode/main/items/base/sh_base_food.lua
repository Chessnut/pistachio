local ITEM = {};

ITEM.isBase = true;
ITEM.baseID = "base_food";
ITEM.stockLimit = 10;
ITEM.category = "Nourishments";
ITEM.weight = 0.5;
ITEM.restore = 5;
ITEM.staminaRestore = 10;

function ITEM:OnUse(entity, client)
	local health = client:Health();
	local maxHealth = client:GetMaxHealth();
	local restore = self.restore or 0;
	local staminaRestore = self.staminaRestore or 0;

	if (restore > 0) then
		if (health + restore <= maxHealth) then
			client:SetHealth(health + restore);
		else
			client:Notify("You don't need to consume this right now.");

			return false;
		end;
	end;

	if (staminaRestore > 0) then
		local stamina = client:GetPrivateVar("stamina") or 0;
		local value = math.Clamp(stamina + staminaRestore, 0, 100);

		client:SetPrivateVar("stamina", value);
	end;
end;

pistachio.item:Register(ITEM);