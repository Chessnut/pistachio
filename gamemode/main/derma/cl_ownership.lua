if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self:SetSize(ScrW() * 0.145, ScrH() * 0.25);
	self:SetTitle("Ownership - Pistachio");
	self:SetSizable(false);
	self:SetDraggable(true);
	self:ShowCloseButton(true);
	self:Center();
	self:MakePopup();

	self.loading = vgui.Create("DLabel", self);
	self.loading:SetFont("ps_TitleFont");
	self.loading:SetText("Loading...");
	self.loading:SizeToContents();
	self.loading:Center();

	timer.Simple(1, function()
		if ( !IsValid(self.entity) ) then
			self:Remove();
		else
			self.loading:Remove();
			self:PerformSetup();
		end;
	end);

	pistachio.ownership = self;
end;

function PANEL:PerformSetup()
	self.panel = vgui.Create("DPanel", self);
	self.panel:Dock(FILL);
	self.panel:DockPadding(3, 3, 3, 3);
	local class = "door";
	local price = 50;

	if ( self.entity:IsVehicle() ) then
		class = "vehicle";
		price = 100;
	end;

	self.info = vgui.Create("DLabel", self.panel);
	self.info:SetTextColor( Color(80, 80, 80, 255) );
	self.info:Dock(FILL);
	self.info:SetWrap(true);
	self.info:SetText("Are you sure you want to buy this "..class.." for $"..price.." dollars?");

	-- Thanks _Undefined!
	local minimum, maximum = self.entity:GetRenderBounds();

	self.model = vgui.Create("DModelPanel", self.panel);
	self.model:Dock(TOP);
	self.model:SetModel( self.entity:GetModel() );
	self.model:SetSkin( self.entity:GetSkin() );
	self.model:SetSize(128, 128);
	self.model:SetCamPos( self.entity:OBBCenter() + minimum:Distance(maximum) * Vector(0.6, 0.6, 0.6) );
	self.model:SetLookAt( (minimum + maximum) / 2 );
	self.model:SetFOV(70);

	self.buttons = vgui.Create("DPanel", self);
	self.buttons:DockMargin(0, 5, 0, 0);
	self.buttons:Dock(BOTTOM);
	self.buttons:SetPaintBackground(false);

	self.yes = vgui.Create("DButton", self.buttons);
	self.yes:SetWide(108);
	self.yes:Dock(LEFT);
	self.yes:SetText("Yes");

	self.yes.DoClick = function()
		net.Start("ps_OwnEntity");
			net.WriteEntity(self.entity);
		net.SendToServer();

		self:Remove();
	end;

	self.no = vgui.Create("DButton", self.buttons);
	self.no:SetWide(108)
	self.no:Dock(RIGHT);
	self.no:SetText("No");

	self.no.DoClick = function()
		self:Remove();
	end;
end;

vgui.Register("ps_Ownership", PANEL, "DFrame");

net.Receive("ps_Ownership", function(length)
	if (pistachio.ownership) then
		pistachio.ownership:Remove();
	end;

	vgui.Create("ps_Ownership");

	if (pistachio.ownership) then
		local entity = net.ReadEntity();

		if ( IsValid(entity) ) then
			pistachio.ownership.entity = entity;
		end;
	end;
end);