if (SERVER) then return; end;

local PANEL = {};

local help = {};

help["Chessnut"] = [[
Developer of the gamemode.]];

help["Spencer Sharkey"] = [[
Some assistance, and coping with me realizing how to fix stuff.]];

help["ArmageddonSrc"] = [[
Some assistance with the networking issue.]];

help["Jetman"] = [[
Hosting the Fast Download stuff.]];

function PANEL:Init()
	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	for k, v in SortedPairs(help) do
		local title = self.list:AddItem("DLabel");
		title:SetFont("ps_TitleFont");
		title:SetTextColor( Color(100, 100, 100, 255) );
		title:SetText(k);

		for k2, v2 in ipairs( string.Explode("\n", v) ) do
			local command = self.list:AddItem("DLabel");
			
			command:SetTextColor( Color(80, 80, 80, 255) );
			command:SetText(v2);
		end;
	end;
end;

vgui.Register("ps_Credits", PANEL, "Panel");