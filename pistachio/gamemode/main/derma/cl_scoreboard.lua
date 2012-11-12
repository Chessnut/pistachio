if (SERVER) then return; end;

surface.CreateFont( "ps_ScoreboardBig", {
	font = "Tahoma",
	antialias = true,
	size = 36,
	weight = 800
} );

surface.CreateFont( "ps_ScoreboardHuge", {
	font = "Tahoma",
	antialias = true,
	size = 48,
	weight = 800
} );

surface.CreateFont( "ps_ScoreboardHeader", {
	font = "Tahoma",
	antialias = true,
	size = 22,
	weight = 800,
} );

surface.CreateFont( "ps_ScoreboardText", {
	font = "Tahoma",
	antialias = true,
	size = 18,
	weight = 600
} );

local PANEL = {};

function PANEL:Init()
	self:SetSize(ScrW() * 0.45, ScrH() * 0.65);
	self:Center();

	self.hostName = self:Add("DLabel");
	self.hostName:Dock(TOP);
	self.hostName:SetTextColor( Color(255, 255, 255, 255) );
	self.hostName:SetExpensiveShadow( 2, Color(5, 5, 5, 255) );
	self.hostName:DockMargin(5, 5, 5, 25);
	self.hostName:SetFont("ps_ScoreboardBig");
	self.hostName:SetContentAlignment(5);
	self.hostName:SetText( GetHostName() );
	self.hostName:SizeToContents();

	self:DockPadding(5, 5, 5, 5);

	self.scroll = self:Add("DScrollPanel");
	self.scroll:Dock(FILL);

	self.teams = {};
end;

local gradientUp = surface.GetTextureID("gui/gradient_up");

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Panel", self, w, h);

	surface.SetDrawColor(25, 25, 25, 100);
	surface.SetTexture(gradientUp);
	surface.DrawTexturedRect(0, 0, w, h);
end;

function PANEL:Think()
	if ( IsValid(self.scroll) ) then
		for k, v in SortedPairs(team.GetAllTeams(), true) do
			if (!self.teams[k] and team.NumPlayers(k) > 0) then
				self.teams[k] = self.scroll:Add("ps_TeamItem");
				self.teams[k]:SetTeam(k);
				self.teams[k]:SizeToContents();

				self.scroll:AddItem( self.teams[k] );
			elseif (self.teams[k] and team.NumPlayers(k) < 1) then
				self.teams[k]:Remove();
			end;
		end;

		for k, v in SortedPairs( player.GetAll() ) do
			if ( !IsValid(v.score) and self.teams[ v:Team() ] ) then
				v.score = self.teams[ v:Team() ]:Add("ps_PlayerItem");
				v.score:SetPlayer(v);
			end;
		end;
	end;
end;

vgui.Register("ps_Scoreboard", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	self:Dock(TOP);
	self:DockMargin(3, 3, 3, 3);
	self:DockPadding(3, 3, 3, 3);
	self:SetTall(48);

	self.label = self:Add("DLabel");
	self.label:Dock(TOP);
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	self.label:SetExpensiveShadow( 1, Color(5, 5, 5, 255) );
	self.label:SetFont("ps_ScoreboardHeader");
end;

function PANEL:Think()
	local children = self:GetChildren();
	local tall = 0;
	local players = 0;

	for k, v in pairs(children) do
		if ( IsValid(v.player) and v.player:IsPlayer() ) then
			if (v.player:Team() != self.team) then
				v:Remove();
			end;

			tall = tall + v:GetTall() + 4;
			players = players + 1;
		end;
	end;

	surface.SetFont("ps_ScoreboardHeader");

	local w, h = surface.GetTextSize(self.label:GetText() or "");

	self:SetTall( math.max(tall + h + 8, 48) );

	if (players < 1) then
		self:Remove();
	end;
end;

function PANEL:SetTeam(teamID)
	if ( team.Valid(teamID) ) then
		self.team = teamID;
		self.label:SetText( team.GetName(teamID) );
	end;
end;

local gradientDown = surface.GetTextureID("gui/gradient_down");

function PANEL:Paint(w, h)
	if (self.team) then
		local color = team.GetColor(self.team);

		derma.SkinHook("Paint", "DPanel", self, w, h);

		surface.SetDrawColor(color.r, color.g, color.b, 200);
		surface.DrawRect(0, 0, w, h);

		surface.SetDrawColor(25, 25, 25, 75);
		surface.SetTexture(gradientDown);
		surface.DrawTexturedRect(0, 0, w, h);
	end;
end;

vgui.Register("ps_TeamItem", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	self:Dock(TOP);
	self:DockMargin(3, 3, 3, 1);
	self:DockPadding(3, 3, 3, 3);
	self:SetTall(48);

	self.avatar = self:Add("SpawnIcon");
	self.avatar:Dock(LEFT);
	self.avatar:SetSize(46, 46);
	self.avatar:DockPadding(3, 3, 3, 3);

	self.avatar.DoClick = function()
		if ( IsValid(self.player) ) then
			self.player:ShowProfile();
		end;
	end;

	self.name = self:Add("DLabel");
	self.name:SetFont("ps_ScoreboardText");
	self.name:SetTextColor( Color(100, 100, 100, 100) );
	self.name:Dock(FILL);
	self.name:DockMargin(5, 5, 5, 5);

	self.ping = self:Add("DLabel");
	self.ping:SetFont("ps_ScoreboardText");
	self.ping:SetTextColor( Color(100, 100, 100, 100) );
	self.ping:Dock(RIGHT);
	self.ping:DockMargin(5, 5, 25, 5);
end;

function PANEL:Think()
	if ( IsValid(self.player) ) then
		self.name:SetText( self.player:Name() );
		self.name:SizeToContents();

		self.ping:SetText( self.player:Ping() );
		self.ping:SizeToContents();

		if ( IsValid(self.player) and IsValid(self.avatar) ) then
			if (self.player:GetModel() != self.avatar.playerModel) then
				self.avatar:SetModel( self.player:GetModel() );
				self.avatar.playerModel = self.player:GetModel();
			end;
		end;
	end;
end;

local gradient = surface.GetTextureID("gui/center_gradient");

local developer = Material("icon16/wrench_orange.png");
local superAdmin = Material("icon16/shield.png");
local admin = Material("icon16/star.png");
local donator = Material("icon16/heart.png");
local user = Material("icon16/user.png");

function PANEL:Paint(w, h)
	if ( IsValid(self.player) ) then
		derma.SkinHook("Paint", "Panel", self, w, h);

		surface.SetDrawColor(200, 200, 200, 225);
		surface.DrawRect(0, 0, w, h);

		local alpha = 100;

		if ( IsValid( LocalPlayer() ) and self.player == LocalPlayer() ) then
			alpha = math.Clamp(math.abs(math.sin(CurTime() * 0.75) * 255), 100, 255);
		end;

		surface.SetFont("ps_ScoreboardHuge");

		surface.SetDrawColor(255, 255, 255, alpha);
		surface.SetTexture(gradient);
		surface.DrawTexturedRect(0, 0, w, h);

		surface.SetDrawColor(255, 255, 255, 255);

		local isDonator = false;

		if ( evolve and self.player:EV_IsRank("donator") ) then
			isDonator = true;
		elseif ( self.player:IsUserGroup("donator") ) then
			isDonator = true;
		end;

		if ( self.player:IsDeveloper() ) then
			surface.SetMaterial(developer);
		elseif ( self.player:IsSuperAdmin() ) then
			surface.SetMaterial(superAdmin);
		elseif ( self.player:IsAdmin() ) then
			surface.SetMaterial(admin);
		elseif (isDonator) then
			surface.SetMaterial(donator);
		else
			surface.SetMaterial(user);
		end;

		surface.DrawTexturedRect(w - 20, (h * 0.5) - 8, 16, 16);
	end;
end;

function PANEL:SetPlayer(client)
	self.player = client;

	self.avatar:SetModel( self.player:GetModel() );
	self.avatar.playerModel = self.player:GetModel();
end;

vgui.Register("ps_PlayerItem", PANEL, "DPanel");

pistachio.scoreboard = pistachio.scoreboard or nil;

if ( IsValid(pistachio.scoreboard) ) then
	pistachio.scoreboard:Remove();
	pistachio.scoreboard = vgui.Create("ps_Scoreboard");
end;

function GM:ScoreboardShow()
	if ( !IsValid(pistachio.scoreboard) ) then
		pistachio.scoreboard = vgui.Create("ps_Scoreboard");
	end;

	pistachio.scoreboard:Show();
	pistachio.scoreboard:MakePopup();
end;

function GM:ScoreboardHide()
	if ( IsValid(pistachio.scoreboard) ) then
		pistachio.scoreboard:Remove();
	end;
end;