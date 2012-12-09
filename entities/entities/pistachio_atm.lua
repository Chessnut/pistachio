AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "ATM";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props/de_nuke/equipment1.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_NONE);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
	end;
end;

function ENT:Use(activator, caller)
	if (SERVER) then
		net.Start("ps_ATMPanel");
		net.Send(activator);
	end;
end;

if (CLIENT) then
	surface.CreateFont( "ps_ATMDisplayFontBlur", {
		font = "Tahoma",
		size = 65,
		weight = 800,
		antialias = true,
		blursize = 12
	} );

	surface.CreateFont( "ps_ATMDisplayFont", {
		font = "Tahoma",
		size = 65,
		weight = 800,
		antialias = true
	} );

	function ENT:Draw()
		self:DrawModel();

		local angles = self:GetAngles();
		local position = self:GetPos();
		local offset = angles:Up() * 83 + angles:Forward() * 7.6 + angles:Right() * -8;

		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 180);
		angles:RotateAroundAxis(angles:Up(), 0);

		cam.Start3D2D(position + offset, angles, 0.1);
			surface.SetDrawColor(5, 25, 175, 255);
			surface.DrawRect(0, 0, 161, 92);

			draw.SimpleText("ATM", "ps_ATMDisplayFontBlur", 80.5, 46, Color(255, 255, 255, math.cos(CurTime() * 1) * 255), 1, 1);
			draw.SimpleText("ATM", "ps_ATMDisplayFont", 80.5, 46, Color(255, 255, 255, 255), 1, 1);
		cam.End3D2D();
	end;
end;