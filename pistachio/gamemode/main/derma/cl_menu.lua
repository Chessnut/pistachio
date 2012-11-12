if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self:SetSkin("Pistachio");
	self:SetSize(ScrW() * 0.65, ScrH() * 0.75);
	self:SetTitle("Menu - Pistachio");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(true);
	self:Center();
	self:MakePopup();

	self.propertySheet = vgui.Create("DPropertySheet", self);
	self.propertySheet:Dock(FILL);

	self.propertySheet:AddSheet("Information", vgui.Create("ps_Information", self.propertySheet), "icon16/information.png");
	self.propertySheet:AddSheet("Rules", vgui.Create("ps_Rules", self.propertySheet), "icon16/book_open.png");
	self.propertySheet:AddSheet("Laws", vgui.Create("ps_Laws", self.propertySheet), "icon16/world.png");
	self.propertySheet:AddSheet("Changelog", vgui.Create("ps_ChangeLog", self.propertySheet), "icon16/script_edit.png");
	self.propertySheet:AddSheet("Commands", vgui.Create("ps_Help", self.propertySheet), "icon16/cog.png");
	self.propertySheet:AddSheet("Inventory", vgui.Create("ps_Inventory", self.propertySheet), "icon16/application_view_tile.png");
	self.propertySheet:AddSheet("Market", vgui.Create("ps_Market", self.propertySheet), "icon16/cart.png");
	self.propertySheet:AddSheet("Credits", vgui.Create("ps_Credits", self.propertySheet), "icon16/heart.png");
	
	pistachio.menu = self;
end;

vgui.Register("ps_Menu", PANEL, "DFrame");

pistachio.menu = pistachio.menu or nil;

if (pistachio.menu) then
	pistachio.menu:Remove();
end;
	
net.Receive("ps_MenuPanel", function(length)
	if (pistachio.menu) then
		pistachio.menu:Remove();
	end;

	pistachio.menu = vgui.Create("ps_Menu");
end);