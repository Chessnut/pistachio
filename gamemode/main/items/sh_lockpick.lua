local ITEM = {};

ITEM.name = "Lockpick";
ITEM.weight = 1;
ITEM.uniqueID = "lockpick";
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.description = "A bar that is used to lockpick stuff.";
ITEM.price = 500;
ITEM.stockLimit = 10;
ITEM.category = "Miscellaneous";

function ITEM:OnUse(entity, client)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) and entity:IsDoor() or entity:IsVehicle() ) then
		local distance = entity:GetPos():Distance( client:GetPos() );

		if (distance > 128) then
			client:Notify("You're too far away to use the lockpick!");

			return false;
		end;
			
		if (entity.isSeat) then
			local parent = entity:GetParent();

			if ( IsValid(parent) and parent:IsVehicle() ) then
				entity = parent;
			end;
		end;
		
		if ( IsValid(entity.picker) ) then
			client:Notify("Someone is already picking this entity!");

			return false;
		end;

		entity.picker = client;

		net.Start("ps_LockPickPanel");
			net.WriteEntity(entity);
		net.Send(client);
	else
		client:Notify("This isn't a valid entity!");

		return false;
	end;
end;

pistachio.item:Register(ITEM);