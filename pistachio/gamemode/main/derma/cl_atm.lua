if (SERVER) then util.AddNetworkString("ps_ATMPanel"); return; end;

surface.CreateFont( "ps_ATMFont", {
	font = "Tahoma",
	size = 24,
	weight = 800,
	antialias = true
} );

surface.CreateFont( "ps_ConsoleFont", {
	font = "Courier New",
	size = 16,
	weight = 200,
} );

local PANEL = {};

function PANEL:Init()
	self:SetSize(360, 236);
	self:SetTitle("ATM Machine - Pistachio");
	self:SetSizable(false);
	self:SetDraggable(true);
	self:ShowCloseButton(true);
	self:Center();
	self:MakePopup();

	self.console = vgui.Create("DPanel", self);
	self.console:Dock(TOP);
	self.console:SetTall(128);
	self.console:DockPadding(2, 2, 2, 2);
	self.console.text = {};

	self.console.Paint = function(control, w, h)
		surface.SetDrawColor(0, 0, 0, 255);
		surface.DrawRect(0, 0, w, h);
	end;

	self.deposit = self:Add("DButton");
	self.deposit:DockMargin(0, 3, 0, 0);
	self.deposit:Dock(TOP);
	self.deposit:SetText("Deposit");
	self.deposit.DoClick = function(control)
		local argument = 0;

		Derma_StringRequest("Deposit Amount", "How much would you like to deposit?", "0", function(text)
			net.Start("ps_ATMAction");
				net.WriteString("deposit");
				net.WriteString(text);
			net.SendToServer();
		end);
	end;

	self.withdraw = self:Add("DButton");
	self.withdraw:DockMargin(0, 3, 0, 0);
	self.withdraw:Dock(TOP);
	self.withdraw:SetText("Widthdraw");
	self.withdraw.DoClick = function(control)
		local argument = 0;

		Derma_StringRequest("Withdraw Amount", "How much would you like to withdraw?", "0", function(text)
			net.Start("ps_ATMAction");
				net.WriteString("withdraw");
				net.WriteString(text);
			net.SendToServer();
		end);
	end;

	self.balance = self:Add("DButton");
	self.balance:DockMargin(0, 3, 0, 0);
	self.balance:Dock(TOP);
	self.balance:SetText("View Balance");
	self.balance.DoClick = function(control)
		self:AddConsoleText("Balance: $"..(LocalPlayer():GetPrivateVar("bank") or 0).." dollars.");
	end;
end;

function PANEL:AddConsoleText(text)
	if ( IsValid(self.console) ) then
		local label = self.console:Add("DLabel");
		label:Dock(TOP);
		label:SetFont("ps_ConsoleFont");
		label:SetTextColor( Color(0, 255, 0, 255) );
		label:SetText(text);
		label:SizeToContents();

		table.insert(self.console.text, label);

		if (#self.console.text > 8) then
			self.console.text[1]:Remove();

			table.remove(self.console.text, 1);
		end;

		surface.PlaySound("buttons/button16.wav");
	end;
end;

vgui.Register("ps_ATM", PANEL, "DFrame");

net.Receive("ps_ATMPanel", function(length)
	if (pistachio.atmPanel) then
		pistachio.atmPanel:Remove();
	end;
	
	pistachio.atmPanel = vgui.Create("ps_ATM");
end);

net.Receive("ps_ATMConsoleText", function(length)
	local text = net.ReadString();

	if ( IsValid(pistachio.atmPanel) ) then
		pistachio.atmPanel:AddConsoleText(text);
	end;
end);