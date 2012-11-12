local ITEM = {};

ITEM.name = "Rope";
ITEM.weight = 0.5;
ITEM.uniqueID = "rope";
ITEM.model = "models/props_lab/pipesystem03d.mdl";
ITEM.description = "Rope that can tie people and such.";
ITEM.price = 500;
ITEM.stockLimit = 10;

function ITEM:OnUse(itemEntity, client)
	client:EmitSound("npc/barnacle/barnacle_tongue_pull3.wav");

	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) ) then
		if (entity:IsPlayer() and entity:GetPos():Distance( client:GetPos() ) <= 256) then
			local oldPosition = client:GetPos();

			timer.Simple(1.5, function()
				if (IsValid(entity) and oldPosition:Distance( client:GetPos() ) <= 5) then
					local tiedWeapons = {};

					for k, v in pairs( entity:GetWeapons() ) do
						tiedWeapons[#tiedWeapons + 1] = v:GetClass();
					end;

					entity.tiedWeapons = tiedWeapons;
					entity:StripWeapons();
					entity:EmitSound("npc/combine_soldier/gear1.wav");
					entity:SetPublicVar("tied", true);
				else
					client:Notify("You need to stand still while tieing!");

					return false;
				end;
			end);
		else
			client:Notify("You're not in range of a player!");

			return false;
		end;
	else
		client:Notify("You need to aim at a player!");

		return false;
	end;
end;

pistachio.item:Register(ITEM);