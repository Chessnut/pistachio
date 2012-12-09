if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self:SetSize(ScrW() * 0.275, ScrH() * 0.35);
	self:SetTitle("Mailbox - Pistachio");
	self:SetSizable(false);
	self:SetDraggable(true);
	self:ShowCloseButton(true);
	self:Center();
	self:MakePopup();

	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	for k, v in SortedPairs( LocalPlayer():GetMailBox() ) do
		for k2, v2 in pairs(v) do
			local amount = v2.quantity;
			local arrived = ( v2.arrival - os.time() ) <= 0;

			if (arrived) then
				local item = self.list:AddItem("ps_MailBoxItem");
				item:SetItem(k, amount, k2);
			end;
		end;
	end;
end;

vgui.Register("ps_MailBox", PANEL, "DFrame");

local PANEL = {};

function PANEL:Init()
	self:DockPadding(5, 5, 5, 5);
	self:SetTall(42);

	self.icon = vgui.Create("SpawnIcon", self);
	self.icon:SetSize(32, 32);
	self.icon:Dock(LEFT);

	self.title = vgui.Create("DLabel", self);
	self.title:Dock(LEFT);
	self.title:DockMargin(8, 8, 8, 8);
	self.title:SetText("Hi");
	self.title:SetTextColor( Color(100, 100, 100, 225) );
	self.title:SetExpensiveShadow( 1, Color(255, 255, 255, 255) );
	self.title:SetFont("ps_TitleFont")

	self.button = vgui.Create("DButton", self);
	self.button:SetText("Take All");
	self.button:Dock(RIGHT);
	self.button:SetDisabled(true);
end;

function PANEL:SetItem(uniqueID, quantity, id)
	local itemTable = pistachio.item:Get(uniqueID);

	if (!itemTable or quantity < 1) then
		self:Remove();
	else
		self.icon:SetModel(itemTable.model);
		self.title:SetText(itemTable.name.." (Quantity: "..quantity..")");
		self.title:SizeToContents();

		self.id = id;

		self.button:SetDisabled(false);
		self.button.DoClick = function()
			net.Start("ps_MailBoxUse");
				net.WriteString(uniqueID);
				net.WriteUInt(id, 8);
			net.SendToServer();

			surface.PlaySound("vehicles/atv_ammo_open.wav");

			self:Remove();
		end;
	end;
end;

vgui.Register("ps_MailBoxItem", PANEL, "DPanel");

net.Receive("ps_MailBoxPanel", function(length)
	if (pistachio.mailBoxPanel) then
		pistachio.mailBoxPanel:Remove();
	end;
	
	pistachio.mailBoxPanel = vgui.Create("ps_MailBox");
end);