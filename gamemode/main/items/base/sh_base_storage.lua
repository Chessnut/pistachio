local ITEM = {};

ITEM.isBase = true;
ITEM.baseID = "base_storage";
ITEM.weight = 0.5;
ITEM.stockLimit = 25;
ITEM.category = "Storage";
ITEM.maxWeight = 5;

function ITEM:OnUse(entity, client)
	local trace = client:GetEyeTrace();

	if (trace) then
		local position = trace.HitPos + Vector(0, 0, 8);

		if (position:Distance( client:GetPos() ) > 72) then
			position = client:GetShootPos() + (client:GetAimVector() * 72);
		end;

		local crate = ents.Create("pistachio_crate");
		crate:SetPos(position);
		crate:Spawn();
		crate:Activate();
		crate:SetItem(self.uniqueID);
		crate:GiveAccess(client, true);
		crate:SetMaxWeight(self.maxWeight);
		
		local physicsObject = crate:GetPhysicsObject();

		if ( IsValid(physicsObject) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;

	entity:Remove();
end;

pistachio.item:Register(ITEM);