AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "Note";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_c17/paper01.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
	end;
end;

function ENT:Use(activator, caller)
	if (activator:KeyDown(IN_SPEED) and IsValid(self.owner) and self.owner == activator) then
		activator:AddItem("paper");

		self:Remove();

		return;
	end;

	activator:ChatPrint(self.text);
end;