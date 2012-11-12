if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self:SetSize(ScrW() * 0.2, ScrH() * 0.225);
	self:SetTitle("Change Model - Pistachio");
	self:SetSizable(false);
	self:SetDraggable(true);
	self:ShowCloseButton(false);
	self:SetVerticalScrollbarEnabled(true);
	self:Center();
	self:MakePopup();

	self.panel = vgui.Create("ps_IconPanel", self);
	self.panel:DockPadding(5, 5, 5, 10);
	self.panel:Dock(FILL);

	local modelTable = pistachio.playerModels[ LocalPlayer():Team() ];

	if (!modelTable) then
		modelTable = pistachio.playerModels[TEAM_CITIZEN];
	end;

	for k, v in SortedPairs(modelTable) do
		local icon = self.panel:AddItem("SpawnIcon");
		icon:SetModel(v);

		function icon:DoClick()
			LocalPlayer():SetModel(v);
			LocalPlayer():EmitSound("UI/buttonclickrelease.wav");
		end;
	end;

	self.confirm = vgui.Create("DButton", self);
	self.confirm:DockMargin(3, 8, 3, 3);
	self.confirm:Dock(BOTTOM);
	self.confirm:SetText("Confirm");

	self.confirm.DoClick = function(button)
		net.Start("ps_PlayerModel");
			net.WriteString( LocalPlayer():GetModel() );
		net.SendToServer();

		self:Remove();
	end;

	pistachio.modelChange = self;
end;

vgui.Register("ps_ChangeModel", PANEL, "DFrame");

net.Receive("ps_ChangeModel", function(length)
	if (pistachio.modelChange) then
		pistachio.modelChange:Remove();
	end;

	vgui.Create("ps_ChangeModel");
end);