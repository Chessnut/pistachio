AddCSLuaFile();

if (CLIENT) then
	SWEP.PrintName = "Baton";
	SWEP.Slot = 1;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;
end;

SWEP.Author = "Chessnut";
SWEP.Purpose = "Protect the society.";
SWEP.Instructions = "Primary Fire: Strike.\nPrimary + Sprint: Arrest.\nSecondary Fire: Push/Breach.\nSecondary + Sprint: Unarrest";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;
SWEP.ViewModel = "models/weapons/v_stunstick.mdl";
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl";
SWEP.Weight = 2;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;

function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
end;

function SWEP:PrimaryAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:SendWeaponAnim(ACT_VM_HITCENTER);

	if (SERVER) then
		local trace = self.Owner:GetEyeTraceNoCursor();
		local entity = trace.Entity;
		local distance = trace.HitPos:Distance( self.Owner:GetPos() );

		if ( IsValid(entity) ) then
			if ( self.Owner:KeyDown(IN_SPEED) ) then
				if (distance <= 128) then
					if (entity:IsPlayer() and entity:Team() == TEAM_CITIZEN) then
						if ( (entity.lastArrest or 0) < CurTime() ) then
							if ( entity:GetPublicVar("warranted") ) then
								entity.loadout = {};

								for k, v in pairs( entity:GetWeapons() ) do
									entity.loadout[#entity.loadout + 1] = v:GetClass();
								end;

								entity:StripWeapons();
								entity:SetArrested(true);
								entity.lastArrest = CurTime() + 300;
							else
								local karma = self.Owner:GetPrivateVar("karma") or 0;

								self.Owner:SetPrivateVar("karma", karma - 1);
								self.Owner:Notify("You've lost karma for arresting someone without a warrant.");

								entity.loadout = {};

								for k, v in pairs( entity:GetWeapons() ) do
									entity.loadout[#entity.loadout + 1] = v:GetClass();
								end;

								entity:StripWeapons();
								entity:SetArrested(true);
								entity.lastArrest = CurTime() + 300;
							end;
						else
							self.Owner:Notify(entity:Name().." has been arrested earlier.");
						end;
					else
						self.Owner:Notify("You can only arrest citizens.");
					end;
				end;
			elseif (distance <= 72) then
				local bounds = Vector(0, 0, 0);
				local start = self.Owner:GetShootPos();
				local finish = start + (self.Owner:GetAimVector() * 72);
				local trace2 = util.TraceLine( {
					filter = self.Owner,
					start = start,
					endpos = finish
				} );
				
				if ( IsValid(trace2.Entity) ) then
					local damage = 15;

					if ( trace2.Entity:IsVehicle() ) then
						damage = damage / 1000;
					end;

					trace2.Entity:TakeDamage(damage, self.Owner, self);
				end;
				
				self:EmitSound("weapons/crossbow/hitbod2.wav");
			end;
		elseif (trace.HitWorld and distance <= 72) then
			self.owner:EmitSound("weapons/crossbow/hitbod2.wav");
		end;

		self.Owner:EmitSound("npc/vort/claw_swing2.wav");
	end;

	self:SetNextPrimaryFire(CurTime() + 1.5);
end;

function SWEP:SecondaryAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	self:SendWeaponAnim(ACT_VM_MISSCENTER);

	if (SERVER) then
		local trace = self.Owner:GetEyeTraceNoCursor();
		local entity = trace.Entity;

		if ( IsValid(entity) ) then
			local distance = entity:GetPos():Distance( self.Owner:GetPos() );

			if ( self.Owner:KeyDown(IN_SPEED) ) then
				if (distance <= 128) then
					if ( entity:IsPlayer() and entity:IsArrested() ) then
						if (entity.loadout) then
							for k, v in pairs(entity.loadout) do
								entity:Give(v);
							end;
						end;

						entity:SetArrested(false);

						timer.Destroy( "ps_Arrest"..entity:EntIndex() );
					else
						self.Owner:Notify("This person isn't arrested!");
					end;
				end;
			elseif (distance <= 108) then
				if ( entity:IsDoor() ) then
					local owner = entity:GetAccessOwner();

					if ( !IsValid(owner) or ( IsValid(owner) and !owner:GetPublicVar("warranted") ) ) then
						local karma = self.Owner:GetPrivateVar("karma") or 0;

						self.Owner:SetPrivateVar("karma", karma - 1);
						self.Owner:Notify("You've lost karma for trying to breach an unwarranted door!");
						self:SetNextSecondaryFire(CurTime() + 1.5);
					end;

					local chance = math.random(1, 10);

					if (chance == 2) then
						local effect = EffectData();
						effect:SetOrigin( entity:LocalToWorld( entity:OBBCenter() ) );

						util.Effect("Explosion", effect);

						entity:EmitSound("physics/wood/wood_crate_break"..math.random(1, 5)..".wav");
						entity:Fire("Unlock");
						entity:Fire("Open");
						entity.locked = false;
					else
						entity:EmitSound("physics/wood/wood_panel_impact_hard1.wav");
					end;
				end;

				local physicsObject = entity:GetPhysicsObject();

				if ( IsValid(physicsObject) ) then
					if ( entity:IsPlayer() ) then
						local normal = ( entity:GetPos() - self.Owner:GetPos() ):GetNormal();
						local push = 320 * normal;
						
						entity:SetVelocity(push);
					else
						physicsObject:ApplyForceCenter(self.Owner:GetAimVector() * 5012);
					end;

					entity:EmitSound("weapons/crossbow/hitbod2.wav");
				end;
			end;
		end;
	end;

	self:SetNextSecondaryFire(CurTime() + 1.5);
end;