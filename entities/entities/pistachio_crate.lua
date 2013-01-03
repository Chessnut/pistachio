AddCSLuaFile();

ENT.Type = "anim";
ENT.PrintName = "Crate";
ENT.Author = "Chessnut";
ENT.Spawnable = false;

util.PrecacheModel("models/items/item_item_crate.mdl");

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/items/item_item_crate.mdl");
		self:SetSolid(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		self.items = {};
		self:SetWeight(0);
		self:SetMaxWeight(5);
	end;
end;

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemID");
	self:NetworkVar("Int", 0, "Weight");
	self:NetworkVar("Int", 1, "MaxWeight");
end;

if (SERVER) then
	function ENT:OnRemove()
		if (self.items and #self.items > 0) then
			for k, v in pairs(self.items) do
				local itemTable = pistachio.item:Get(v);

				if (itemTable) then
					pistachio.item:Create( v, self:GetPos() + Vector(0, 0, 16) );
				end;
			end;
		end;
	end;

	function ENT:SetItem(itemID)
		local itemTable = pistachio.item:Get(itemID);

		if (itemTable) then
			self:SetItemID(itemID);
			self:SetModel(itemTable.model);
			self:SetSolid(SOLID_VPHYSICS);
			self:SetMoveType(MOVETYPE_VPHYSICS);
			self:PhysicsInit(SOLID_VPHYSICS);
			self:SetUseType(SIMPLE_USE);
		end;
	end;

	function ENT:Use(activator, caller)
		if ( (self.nextUse or 0) < CurTime() ) then
			if ( activator:KeyDown(IN_SPEED) ) then
				if (self.items and #self.items > 0) then
					for k, v in pairs(self.items) do
						local itemTable = pistachio.item:Get(v);

						if (itemTable) then
							activator:AddItem(v);
						end;
					end;
				end;

				activator:AddItem(self:GetItemID() or "crate");

				self:Remove();
			else
				if (self.items and #self.items > 0) then
					local index = math.random(1, #self.items);
					local info = self.items[index];

					if (info) then
						local itemTable = pistachio.item:Get(info);

						if (itemTable) then
							local entity = pistachio.item:Create( info, self:GetPos() + Vector(0, 0, 16) );
							entity.touchedCrate = CurTime() + 5;

							self:EmitSound("items/ammocrate_open.wav");
							
							if ( self:GetMaxWeight() and self:GetWeight() ) then
								self:SetWeight( math.max(self:GetWeight() - (itemTable.weight or 0), 0) );
							end;

							table.remove(self.items, index);
						end;
					end;
				end;
			end;

			self.nextUse = CurTime() + 1;
		end;
	end;

	function ENT:StartTouch(entity)
		if ( (entity.touchedCrate or 0) < CurTime() and IsValid(entity) and entity:GetClass() == "pistachio_item") then
			entity.touchedCrate = CurTime() + 2.5;

			local uniqueID = entity:GetItemID();
			local itemTable = pistachio.item:Get(uniqueID);

			if ( self:GetWeight() and self:GetMaxWeight() and self:GetMaxWeight() > 0 ) then
				if ( self:GetWeight() + (itemTable.weight or 0) > self:GetMaxWeight() ) then
					self:EmitSound("buttons/button10.wav");

					return;
				end;
			end;

			if (itemTable and self.items) then
				table.insert(self.items, uniqueID);

				if ( self:GetWeight() and self:GetMaxWeight() and self:GetMaxWeight() > 0 ) then
					self:SetWeight( math.max(self:GetWeight() + (itemTable.weight or 0), 0) );
				end;

				entity:EmitSound("items/ammocrate_close.wav");
				entity:Remove();
			end;
		end;
	end;
end;