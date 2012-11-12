if (SERVER) then return; end;

local math_clamp = math.Clamp;
local PANEL = {};

function PANEL:Init()
	self:SetSize(ScrW() * 0.33, ScrH() * 0.325);
	self:SetTitle("Shirt Color - Pistachio");
	self:SetSizable(false);
	self:SetDraggable(true);
	self:ShowCloseButton(true);
	self:Center();
	self:MakePopup();

	self.color = vgui.Create("DColorMixer", self);
	self.color:Dock(LEFT);
	self.color:SetAlphaBar(false);

	self.okay = vgui.Create("DButton", self);
	self.okay:SetText("Change Color");
	self.okay:Dock(BOTTOM);
	self.okay:SetSize(256, 24);
	self.okay:DockMargin(3, 0, 0, 0);

	self.okay.DoClick = function()
		local color = self.color:GetColor();
		local red, green, blue = color.r, color.g, color.b;

		red = math.Clamp(red, 0, 255);
		green = math.Clamp(green, 0, 255);
		blue = math.Clamp(blue, 0, 255);

		net.Start("ps_SelectShirtColor");
			net.WriteUInt(red, 8);
			net.WriteUInt(green, 8);
			net.WriteUInt(blue, 8);
		net.SendToServer();

		self:Remove();
	end;

	self.model = vgui.Create("DModelPanel", self);
	self.model:SetModel( LocalPlayer():GetPrivateVar("model") );
	self.model:Dock(RIGHT);
	self.model:SetSize(256, 256);

	self.model.Entity.GetPlayerColor = function()
		local color = self.color:GetColor();
		local r, g, b = math_clamp(color.r / 255, 0, 1), math_clamp(color.g / 255, 0, 1), math_clamp(color.b / 255, 0, 1);

		return Vector(r, g, b);
	end;
end;

vgui.Register("ps_ChangeShirt", PANEL, "DFrame");

pistachio.changeShirt = pistachio.changeShirt or nil;

if ( IsValid(pistachio.changeShirt) ) then
	pistachio.changeShirt:Remove();
end;

net.Receive("ps_ChangeShirt", function(length)
	if ( IsValid(pistachio.changeShirt) ) then
		pistachio.changeShirt:Remove();
	end;

	pistachio.changeShirt = vgui.Create("ps_ChangeShirt");
end);