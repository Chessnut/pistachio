local ITEM = {};

ITEM.name = "Money Printer";
ITEM.weight = 1.5;
ITEM.uniqueID = "printer";
ITEM.model = "models/props_c17/consolebox03a.mdl";
ITEM.description = "A printer that prints fake currency.";
ITEM.price = 500;
ITEM.stockLimit = 15;
ITEM.category = "Contraband";

function ITEM:OnUse(entity, client)
	local trace = client:GetEyeTrace();

	if (trace) then
		local position = trace.HitPos + Vector(0, 0, 8);

		if (position:Distance( client:GetPos() ) > 72) then
			position = client:GetShootPos() + (client:GetAimVector() * 72);
		end;

		local printer = ents.Create("pistachio_printer");
		printer:SetPos(position);
		printer:Spawn();
		printer:Activate();
		printer:SetPower(5);
		printer:SetNextBeep(CurTime() + 5);
		printer:SetPrinterHealth(50);
		printer:SetNextPower(CurTime() + 60);
		printer:SetNextMoney(CurTime() + 300);
		printer:GiveAccess(client, true);

		local karma = client:GetPrivateVar("karma") or 0;

		client:SetPrivateVar("karma", karma - 1);
		client:Notify("You've lost karma for using a money printer.");
		
		local physicsObject = printer:GetPhysicsObject();

		if ( IsValid(physicsObject) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;

	entity:Remove();
end;

pistachio.item:Register(ITEM);