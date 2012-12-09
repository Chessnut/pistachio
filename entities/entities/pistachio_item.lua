AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "Item";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemID");
end;

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_junk/watermelon01.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);

		local physicsObject = self:GetPhysicsObject();

		if ( IsValid(physicsObjects) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;
end;

if (SERVER) then
	util.AddNetworkString("ps_ItemUseMenu");
	util.AddNetworkString("ps_ItemUseMenuData");

	net.Receive("ps_ItemUseMenuData", function(length, client)
		if ( IsValid(client) ) then
			local entity = net.ReadEntity();
			local action = net.ReadString();

			if (IsValid(entity) and entity:GetClass() == "pistachio_item" and entity:GetPos():Distance( client:GetPos() ) <= 96) then
				entity:UseMenu(client, action);
			end;
		end;
	end);

	function ENT:Use(activator, caller)
		if ( IsValid(activator) and !IsValid(self.tapped) ) then
			net.Start("ps_ItemuseMenu");
				net.WriteEntity(self);
			net.Send(activator);

			self.tapped = activator;
		end;
	end;

	function ENT:UseMenu(activator, action)
		local itemTable = pistachio.item:Get( self:GetItemID() );
		local shouldRemove = true;

		if (action == "cancel") then
			self.tapped = false;

			return;
		end;

		if (action == "take") then
			activator:AddItem( self:GetItemID() );

			SafeRemoveEntity(self);

			return;
		end;

		if (itemTable.preventUse) then
			return;
		end;
		
		if (itemTable and itemTable.OnUse) then
			shouldRemove = itemTable:OnUse(self, activator);
		end;

		if (shouldRemove != false) then
			SafeRemoveEntity(self);
		else
			activator:AddItem( self:GetItemID() );

			SafeRemoveEntity(self);
		end;
	end;

	function ENT:SetItem(key)
		local itemTable = pistachio.item:Get(key);

		self:SetItemID(key);
		self:SetModel(itemTable.model or "models/error.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self.item = itemTable;

		if (itemTable.LayoutEntity) then
			itemTable:LayoutEntity(self);
		end;
		
		local physicsObject = self:GetPhysicsObject();

		if ( IsValid(physicsObject) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;

	function ENT:OnTakeDamage(damageInfo)
		if (!self.health) then
			self.health = 50;
		end;

		if (self.health < 1) then
			local effect = EffectData();
			effect:SetOrigin( self:LocalToWorld( self:OBBCenter() ) );

			util.Effect("StunstickImpact", effect);

			self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
			self:Remove();

			return;
		end;

		self.health = self.health - damageInfo:GetDamage();
	end;
else
	net.Receive("ps_ItemUseMenu", function(length)
		local entity = net.ReadEntity();

		if ( IsValid(entity) ) then
			local menu = DermaMenu();

			menu:AddOption("Use", function()
				net.Start("ps_ItemUseMenuData");
					net.WriteEntity(entity);
					net.WriteString("use");
				net.SendToServer();

				menu:Remove();
			end);

			menu:AddOption("Take", function()
				net.Start("ps_ItemUseMenuData");
					net.WriteEntity(entity);
					net.WriteString("take");
				net.SendToServer();

				menu:Remove();
			end);

			menu:AddOption("Cancel", function()
				net.Start("ps_ItemUseMenuData");
					net.WriteEntity(entity);
					net.WriteString("cancel");
				net.SendToServer();

				menu:Remove();
			end);

			local oldRemove = menu.Remove;

			menu.Remove = function(control)
				net.Start("ps_ItemUseMenuData");
					net.WriteEntity(entity);
					net.WriteString("cancel");
				net.SendToServer();

				oldRemove(control);
			end;

			menu:Open();
			menu:Center();
		end;
	end);

	function ENT:Draw()
		self:DrawModel();
	end;
end;