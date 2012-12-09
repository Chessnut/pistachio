if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self.panel = vgui.Create("DScrollPanel", self);
	self.panel:Dock(FILL);

	self.categories = {};

	for k, v in SortedPairs(pistachio.item.stored) do
		if (!v.preventBuy) then
			local itemTable = pistachio.item:Get(k);
			local itemCategory = itemTable.category or "Miscellaneous";

			if ( itemTable and !self.categories[itemCategory] ) then
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

			if (itemTable) then
				local category = self.categories[itemTable.category or "Miscellaneous"];

				local item = category.list:Add("ps_MarketItem");
				item:DockMargin(3, 3, 3, 3);
				item:SetAmount(v);
				item:SetItem(itemTable);
			end;
		end;
	end;
end;

function PANEL:Rebuild()
	for k, v in pairs(self.categories) do
		v:Remove();
	end;

	if (itemTable and !itemTable.preventBuy) then
		local category = self.categories[itemTable.category or "Miscellaneous"];

		local item = category.list:Add("ps_MarketItem");
		item:DockMargin(3, 3, 3, 3);
		item:SetAmount(v);
		item:SetItem(itemTable);
	end;
end;

vgui.Register("ps_Market", PANEL, "Panel");

local PANEL = {};

AccessorFunc(PANEL, "amount", "Amount");

function PANEL:Init()
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

	self.order = vgui.Create("DButton", self);
	self.order:Dock(RIGHT);
	self.order:DockMargin(5, 5, 5, 5);
	self.order:SetText("Order");
	self.order:SetWide(92);

	self.order.DoClick = function()
		if (self.itemTable) then
			net.Start("ps_OrderItem");
				net.WriteString(self.itemTable.uniqueID);
			net.SendToServer();
		end;
	end;

	self:SizeToContents();
end;

function PANEL:SetItem(itemTable)
	local name = itemTable.name;

	name = hook.Call("GetMarketItemName", GAMEMODE, itemTable);

	self.spawnIcon:SetModel(itemTable.model or "");

	self.name:SetFont("ps_TitleFont");
	self.name:SetTextColor( Color(100, 100, 100, 255) );
	self.name:SetText(name);
	self.name:SizeToContents();

	self.description:SetText(itemTable.description or "No description available.");
	self.description:SetTextColor( Color(125, 125, 125, 225) );
	self.description:SizeToContents();

	self.itemTable = itemTable;
end;

function PANEL:Think()
	local name = hook.Call("GetMarketItemName", GAMEMODE, self.itemTable);
	local shouldEnable = hook.Call("ShouldEnableOrderButton", GAMEMODE, self.itemTable);
	local buttonText = hook.Call("GetOrderButtonText", GAMEMODE, self.itemTable);

	self.name:SetText(name);
	self.name:SizeToContents();

	self.order:SetText("Order ("..buttonText..")");
	self.order:SetEnabled(shouldEnable);
end;

vgui.Register("ps_MarketItem", PANEL, "DPanel");