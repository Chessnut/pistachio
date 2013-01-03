AddCSLuaFile();

ENT.Type = "anim" 
ENT.Base = "base_anim" 
ENT.PrintName = "Hat"
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/Combine_Scanner.mdl");
	end;
end;

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "UniqueID");
end;

function ENT:Think()
	local client = self:GetOwner();

	if ( IsValid(client) ) then
		if ( IsValid( client:GetRagdollEntity() ) ) then
			client = client:GetRagdollEntity();
		end;

		if ( IsValid(client) ) then
			local boneIndex = client:LookupBone("ValveBiped.Bip01_Head1");
			local info = pistachio.item:Get( self:GetUniqueID() );

			if (info and boneIndex and boneIndex != -1) then
				local position, angle = client:GetBonePosition(boneIndex);

				self:SetPos( position + angle:Right() * (info.offset[1] or 0) + angle:Forward() * (info.offset[2] or 0) + angle:Up() * (info.offset[3] or 0) );

				angle:RotateAroundAxis( angle:Right(), (info.rotation[1] or 0) );
				angle:RotateAroundAxis( angle:Forward(), (info.rotation[2] or 0) );
				angle:RotateAroundAxis( angle:Up(), (info.rotation[3] or 0) );

				self:SetAngles(angle);
			end;
		end;
	end;
end;

if (CLIENT) then
	function ENT:Draw()
		local client = self:GetOwner();

		if ( !IsValid(client) ) then
			return;
		end;

		local itemTable = pistachio.item:Get( self:GetUniqueID() );

		if ( itemTable and IsValid(client) and ( client != LocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer() ) ) then
			if (self:GetModelScale() != itemTable.scale) then
				self:SetModelScale(itemTable.scale, 0);
			end;
			
			self:DrawModel();
		end;
	end;
end;