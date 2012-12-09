if (SERVER) then return; end;

surface.CreateFont( "ps_VoiceFont", {
	font = "Tahoma",
	size = 21,
	weight = 500,
	antialias = true
} );

local PANEL = {}

if ( IsValid(pistachio.voices) ) then
	pistachio.voices:Remove();
end;

pistachio.voices = vgui.Create("DPanel");

if ( IsValid(pistachio.voices) ) then
	pistachio.voices:SetDrawBackground(false);
	pistachio.voices:ParentToHUD();
	pistachio.voices:SetPos(ScrW() * 0.75, ScrH() * 0.4);
	pistachio.voices:SetWide(ScrW() * 0.175);
	pistachio.voices:SetTall(ScrH() * 0.4);
	pistachio.voices:DockPadding(3, 3, 3, 3);
end;

function PANEL:Init()
	self:Dock(BOTTOM);
	self:SetTall(38);
	self:DockPadding(3, 3, 3, 3);
	self:DockMargin(5, 5, 5, 5);

	self.label = self:Add("DLabel");
	self.label:Dock(FILL);
	self.label:SetFont("ps_VoiceFont");
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	self.label:SetExpensiveShadow( 1, Color(0, 0, 0, 255) );
	self.label:DockMargin(10, 5, 5, 5);
	self.label:SizeToContents();

	self.icon = self:Add("SpawnIcon");
	self.icon:Dock(LEFT);
	self.icon:SetSize(40, 38);
end

function PANEL:SetPlayer(client)
	self.player = client;
	self.playerSet = true;

	self.icon:SetModel( self.player:GetModel() );
	self.icon.playerModel = self.player:GetModel();

	self.label:SetText( client:Name() );
	self.label:SizeToContents();
end;

function PANEL:Think()
	if ( self.playerSet and IsValid(self.player) ) then
		if (IsValid(self.icon) and self.player:GetModel() != self.icon.playerModel) then
			self.icon:SetModel( self.player:GetModel() );
			self.icon.playerModel = self.player:GetModel();
		end;

		self.label:SetText( self.player:Name() );
		self.label:SizeToContents();
	else
		self:Remove();
	end;
end;

local gradientUp = surface.GetTextureID("gui/gradient_up");
local gradientDown = surface.GetTextureID("gui/gradient_down");

function PANEL:Paint(w, h)
	if ( IsValid(self.player) ) then
		local distance = LocalPlayer():GetPos():Distance( self.player:GetPos() );

		if (distance <= 512) then
			local teamColor = team.GetColor( self.player:Team() );
			local r, g, b, a = teamColor.r, teamColor.g, teamColor.b, math.Clamp( ( 512 - math.Clamp(distance, 0, 512) ) * 0.5, 0, 255 );
			local volume = self.player:VoiceVolume();

			draw.RoundedBox( 0, 0, 0, w, h, Color(r, g, b, a) );

			surface.SetDrawColor(5, 5, 5, a * 0.4);
			surface.SetTexture(gradientUp);
			surface.DrawTexturedRect(0, 0, w, h);

			draw.RoundedBox( 0, 47, 3, w - 50, h - 6, Color(0, 0, 0, a) );

			surface.SetDrawColor(225, 225, 225, a * 0.02);
			surface.SetTexture(gradientDown);
			surface.DrawTexturedRect(47, 3, w - 50, h - 6);

			draw.RoundedBox( 0, 48, 4, volume * w, h - 8, Color(volume * 255, 255 - (volume * 255), 0, a * 0.8) );

			self.label:SetVisible(true);
			self.label:SetTextColor( Color(255, 255, 255, a) );
			self.label:SetExpensiveShadow( 1, Color(0, 0, 0, a) );

			self.icon:SetVisible(true);
			self.icon:SetAlpha(a);
		else
			self.label:SetVisible(false);
			self.icon:SetVisible(false);
		end;
	end;
end;

vgui.Register("ps_VoicePanel", PANEL, "DPanel");

function GM:PlayerStartVoice(client)
	if ( IsValid(client) and !IsValid(client.voice) ) then
		client.voice = pistachio.voices:Add("ps_VoicePanel");
		client.voice:SetPlayer(client);
	end;
end;

function GM:PlayerEndVoice(client)
	if ( IsValid(client.voice) ) then
		client.voice:Remove();
	end;
end;