local MODULE = MODULE;

include("sh_commands.lua");
AddCSLuaFile("sh_commands.lua");

MODULE.atm = MODULE.atm or {};

function MODULE:SaveATM()
	local data = {};

	for k, v in pairs(self.atm) do
		if ( IsValid(v) ) then
			local position = v:GetPos();
			local angle = v:GetAngles();

			data[#data + 1] = {
				position = position,
				angle = angle
			};
		end;
	end;

	pistachio.persist:PersistData("atm", data, false, true);
end;

function MODULE:CreateATM(position, angle)
	local entities = ents.FindInSphere(position, 8);

	for k, v in pairs(entities) do
		if (v:GetClass() == "pistachio_atm") then
			return;
		end;
	end;
	
	local entity = ents.Create("pistachio_atm");
	entity:SetAngles(angle);
	entity:SetPos( position + Vector(0, 0, 16) );
	entity:SetMoveType(MOVETYPE_NONE);
	entity:Spawn();
	entity:Activate();
	entity:DropToFloor();

	local physicsObject = entity:GetPhysicsObject();

	if ( IsValid(physicsObject) ) then
		physicsObject:Sleep();
		physicsObject:EnableMotion(false);
	end;

	self.atm[#self.atm + 1] = entity;

	return IsValid(entity);
end;

function MODULE:LoadATM()
	for k, v in pairs( ents.FindByClass("pistachio_atm") ) do
		v:Remove();
	end;

	local atm = pistachio.persist:GetData("atm");

	if (atm) then
		for k, v in pairs(atm) do
			self:CreateATM(v.position, v.angle);
		end;
	end;
end;

timer.Simple(5, function()
	MODULE:LoadATM();
end);
