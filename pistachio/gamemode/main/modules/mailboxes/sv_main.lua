local MODULE = MODULE;

include("sh_commands.lua");
AddCSLuaFile("sh_commands.lua");

MODULE.mailBoxes = MODULE.mailBoxes or {};

function MODULE:SaveMailBoxes()
	local data = {};

	for k, v in pairs(self.mailBoxes) do
		if ( IsValid(v) ) then
			local position = v:GetPos();
			local angle = v:GetAngles();

			data[#data + 1] = {
				position = position,
				angle = angle
			};
		end;
	end;

	pistachio.persist:PersistData("mailbox", data, false, true);
end;

function MODULE:CreateMailBox(position, angle)
	local entities = ents.FindInSphere(position, 8);

	for k, v in pairs(entities) do
		if (v:GetClass() == "pistachio_mailbox") then
			return;
		end;
	end;
	
	local entity = ents.Create("pistachio_mailbox");
	entity:SetAngles(angle);
	entity:SetPos( position + Vector(0, 0, 8) );
	entity:Spawn();
	entity:Activate();
	entity:DropToFloor();

	local physicsObject = entity:GetPhysicsObject();

	if ( IsValid(physicsObject) ) then
		physicsObject:EnableMotion(false);
	end;

	self.mailBoxes[#self.mailBoxes + 1] = entity;

	return IsValid(entity);
end;

function MODULE:LoadMailBoxes()
	local mailBoxes = pistachio.persist:GetData("mailbox");

	if (mailBoxes) then
		for k, v in pairs(mailBoxes) do
			self:CreateMailBox(v.position, v.angle);
		end;
	end;
end;

hook.Add("InitPostEntity", "ps_LoadMailBoxes", function()
	timer.Simple(5, function()
		MODULE:LoadMailBoxes();
	end);
end);