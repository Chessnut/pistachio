if (SERVER) then return; end;

local PANEL = {};

local RULES = {
	"1.) Do not kill other players without a reasonable purpose. (No RDM)",
	"   a. Having a different model is considered a bad reason.",
	"   b. Constantly killing you, report them if it is random deathmatch.",
	"   c. Spamming props/prop blocking you, report them instead.",
	"   d. Yelling 'raid' or having your job as a Hitman isn't a valid reason to kill others.",
	"2.) Do not prop block.",
	"   a. Having a base is considered prop blocking unless there is a reasonable entrance.",
	"3.) Do not use props that give you an advantage. (i.e one sided props)",
	"4.) The purpose of this gamemode isn't for being sandbox, don't spawn too many props.",
	"5.) Obey the New Life Rule rule.",
	"   a. If you are called back to the location, do not do it.",
	"   b. Do not void a situation, roleplay what just happened.",
	"   c. Do not pick up items you left, you died remember?",
	"   d. There should be a minimum of two minutes before returning.",
	"6.) Do not kill for revenge.",
	"   a. Killing someone else who has killed you multiple times is not permitted, report them.",
	"7.) If you no longer need props you spawned, delete them.",
	"8.) Do not advertise in OOC chat.",
	"   a. This includes advertising other servers/communities.",
	"   b. This includes roleplay situations.",
	"   c. Use /advertise instead!",
	"9.) Do not flood OOC with useless conversations.",
	"   a. This includes complaining about you being killed.",
	"   b. This includes you being arrested.",
	"   c. This includes any flaming.",
	"   d. Take up the situation with private messages.",
	"10.) Do not say anything to offend others.",
	"   a. Certain situations may be allowed in roleplay.",
	"11.) Do not prop climb. This includes you assisting others propclimb.",
	"12.) If there is a hostage taker, do not kill the hostage taker, try to negotiate first!",
	"   a. Killing the hostage taking should be a LAST RESORT.",
	"13.) Do not use in-game items for real life benefits (i.e. selling hats for real life money)",
	"14.) Do not prop push/kill others.",
	"15.) Do not kill others just because of a job. (Also see rule rule 1d)",
	"16.) Do not kill others while they are typing.",
	"   a. Players who are typing have their hand in their ear.",
	"17.) Mayors must warrant players only with a valid reason.",
	"18.) Government officials may not participate in illegal activities.",
	" ",
	"The offenders will face the following: Warning => Kick => Ban => Permanent ban.",
	" "
};

function PANEL:Init()
	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	for k, v in ipairs(RULES) do
		local label = self.list:AddItem("DLabel");
		label:Dock(TOP);
		label:SetTextColor( Color(80, 80, 80, 255) );
		label:SetText(v);
	end;

	-- This is used to add an extra gap to read easier.
	local label = self.list:AddItem("DLabel");
	label:Dock(TOP);
	label:DockMargin(2, 2, 2, 2);
	label:SetTextColor( Color(80, 80, 80, 255) );
	label:SetText("");
end;

vgui.Register("ps_Rules", PANEL, "Panel");