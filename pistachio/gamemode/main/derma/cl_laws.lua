if (SERVER) then return; end;

local PANEL = {};

pistachio.laws = pistachio.laws or {
	"Having weapons is not permitted.",
	"Do not cause public disturbances.",
	"Do not block public areas with your property.",
	"Murder is illegal.",
	"Stealing is illegal.",
	"You are not allowed to consume alcohol in public.",
	"Regular civilians are not allowed in the police department.",
	"Gambling in public is not allowed.",
	"Contraband is not allowed at all times.",
	"Assault is not allowed.",
	"Follow all traffic signals.",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	""
};

function PANEL:Init()
	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	for k, v in ipairs(pistachio.laws) do
		local label = self.list:AddItem("DLabel");
		label:Dock(TOP);
		label:SetTextColor( Color(80, 80, 80, 255) );
		label:SetText(k..".) "..v);
		label:SetDisabled(false);
		label.Think = function(self)
			if (pistachio.laws[k] == "") then
				self:SetText("");

				return;
			end;

			if ( self:GetText() != pistachio.laws[k] ) then
				self:SetText( k..".) "..pistachio.laws[k] );
			end;
		end;
	end;

	if (LocalPlayer():Team() == TEAM_MAYOR) then
		-- This is used to add an extra gap to read easier.
		local label = self.list:AddItem("DLabel");
		label:Dock(TOP);
		label:SetTextColor( Color(80, 80, 80, 255) );
		label:SetText("");

		local title = self.list:AddItem("DLabel");
		title:Dock(TOP);
		title:SetFont("ps_TitleFont");
		title:SetTextColor( Color(100, 100, 100, 255) )
		title:SetText("Mayor Options");

		for i = 1, 25 do
			local panel = self.list:AddItem("DPanel");
			panel:DockPadding(3, 3, 3, 3);
			panel:DockMargin(2, 0, 0, 2);
			panel:Dock(TOP);

			local textEntry = panel:Add("DTextEntry");
			textEntry:Dock(FILL);
			textEntry:SetText( pistachio.laws[i] );

			local edit = panel:Add("DButton");
			edit:Dock(RIGHT);
			edit:SetText("Edit");
			edit.DoClick = function(self)
				local text = tostring( textEntry:GetValue() );
				
				if ( string.lower(text) == string.lower( pistachio.laws[i] ) ) then
					LocalPlayer():Notify("You haven't modified the law!");

					return;
				end;

				net.Start("ps_EditLaw");
					net.WriteUInt(i, 8);
					net.WriteString(text or "");
				net.SendToServer();
			end;
		end;
	end;

	-- This is used to add an extra gap to read easier.
	local label = self.list:AddItem("DLabel");
	label:Dock(TOP);
	label:DockMargin(2, 2, 2, 2);
	label:SetTextColor( Color(80, 80, 80, 255) );
	label:SetText("");
end;

vgui.Register("ps_Laws", PANEL, "Panel");

net.Receive("ps_UpdateLaw", function(length)
	local index = net.ReadUInt(8);
	local text = net.ReadString();

	if ( pistachio.laws[index] ) then
		pistachio.laws[index] = text or "";
	end;
end);