pistachio.hats = pistachio.hats or {};

function pistachio.hats:Give(client, uniqueID)
	if ( IsValid(client.hat) ) then
		SafeRemoveEntity(client.hat);
	end;

	local itemTable = pistachio.item:Get(uniqueID);

	if (itemTable) then
		local entity = ents.Create("pistachio_hat");
		entity:SetPos( client:GetPos() );
		entity:Spawn();
		entity:Activate();
		entity:SetOwner(client);
		entity:SetModel(itemTable.model);
		entity:SetUniqueID(uniqueID);
		
		client:DeleteOnRemove(entity);
		client.hat = entity;

		if ( IsValid(client.hat) ) then
			if (itemTable.LayoutEntity) then
				itemTable:LayoutEntity(client.hat);
			end;
		end;
	end;
end;