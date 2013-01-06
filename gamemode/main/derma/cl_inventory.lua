if (SERVER) then return; end;

local menuPanel;
local PANEL = {};

function PANEL:Init()
	self.panel = vgui.Create("DScrollPanel", self);
	self.panel:Dock(FILL);

	self.categories = {};

	for k, v in SortedPairs( LocalPlayer():GetInventory() ) do
		local itemTable = pistachio.item:Get(k);

		if (itemTable) then
			local itemCategory = itemTable.category or "Miscellaneous";

			if ( !self.categories[itemCategory] ) then
				local category = vgui.Create("DCollapsibleCategory");
				category:SetLabel(itemCategory);
				category:Dock(TOP);
				category:SetExpanded(0);

				category.panel = vgui.Create("DPanel", category);
				category.panel:Dock(FILL);

				category.list = vgui.Create("DListLayout", category.panel);
				category.list:Dock(FILL);
				category.list:DockPadding(3, 3, 3, 7);

				category:SetContents(category.list);

				self.panel:AddItem(category);
				self.categories[itemCategory] = category;
			end;

			local category = self.categories[itemTable.category or "Miscellaneous"];

			local item = category.list:Add("ps_InventoryItem");
			item:DockMargin(3, 3, 3, 3);
			item:SetAmount(v);
			item:SetItem(itemTable);
		end;
	end;

	menuPanel = self;
end;

function PANEL:RebuildInventory()
	local expanded = {}

	for k, v in pairs(self.categories) do
		if (v.list) then
			v.list:Clear(true);

			for k2, v2 in pairs( LocalPlayer():GetInventory() ) do
				local itemTable = pistachio.item:Get(k2);

				if (itemTable) then
					local category = self.categories[itemTable.category or "Miscellaneous"];

					if (category == v) then
						local item = v.list:Add("ps_InventoryItem");
						item:DockMargin(3, 3, 3, 3);
						item:SetAmount(v2);
						item:SetItem(itemTable);

						if ( v:GetExpanded() ) then
							v:SetExpanded(0);

							timer.Simple(0.1, function()
								if ( IsValid(v) ) then
									v:SetExpanded(1);
								end;
							end);
						end;
					end;	
				end;
			end;

			if (table.Count( v.list:GetChildren() ) <= 1) then
				v:Remove();
			end;
		end;
	end;
end;

concommand.Add("ps_rebuildinv", function()
	if ( IsValid(menuPanel) ) then
		menuPanel:RebuildInventory();
	end;
end);

vgui.Register("ps_Inventory", PANEL, "Panel");

local PANEL = {};

AccessorFunc(PANEL, "amount", "Amount");

function PANEL:Init()
	self:Dock(TOP)
	self:SetTall(48);

	self.spawnIcon = vgui.Create("SpawnIcon", self);
	self.spawnIcon:Dock(LEFT);
	self.spawnIcon:SetSize(48, 48);
	self.spawnIcon:SetModel("models/error.mdl");

	self.name = vgui.Create("DLabel", self);
	self.name:SetPos(56, 4);
	self.name:SetText("Unknown");
	self.name:SetExpensiveShadow( 1, Color(255, 255, 255, 255) );

	self.description = vgui.Create("DLabel", self);
	self.description:SetPos(56, 22);
	self.description:SetText("No description available.");

	self:SizeToContents();
end;

function PANEL:Refresh(itemTable)
	self.name:SetText(itemTable.name.." (Quantity: "..(self:GetAmount() or 0)..")");

	if ( !LocalPlayer():HasItem(itemTable.uniqueID) ) then
		self:Remove();
	end;

	if (self:GetAmount() < 1) then
		self:Remove();
	end;
end;

function PANEL:SetItem(itemTable)
	if (!itemTable) then
		self:Remove();

		return;
	end;

	if ( !LocalPlayer():HasItem(itemTable.uniqueID) ) then
		self:Remove();

		return;
	end;

	self.spawnIcon:SetModel(itemTable.model or "");

	self.name:SetFont("ps_TitleFont");
	self.name:SetTextColor( Color(100, 100, 100, 255) );
	self.name:SetText(itemTable.name.." (Quantity: "..(self:GetAmount() or 0)..")");
	self.name:SizeToContents();

	self.description:SetText(itemTable.description or "No description available.");
	self.description:SetTextColor( Color(125, 125, 125, 225) );
	self.description:SizeToContents();

	self.buttons = {};

	for k, v in SortedPairs(itemTable) do
		if (type(v) == "function") then
			if (string.sub(k, 1, 2) == "On") then
				local name = string.gsub(k, "On", "");

				if ( itemTable["prevent"..name] ) then
					continue;
				end;

				self.buttons[k] = vgui.Create("DButton", self);
				self.buttons[k]:Dock(RIGHT);
				self.buttons[k]:DockMargin(5, 5, 5, 5);
				self.buttons[k]:SetText(name);

				self.buttons[k].DoClick = function()
					net.Start("ps_InvAction");
						net.WriteString(k);
						net.WriteString(itemTable.uniqueID);
					net.SendToServer();

					self:Refresh(itemTable);
				end;
			end;
		end;
	end;
end;

vgui.Register("ps_InventoryItem", PANEL, "DPanel");