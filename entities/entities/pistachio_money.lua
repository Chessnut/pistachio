AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "Money";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Money");
end;

util.PrecacheModel("models/props/cs_assault/money.mdl");

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props/cs_assault/money.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		self:SetMoney(0);

		local physicsObject = self:GetPhysicsObject();

		if ( IsValid(physicsObject) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;
end;

function ENT:StartTouch(entity)
	if (SERVER) then
		if (IsValid(entity) and entity:GetClass() == self.ClassName) then
			local amount = entity:GetMoney();
			local money = self:GetMoney();

			self:SetMoney(money + amount);

			entity:Remove();
		end;
	end;
end;

function ENT:Use(activator, caller)
	if (SERVER) then
		if ( IsValid(activator) and activator:IsPlayer() ) then
			local money = activator:GetPrivateVar("money");
			local amount = self:GetMoney() or 0;

			activator:SetPrivateVar("money", money + amount);
			activator:Notify("You've picked up $"..amount.." dollars.");

			self:Remove();
		end;
	end;
end;