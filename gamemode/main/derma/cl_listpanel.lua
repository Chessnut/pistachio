if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self.panel = vgui.Create("DScrollPanel", self);
	self.panel:Dock(FILL);
	self.panel:SetPaintBackground(true);

	self.list = vgui.Create("DListLayout", self.panel);
	self.list:Dock(FILL);
	self.list:DockMargin(5, 5, 5, 5);

	self.panel:AddItem(self.list);
	self.panel:SizeToContents();
end;

function PANEL:AddItem(item)
	local panel = self.list:Add(item);

	self.panel:SizeToContents();

	return panel;
end;

vgui.Register("ps_ListPanel", PANEL, "Panel");

local PANEL = {};

function PANEL:Init()
	self.panel = vgui.Create("DScrollPanel", self);
	self.panel:Dock(FILL);
	self.panel:SetPaintBackground(true);

	self.list = vgui.Create("DIconLayout", self.panel);
	self.list:Dock(FILL);
	self.list:DockMargin(5, 5, 5, 5);
	self.list:SetSpaceX(5);
	self.list:SetSpaceY(5);

	self.panel:AddItem(self.list);
	self.panel:SizeToContents();
end;

function PANEL:AddItem(item)
	local panel = self.list:Add(item);

	self.panel:SizeToContents();

	return panel;
end;

vgui.Register("ps_IconPanel", PANEL, "Panel");