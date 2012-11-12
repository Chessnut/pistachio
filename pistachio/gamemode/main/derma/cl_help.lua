if (SERVER) then return; end;

local PANEL = {};

local help = {};

help["How do I open this menu again?"] = [[
To open this menu again, press F1.
]];

help["What is Pistachio?"] = [[
Pistachio is a simple role-play gamemode that relies on players, rather than features, to do fun things.
The gamemode is player driven, allowing players to freely role-play in an unrestricted environment.
Other gamemodes usually have limitations that make it hard to be creative, but that is the opposite with
Pistachio.
]];

help["How do I get a job?"] = [[
Getting a job requires your imagination. This gamemode is player driven, meaning
you decide what you want to happen. Type /job followed by what you want your job to be.
To assist with common jobs that are for selling items, you can visit the market in the Market tab.
There are however some default jobs groups that're listed within the Commands tab of this menu.
]];

help["Where did my paychecks go?"] = [[
Paychecks are sent to your mailbox, which are the mailboxes that glow. Just press your Use button
while aiming at one to bring up a menu, then if you have a Paycheck item, press "Take All".
]];

help["Why did I lose karma?"] = [[
Losing karma is caused by you killing someone. The less karma you have, the less
damage you inflict onto others and the longer it takes for you to spawn.
]];

help["How do I get karma?"] = [[
Karma will be given once every ten minutes. Having more karma does the opposite of
having bad karma.
]];

function PANEL:Init()
	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	for k, v in pairs(help) do
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

vgui.Register("ps_Information", PANEL, "Panel");