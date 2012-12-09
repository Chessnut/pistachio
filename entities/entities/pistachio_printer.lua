AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "Printer";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_c17/consolebox03a.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
	end;
end;

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Power");
	self:NetworkVar("Int", 1, "NextBeep");
	self:NetworkVar("Int", 2, "PrinterHealth");
	self:NetworkVar("Int", 3, "NextPower");
	self:NetworkVar("Int", 4, "NextMoney")
end;

if (SERVER) then
	function ENT:Use(activator, caller)
		if ( (self.nextPress or 0) < CurTime() ) then			
			if (activator:Team() == TEAM_POLICE) then
				self:SetPower( math.Clamp(self:GetPower() - 1, 0, 5) );
				self:EmitSound("npc/roller/mine/rmine_taunt2.wav");
				self.nextPress = CurTime() + 15;

				return;
			elseif (self:GetPower() < 5) then
				self:EmitSound("npc/scanner/scanner_siren1.wav");
				self:SetPower( math.Clamp(self:GetPower() + 1, 0, 5) );
				self.nextPress = CurTime() + 10;
			end;
		end;
	end;

	function ENT:Think()
		if ( (self:GetNextBeep() or 0) <= CurTime() ) then
			self:EmitSound("npc/scanner/combat_scan2.wav");
			self:SetNextBeep(CurTime() + 5);
		end;

		if ( self:GetNextPower() < CurTime() ) then
			self:EmitSound("npc/roller/mine/rmine_taunt1.wav");
			self:SetPower( math.Clamp(self:GetPower() - 1, 0, 5) );

			if (self:GetPower() < 1) then
				self:Ignite(10);
			else
				self:SetPrinterHealth( math.Clamp(self:GetPrinterHealth() + 10, 0, 50) );
			end;

			self:SetNextPower(CurTime() + 60);
		end;

		if (!self.nextMoney) then
			self.nextMoney = CurTime() + 180;
		end;

		if ( self.nextMoney < CurTime() ) then
			if (self:GetPower() > 0) then
				local money = ents.Create("pistachio_money");
				money:SetPos( self:GetPos() + Vector(0, 0, 8) );
				money:SetSolid(SOLID_VPHYSICS);
				money:SetMoveType(MOVETYPE_VPHYSICS);
				money:PhysicsInit(SOLID_VPHYSICS);
				money:SetUseType(SIMPLE_USE);
				money:Spawn();
				money:SetMoney( (self:GetPower() * 10) + math.random(0, 25) );

				self:EmitSound("npc/roller/mine/rmine_blades_out"..math.random(1, 3)..".wav");
			end;

			self.nextMoney = CurTime() + ( 300 - (self:GetPower() * 10) );
		end;

		self:NextThink(1);
	end;

	function ENT:OnTakeDamage(damageInfo)
		self:TakePhysicsDamage(damageInfo);

		if (self:GetPrinterHealth() < 1) then
			return;
		end;

		self:SetPrinterHealth( self:GetPrinterHealth() - damageInfo:GetDamage() );
		self:EmitSound("npc/roller/mine/rmine_chirp_quest1.wav");

		if (self:GetPrinterHealth() < 1) then
			local attacker = damageInfo:GetAttacker();

			if ( IsValid(attacker) and attacker:IsPlayer() ) then
				if (attacker:Team() != TEAM_POLICE) then
					local karma = attacker:GetPrivateVar("karma") or 0;

					attacker:SetPrivateVar("karma", karma + 1);
					attacker:Notify("You've gained karma for destroying a printer.");
				else
					local money = attacker:GetPrivateVar("money") or 0;

					attacker:SetPrivateVar("money", money + 50);
					attacker:Notify("You've gained $50 dollars for destroying a printer.");
				end;
			end;

			local explosion = ents.Create("env_explosion");
			explosion:SetOwner(self);
			explosion:SetPos( self:GetPos() );
			explosion:Spawn();
			explosion:SetKeyValue("iMagnitude", "16");
			explosion:Fire("Explode");

			self:Remove();
		end;
	end;
else
	local randomNumber = math.random(111111111, 999999999);
	local nextRandomNumber = 0;

	function ENT:Draw()
		self:DrawModel();

		local angles = self:GetAngles();
		local position = self:GetPos();
		local offset = angles:Up() * 7.35 + angles:Forward() * 10.15 + angles:Right() * -3.71;

		angles:RotateAroundAxis(angles:Forward(), 0);
		angles:RotateAroundAxis(angles:Right(), 270);
		angles:RotateAroundAxis(angles:Up(), 90);

		cam.Start3D2D(position + offset, angles, 0.1);
			surface.SetDrawColor(75, 75, 75, 255);
			surface.DrawRect(0, 0, 70, 55);

			surface.SetDrawColor(25, 25, 25, 255);
			surface.DrawRect(1, 1, 68, 53);

			local fraction = self:GetNextBeep() - CurTime();

			draw.SimpleText("Power: "..self:GetPower(), "ps_HUDFont", 4, 2, Color(255, 255, 255, 255), 0, 2);

			surface.SetDrawColor(0, 0, 0, 255);
			surface.DrawRect(4, 19, 62, 6);

			surface.SetDrawColor(255, 0, 0, 255);
			surface.DrawRect(5, 20, math.Clamp(60 - (fraction * 12), 0, 60), 4);

			surface.SetDrawColor(0, 0, 0, 255);
			surface.DrawRect(4, 27, 62, 6);

			surface.SetDrawColor(0, 255, 0, 255);
			surface.DrawRect(5, 28, math.Clamp(60 * (self:GetPrinterHealth() / 50), 0, 60), 4);

			surface.SetDrawColor(0, 0, 0, 255);
			surface.DrawRect(4, 35, 62, 6);

			surface.SetDrawColor(255, 255, 0, 255);
			surface.DrawRect(5, 36, math.Clamp(60 - ( self:GetNextPower() - CurTime() ), 0, 60), 4);

			if ( nextRandomNumber < CurTime() ) then
				randomNumber = math.random(111111111, 999999999);

				nextRandomNumber = CurTime() + math.Rand(0.15, 1);
			end;

			draw.SimpleText(randomNumber, "ps_HUDFont", 4, 41, Color(255, 255, 255, 100), 0, 2)
		cam.End3D2D();
	end;
end;