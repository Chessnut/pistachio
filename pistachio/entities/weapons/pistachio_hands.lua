AddCSLuaFile();

if (CLIENT) then
	SWEP.PrintName = "Hands";
	SWEP.Slot = 1;
	SWEP.SlotPos = 2;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;
end;

SWEP.Author = "Chessnut";
SWEP.Purpose = "Interact with the world.";
SWEP.Instructions = "Primary Fire: Punch.\nPrimary + Sprint: Lock.\nSecondary Fire: Knock.\nSecondary + Sprint: Unlock.";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;
SWEP.ViewModel = "";
SWEP.WorldModel = "";
SWEP.Weight = 1;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;

function SWEP:Initialize()
	if ( IsValid(self) ) then
		self:SetWeaponHoldType("normal");
	end;
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
				if (distance <= 72) then
					if ( ( entity:IsDoor() or entity:IsVehicle() ) and entity:HasAccess(self.Owner) ) then
						self.Owner:EmitSound("doors/door_latch3.wav");

						entity:Lock();
						entity.locked = true;
					else
						self.Owner:Notify("You don't have access to this entity!");
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
					local damage = 10;

					if ( trace2.Entity:IsVehicle() ) then
						damage = 0.5 / 1000;
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

	if (SERVER) then
		local trace = self.Owner:GetEyeTraceNoCursor();
		local entity = trace.Entity;

		if ( IsValid(entity) ) then
			local distance = entity:GetPos():Distance( self.Owner:GetPos() );

			if ( self.Owner:KeyDown(IN_SPEED) ) then
				local expectedDistance = 72;

				if ( entity:IsVehicle() ) then
					expectedDistance = 128;
				end;

				if (distance <= expectedDistance) then
					if ( ( entity:IsDoor() or entity:IsVehicle() ) and entity:HasAccess(self.Owner) and !entity.isSeat ) then
						self.Owner:EmitSound("doors/door_latch1.wav");

						entity:UnLock();
						entity.locked = false;
					else
						self.Owner:Notify("You don't have access to this entity!");
					end;
				end;
			elseif ( distance <= 72 and entity:IsDoor() ) then
				entity:EmitSound("physics/wood/wood_crate_impact_hard"..math.random(1, 5)..".wav");

				self:SetNextSecondaryFire(CurTime() + 0.5);

				return;
			end;
		end;
	end;

	self:SetNextSecondaryFire(CurTime() + 0.75);
end;