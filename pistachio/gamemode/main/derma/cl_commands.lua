if (SERVER) then return; end;

local PANEL = {};

function PANEL:Init()
	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	local title = self.list:AddItem("DLabel");
	title:SetFont("ps_TitleFont");
	title:SetTextColor( Color(100, 100, 100, 255) );
	title:SetText("Commands");

	local userGroup = LocalPlayer():GetNWString("usergroup");

	for k, v in SortedPairs(pistachio.command.stored) do
		if ( v.userGroup and !string.find(userGroup, v.userGroup) ) then
			continue;
		end;

		if (v.fake) then
			continue;
		end;

		local command = self.list:AddItem("DLabel");
		command:SetTextColor( Color(80, 80, 80, 255) );
		command:DockMargin(4, 2, 2, 2);

		if (v.info) then
			command:SetText("/"..k.." "..(v.help or "<none>").." - "..v.info);
		else
			command:SetText( "/"..k.." "..(v.help or "<none>") );
		end;
	end;

	local title = self.list:AddItem("DLabel");
	title:SetFont("ps_TitleFont");
	title:SetTextColor( Color(100, 100, 100, 255) );
	title:SetText("Chat Commands");
	title:SizeToContents();

	for k, v in SortedPairs(pistachio.command.stored) do
		if (v.fake) then
			local command = self.list:AddItem("DLabel");
			command:SetTextColor( Color(80, 80, 80, 255) );
			command:SetText(k.." "..(v.help or "<none>") );
			command:DockMargin(4, 2, 2, 2);
		end;
	end;
end;

vgui.Register("ps_Help", PANEL, "Panel");