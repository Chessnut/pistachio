AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "Mailbox";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props/cs_militia/mailbox01.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_NONE);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
	end;
end;

function ENT:Use(activator, caller)
	if (SERVER) then
		net.Start("ps_MailBoxPanel");
		net.Send(activator);
	end;
end;