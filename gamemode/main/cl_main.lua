if (SERVER) then return; end;

timer.Destroy("HintSystem_OpeningMenu");
timer.Destroy("HintSystem_Annoy2");
timer.Destroy("HintSystem_Annoy1");

PS_CVAR_HEADBOB = CreateClientConVar("ps_headbobscale", "0", true, false);
PS_CVAR_OOC = CreateClientConVar("ps_showooc", "1", true, false);
PS_CVAR_SHOWVOTE = CreateClientConVar("ps_showmyvote", "1", true, true);
PS_CVAR_OUTLINE = CreateClientConVar("ps_hudoutline", "1", true, false);
PS_CVAR_WRAP = CreateClientConVar("ps_hudwrap", "0.25", true, false);

pistachio.lostFocus = pistachio.lostFocus or false;
pistachio.lostFocusTime = pistachio.lostFocusTime or 0;
pistachio.tips = {
	"Printers can have power restored by pressing E on them.",
	"Some foods will restore health while others restore stamina.",
	"Paychecks can be found in your mailbox.",
	"Items will take a while to be delivered to your mailbox.",
	"Rope can be used to restrain others.",
	"Money printers will emit a beeping noise once every five seconds.",
	"Storage items can be used to transportion of other items.",
	"Stock of items will go up once every 24 hours.",
	"Dyes can change the color of a white shirt.",
	"Life insurance reduces the loss of money on death.",
	"ATMs can be used to store money to prevent further loss on death.",
	"Weapons are usually strictly prohibited.",
	"Weapon accuracy will worsen while you're moving.",
	"Weapon accuracy can be improved by using ironsights.",
	"You can resign from your job any time using /resign.",
	"You can allow others access to your entities with /GiveOwnership <name>.",
	"You can revoke access to your entities with /TakeOwnership <name>",
	"Certain chat modes will have shortcuts.",
	"Yelling is displayed using a light green color.",
	"Whispering is displayed using a light blue color.",
	"Script updates can be seen on the Changelog section of the main menu.",
	"You can access the main menu by pressing F1.",
	"Your karma will go up once every ten minutes."
};
pistachio.tip = "Tip: "..table.Random(pistachio.tips);

surface.CreateFont( "ps_HUDFont", {
	font = "Tahoma",
	size = 14,
	weight = 400,
	antialias = true,
	outline = true
} );

surface.CreateFont( "ps_TargetFont", {
	font = "Tahoma",
	size = 18,
	weight = 800,
	antialias = true,
} );

surface.CreateFont( "ps_TipFont", {
	font = "Tahoma",
	size = 14,
	weight = 400,
	antialias = true,
	outline = true
} );

surface.CreateFont( "ps_TargetFontSmall", {
	font = "Tahoma",
	size = 16,
	weight = 800,
	antialias = true,
} );

surface.CreateFont( "ps_TargetFontLarge", {
	font = "Tahoma",
	size = 24,
	weight = 800,
	antialias = true,
	outline = true
} );

surface.CreateFont( "ps_TargetFontHuge", {
	font = "Tahoma",
	size = 72,
	weight = 800,
	antialias = true,
	outline = true
} );

surface.CreateFont( "ps_TitleFont", {
	font = "Tahoma",
	size = 18,
	weight = 800,
	antialias = true,
} );

surface.CreateFont( "ps_DataText", {
	font = "Arial",
	size = 16,
	weight = 300,
	antialias = true
} );

include("sh_main.lua");
include("cl_skin.lua");

local deltaAlpha = 0;
local alpha = 0;

pistachio.loaded = pistachio.loaded or false;

function GM:DrawUpperInfo(x, y, icon, text, shouldDrawCallback, alpha)
	local shouldDraw = true;

	if (!alpha) then
		alpha = 255;
	end;

	if (shouldDrawCallback) then
		shouldDraw = shouldDrawCallback(x, y);
	end;

	if (shouldDraw != false) then
		surface.SetFont("ps_HUDFont");

		local width, height = surface.GetTextSize(text or "");
		local maxWidth = ScrW() * PS_CVAR_WRAP:GetFloat();

		draw.RoundedBox( 4, x, y, 26, 26, Color(0, 0, 0, alpha * 0.78) );
		draw.RoundedBox( 4, x + 26 + 4, y, width + 12, 26, Color(0, 0, 0, alpha * 0.78) );

		if (PS_CVAR_OUTLINE:GetInt() > 0) then
			surface.SetDrawColor(250, 250, 250, alpha * 0.031);
			surface.DrawRect(x + 33, y + 3, width + 6, 20);

			surface.SetDrawColor(250, 250, 250, 8);
			surface.DrawRect(x + 3, y + 3, 20, 20);
		end;

		surface.SetDrawColor(255, 255, 255, alpha);
		surface.SetMaterial( Material(icon) );
		surface.DrawTexturedRect(x + 5, y + 5, 16, 16);

		draw.SimpleText(text, "ps_HUDFont", x + 36, y + 13, Color(255, 255, 255, alpha), 0, 1);

		local totalHeight = y;
		local totalWidth = (width + 12) + x + 34;

		if (totalWidth >= maxWidth) then
			local addition = 30;

			totalHeight = y + addition;
			totalWidth = 8;
		end;

		return totalWidth, totalHeight;
	else
		return x, y;
	end;
end;

local loadingAlpha = 255;
local loadingAlphaDelta = loadingAlpha;
local loadingAlphaDelta2 = loadingAlpha;

pistachio.totalVars = pistachio.totalVars or 1;
pistachio.sendVars = pistachio.sendVars or 0;

net.Receive("ps_Progress", function(length)
	pistachio.sendVars = pistachio.sendVars + net.ReadUInt(8);
end);

net.Receive("ps_TotalVars", function(length)
	pistachio.totalVars = net.ReadUInt(16);

	print("expectation => "..pistachio.totalVars);
end);

loadingDrawn = loadingDrawn or false;

function GM:HUDPaintIntro()
	if (!loadingDrawn) then
		local percentage = pistachio.sendVars / pistachio.totalVars;

		if (percentage < 1) then
			loadingAlpha = 255;
		else
			loadingAlpha = 0;
		end;

		loadingAlphaDelta = math.Approach(loadingAlphaDelta, loadingAlpha, FrameTime() * 150);

		timer.Simple(5, function()
			loadingAlphaDelta2 = math.Approach(loadingAlphaDelta2, loadingAlpha, FrameTime() * 125);
		end);
		
		if (loadingAlphaDelta2 > 0) then
			surface.SetDrawColor(0, 0, 0, loadingAlphaDelta2);
			surface.DrawRect( 0, 0, ScrW(), ScrH() );

			surface.SetDrawColor(255, 255, 255, loadingAlphaDelta);
			surface.DrawRect(ScrW() * 0.25, ScrH() * 0.5, ScrW() * 0.5, ScrH() * 0.05);

			surface.SetDrawColor(0, 0, 0, loadingAlphaDelta);
			surface.DrawRect(ScrW() * 0.25 + 2, ScrH() * 0.5 + 2, ScrW() * 0.5- 4, ScrH() * 0.05 - 4);

			surface.SetDrawColor(255, 255, 255, loadingAlphaDelta);
			surface.DrawRect(ScrW() * 0.25 + 2, ScrH() * 0.5 + 2, ScrW() * (0.5 * percentage) - 4, ScrH() * 0.05 - 4);

			local percentageString = math.Round(percentage, 2) * 100;
			
			draw.SimpleText("Loading... "..percentageString.."%", "ps_TargetFontLarge", ScrW() * 0.25, ScrH() * 0.6, Color(255, 255, 255, loadingAlphaDelta), 0, 4);

			draw.SimpleText(pistachio.tip, "ps_TipFont", ScrW() * 0.5, ScrH() * 0.95, Color(255, 255, 255, loadingAlphaDelta), 1, 1);
		end;

		if (loadingAlphaDelta2 < 1) then
			loadingDrawn = true;

			if ( !IsValid(pistachio.menu) ) then
				pistachio.menu = vgui.Create("ps_Menu");
			end;
		end;
	end;
end;

local deathAlpha = 0;
local deathAlphaDelta = deathAlpha;

function GM:HUDPaintDeath()
	local text = "";

	if ( (!LocalPlayer():Alive() and LocalPlayer().deathTime or 0) >= CurTime() ) then
		deathAlpha = 255;

		local time = string.FormattedTime(math.max(LocalPlayer().deathTime - CurTime(), 0), "%02i:%02i");
		local timePhrase = "second(s)";

		if (LocalPlayer().deathTime - CurTime() >= 60) then
			timePhrase = "minute(s)";
		end;

		text = "You must wait "..time.." "..timePhrase.." before spawning.";
	else
		timer.Simple(2.5, function()
			deathAlpha = 0;
		end);

		text = "You're now being spawned.";
	end;

	deathAlphaDelta = math.Approach(deathAlphaDelta, deathAlpha, FrameTime() * 100);

	surface.SetDrawColor(0, 0, 0, deathAlphaDelta);
	surface.DrawRect( 0, 0, ScrW(), ScrH() );

	draw.SimpleText(text, "ps_TargetFontLarge", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, deathAlphaDelta), 1, 1);
	draw.SimpleText(pistachio.tip, "ps_TipFont", ScrW() * 0.5, ScrH() * 0.95, Color(255, 255, 255, deathAlphaDelta), 1, 1);
end;

local arrestAlpha = 0;
local arrestAlphaDelta = arrestAlpha;

function GM:HUDPaintArrest()
	local text = "";

	if ( LocalPlayer():Alive() and (LocalPlayer().arrestTime or 0) >= CurTime() and LocalPlayer():IsArrested() ) then
		local timePhrase = "second(s)";
		local time = string.FormattedTime(math.max(LocalPlayer().arrestTime - CurTime(), 0), "%02i:%02i");

		if (LocalPlayer().arrestTime - CurTime() >= 60) then
			timePhrase = "minute(s)";
		end;

		text = "You're arrested for "..time.." more "..timePhrase..".";
		arrestAlpha = 255;
	else
		arrestAlpha = 0;
	end;

	surface.SetDrawColor(0, 0, 0, 255);
	surface.DrawRect(0, 0, ScrW(), ScrH() * 0.1 * (arrestAlphaDelta / 255));

	surface.SetDrawColor(0, 0, 0, 255);
	surface.DrawRect(0, ScrH() * (1 - (0.1 * (arrestAlphaDelta / 255))), ScrW(), ScrH() * 0.1);

	arrestAlphaDelta = math.Approach(arrestAlphaDelta, arrestAlpha, FrameTime() * 100);

	draw.SimpleText(text, "ps_TargetFontLarge", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, arrestAlphaDelta), 1, 1);
end;

local tieAlpha = 0;
local tieAlphaDelta = tieAlpha;

function GM:HUDPaintRestrained()
	if ( LocalPlayer():GetPublicVar("tied") ) then
		tieAlpha = 255;
	else
		tieAlpha = 0;
	end;

	tieAlphaDelta = math.Approach(tieAlphaDelta, tieAlpha, FrameTime() * 100);

	draw.SimpleText("You're currently tied.", "ps_TargetFontLarge", ScrW() * 0.5, ScrH() * 0.25, Color(255, 255, 255, tieAlphaDelta), 1, 1);
end;

local deltaPosition = Vector(0, 0, 0);
local blacklist = {
	"weapon_physgun",
	"weapon_physcannon",
	"gmod_tool",
	"pistachio_hands"
};

function GM:HUDPaint()
	if ( IsValid( LocalPlayer() ) ) then
		if (IsValid( LocalPlayer():GetActiveWeapon() ) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then
			return;
		end;
		
		self:HUDDrawTargetID();
		self:HUDDrawItems();

		local x, y = 8, 8;
		local money = LocalPlayer():GetPrivateVar("money") or 0;
		local stamina = LocalPlayer():GetPrivateVar("stamina") or 0;
		local job = LocalPlayer():GetPublicVar("job") or "Unemployed";
		local health = LocalPlayer():Health();
		local title = LocalPlayer():GetPublicVar("title") or "";
		local armor = LocalPlayer():Armor();
		local flashlight = LocalPlayer():GetPrivateVar("flashlight") or 0;
		local karma = LocalPlayer():GetPrivateVar("karma") or 0;

		x, y = self:DrawUpperInfo(x, y, "icon16/coins.png", "Money: $"..money);
		x, y = self:DrawUpperInfo(x, y, "icon16/wrench.png", "Job: "..job, function(x, y)
			return string.lower(job) != "unemployed";
		end);
		x, y = self:DrawUpperInfo(x, y, "icon16/heart.png", "Health: "..health, function(x, y)
			return health <= 75;
		end);
		x, y = self:DrawUpperInfo(x, y, "icon16/shield.png", "Armor: "..armor, function(x, y)
			return armor > 0;
		end);
		x, y = self:DrawUpperInfo(x, y, "icon16/fire.png", "Flashlight: "..flashlight, function(x, y)
			return flashlight < 100;
		end);
		x, y = self:DrawUpperInfo(x, y, "icon16/lightning.png", "Stamina: "..stamina, function(x, y)
			return stamina < 100;
		end);
		x, y = self:DrawUpperInfo(x, y, "icon16/eye.png", "Title: "..title, function(x, y)
			return string.len(title) > 0;
		end);
		x, y = self:DrawUpperInfo(x, y, "icon16/star.png", "Karma: "..karma);


		local activeWeapon = LocalPlayer():GetActiveWeapon();

		if ( IsValid(activeWeapon) ) then
			local clipText = activeWeapon:Clip1();

			x, y = self:DrawUpperInfo(x, y, "icon16/gun.png", "Ammo: "..clipText, function()
				return !table.HasValue( blacklist, string.lower( activeWeapon:GetClass() ) );
			end);
		end;

		deltaPosition = LerpVector(FrameTime() * 10, deltaPosition, LocalPlayer():GetEyeTraceNoCursor().HitPos or vector_origin + Vector());

		x, y = deltaPosition:ToScreen().x, deltaPosition:ToScreen().y;
		x = x + math.cos(CurTime() * 0.75) * 6;
		y = y + math.sin(CurTime() * 0.95) * 12;

		surface.SetDrawColor(0, 0, 0, 255);
		surface.DrawRect( x - 1, y - 1, 5, 5 );
		surface.DrawRect( x - 10, y + 12, 5, 5 );
		surface.DrawRect( x + 8, y + 12, 5, 5 );

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( x, y, 3, 3 );
		surface.DrawRect( x - 9, y + 13, 3, 3 );
		surface.DrawRect( x + 9, y + 13, 3, 3 );

		self:HUDPaintRestrained();
		self:HUDPaintArrest();
		self:HUDPaintIntro();
		self:HUDPaintDeath();

		pistachio.chatBox:Paint();
		
		surface.SetFont("ps_DataText");

		local text = "Pistachio "..GAMEMODE.Version;
		local w, h = surface.GetTextSize(text);

		draw.SimpleText(text, "ps_DataText", (ScrW() - 8) + 1, 7, Color(0, 0, 0, 255), 2, 3);
		draw.SimpleText(text, "ps_DataText", ScrW() - 8, 6, Color(255, 255, 255, 255), 2, 3);
	end;
end;

function GM:RenderScreenspaceEffects()
	self.BaseClass:RenderScreenspaceEffects();

	local info = {};
	info["$pp_colour_addr"] = 0;
	info["$pp_colour_addg"] = 0;
	info["$pp_colour_addb"] = 0;
	info["$pp_colour_brightness"] = 0 - ( ( (arrestAlphaDelta) / 255 ) * 0.1 );
	info["$pp_colour_contrast"] = 1 + ( ( (arrestAlphaDelta) / 255 ) * 0.25 );
	info["$pp_colour_colour"] = (255 - arrestAlphaDelta) / 255;
	info["$pp_colour_mulr"] = 0;
	info["$pp_colour_mulg"] = 0;
	info["$pp_colour_mulb"] = 0;

	DrawColorModify(info);

	local drunk = LocalPlayer():GetPrivateVar("drunk") or 0;
	local additive = math.Clamp( (1 - drunk) * 0.1, 0.01, 0.2 );

	DrawMotionBlur(additive, math.Clamp(drunk, 0, 0.9), drunk);
end;

function GM:HUDDrawItems()
	for k, v in pairs( ents.FindByClass("pistachio_item") ) do
		local distance = v:GetPos():Distance( LocalPlayer():GetPos() );

		if (distance <= 256) then
			local position = v:LocalToWorld( v:OBBCenter() ) + Vector(0, 0, v:OBBMaxs().y - v:OBBMins().y) + Vector(0, 0, 8);
			local key = v:GetItemID();

			if (key) then
				local itemTable = pistachio.item:Get(key);

				if (itemTable) then
					local screenPos = position:ToScreen();
					local color = pistachio.itemColors["none"];
					local alpha = 255 - math.Clamp(distance, 0, 255);
					local title = itemTable.name;
					local outlineColor = Color(0, 0, 0, alpha);

					if ( itemTable.class and pistachio.itemColors[itemTable.category] ) then
						color = pistachio.itemColors[itemTable.category];
					end;

					draw.SimpleTextOutlined(title, "ps_TargetFont", screenPos.x, screenPos.y, Color(color.r, color.g, color.b, alpha), 1, 1, 1, outlineColor);
					draw.SimpleTextOutlined(itemTable.description or "No description available.", "ps_TargetFont", screenPos.x, screenPos.y + 24, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor);
				end;
			end;
		end;
	end;

	for k, v in pairs( ents.FindByClass("pistachio_money") ) do
		local distance = v:GetPos():Distance( LocalPlayer():GetPos() );

		if (distance <= 256) then
			local position = v:LocalToWorld( v:OBBCenter() ) + Vector(0, 0, v:OBBMaxs().y - v:OBBMins().y) + Vector(0, 0, 8);
			local screenPos = position:ToScreen();
			local alpha = 255 - math.Clamp(distance, 0, 255);
			local outlineColor = Color(0, 0, 0, alpha);
			local increment = 0.5;

			if (v.deltaMoney) then
				local difference = v:GetMoney() - v.deltaMoney;

				if (difference >= 1000) then
					increment = 50;
				elseif (difference >= 100) then
					increment = 5;
				end;
			end;

			v.deltaMoney = math.Approach(v.deltaMoney or 0, v:GetMoney(), increment);

			draw.SimpleTextOutlined("$"..math.floor(v.deltaMoney), "ps_TargetFont", screenPos.x, screenPos.y, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor);
		end;
	end;

	for k, v in pairs( ents.FindByClass("pistachio_crate") ) do
		local distance = v:GetPos():Distance( LocalPlayer():GetPos() );

		if (distance <= 256) then
			local position = v:LocalToWorld( v:OBBCenter() ) + (Vector(0, 0, v:OBBMaxs().y - v:OBBMins().y) * 1.25);
			local screenPos = position:ToScreen();
			local alpha = 255 - math.Clamp(distance, 0, 255);
			local outlineColor = Color(0, 0, 0, alpha);
			local uniqueID = v:GetItemID();
			local itemTable = pistachio.item:Get(uniqueID);

			if (itemTable) then
				local name = itemTable.name;

				draw.SimpleTextOutlined(name, "ps_TargetFont", screenPos.x, screenPos.y, Color(225, 175, 85, alpha), 1, 1, 1, outlineColor);

				if (IsValid(v) and v:GetWeight() and v:GetMaxWeight() and v:GetMaxWeight() > 0) then
					draw.SimpleTextOutlined("Weight: "..(v:GetWeight() or 0).."/"..(v:GetMaxWeight() or 0), "ps_TargetFont", screenPos.x, screenPos.y + 24, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor);
				end;
			end;
		end;
	end;
end;

local targetAlpha = 0;
local targetAlphaDelta = 0;

function GM:HUDDrawTargetID()
	local trace = LocalPlayer():GetEyeTrace();
	local entity = trace.Entity;
	
	if ( IsValid(entity) ) then
		if ( entity:IsDoor() or entity:IsVehicle() ) then
			local y = 8;

			if ( entity:IsVehicle() ) then
				y = 16 + (entity:OBBMaxs().y - entity:OBBMins().y);
			end;

			local worldPosition = entity:LocalToWorld( entity:OBBCenter() ) + Vector(0, 0, y);
			local position = worldPosition:ToScreen();
			local distance = worldPosition:Distance( LocalPlayer():GetPos() );
			local alpha = 255 - math.Clamp(distance, 0, 255);
			local outlineColor = Color(0, 0, 0, alpha);

			if (distance <= 256) then
				local title = "Door";
				local owner = "You don't have access to this entity.";
				local color = Color(225, 175, 85);

				if ( IsValid( entity:GetAccessOwner() ) ) then
					color = team.GetColor( entity:GetAccessOwner():Team() );
				end;

				if ( entity:GetPublicVar("title") ) then
					title = entity:GetPublicVar("title");
				elseif ( IsValid( entity:GetAccessOwner() ) ) then
					if ( entity:GetAccessOwner() == LocalPlayer() ) then
						title = "This entity is owned by you.";
					else
						title = "This entity is owned by "..entity:GetAccessOwner():Name();
					end;
				elseif ( entity:IsVehicle() ) then
					title = "Vehicle";
				end;

				if ( entity:HasAccess( LocalPlayer() ) ) then
					owner = "You have access to this entity.";
				elseif ( entity:GetPublicVar("team") ) then
					if ( LocalPlayer():Team() == entity:GetPublicVar("team") ) then
						owner = "You have access to this door.";
					end;

					color = team.GetColor( entity:GetPublicVar("team") );
				elseif ( entity:GetPublicVar("unownable") ) then
					owner = "This door is unownable.";
				elseif ( !entity:IsAccessed() ) then
					owner = "This entity is for sale.";
				end;
			
				draw.SimpleTextOutlined(title, "ps_TargetFont", position.x, position.y, Color(color.r, color.g, color.b, alpha), 1, 1, 1, outlineColor);
				draw.SimpleTextOutlined(owner, "ps_TargetFontSmall", position.x, position.y + 22, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor);
			end;
		elseif (entity:GetClass() == "pistachio_mailbox") then
			local position = entity:LocalToWorld( entity:OBBCenter() ) + Vector(0, 0, 42);
			local distance = position:Distance( LocalPlayer():GetPos() );
			local alpha = 255 - math.Clamp(distance * 0.5, 0, 255);
			local screenPos = position:ToScreen();
			local items = 0;

			for k, v in pairs( LocalPlayer():GetMailBox() ) do
				items = items + LocalPlayer():GetMailBoxAmount(k);
			end;

			local description = "You have "..items.." item(s).";
			local outlineColor = Color(0, 0, 0, alpha);

			draw.SimpleTextOutlined("Mailbox", "ps_TargetFont", screenPos.x, screenPos.y, Color(225, 175, 85, alpha), 1, 1, 1, outlineColor);
			draw.SimpleTextOutlined(description, "ps_TargetFontSmall", screenPos.x, screenPos.y + 22, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor);
		end;
	end;

	for k, entity in pairs( player.GetAll() ) do
		if ( IsValid(entity) and entity:Alive() ) then
			local worldPosition = entity:GetPos() + entity:OBBCenter() + Vector(0, 0, 54);
			local position = worldPosition:ToScreen();
			local distance = worldPosition:Distance( LocalPlayer():GetPos() );
			local alpha = 255 - math.Clamp(distance * 0.75, 0, 255);
			local teamColor = team.GetColor( entity:Team() );
			local outlineColor = Color(0, 0, 0, alpha);

			if (distance <= 512) then
				local y = position.y - 22;

				if ( entity:GetPublicVar("tied") ) then
					draw.SimpleTextOutlined("This person is tied.", "ps_TargetFontSmall", position.x, y, Color(255, 255, 25, alpha), 1, 1, 1, outlineColor); y = y + 22;
				end;

				if ( entity:GetPublicVar("warranted") ) then
					draw.SimpleTextOutlined("Warranted", "ps_TargetFontSmall", position.x, y, Color(255, 25 * (math.sin(CurTime() * 1.25) * 10.2), 25 * (math.sin(CurTime() * 1.25) * 10.2), alpha), 1, 1, 1, outlineColor); y = y + 22;
				end;

				draw.SimpleTextOutlined(entity:Name(), "ps_TargetFont", position.x, y, Color(teamColor.r, teamColor.g, teamColor.b, alpha), 1, 1, 1, outlineColor); y = y + 22;

				if (entity:GetPublicVar("job") and string.len( entity:GetPublicVar("job") ) > 0 and entity:GetPublicVar("job") != "Unemployed") then
					draw.SimpleTextOutlined(entity:GetPublicVar("job") or "Unemployed", "ps_TargetFontSmall", position.x, y, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor); y = y + 22;
				end;

				if ( entity:GetPublicVar("title") ) then
					draw.SimpleTextOutlined(entity:GetPublicVar("title") or "", "ps_TargetFontSmall", position.x, y, Color(255, 255, 255, alpha), 1, 1, 1, outlineColor); y = y + 22;
				end;
			end;
		end;
	end;
end;

local deltaDrunk = 0;
local deltaSpeed = 0;

function GM:CalcView(client, origin, angles, fov)
	local speed = client:GetVelocity():Length2D();
	local percentage = PS_CVAR_HEADBOB:GetFloat();

	if ( !client:IsOnGround() ) then
		speed = 0;
	end;

	deltaSpeed = math.Approach(deltaSpeed, speed, 0.005);

	local view = self.BaseClass:CalcView(client, origin, angles, fov);
	deltaDrunk = math.Approach(deltaDrunk, LocalPlayer():GetPrivateVar("drunk") or 0, 0.0005);

	view.angles = view.angles + (Angle(math.sin(CurTime() * math.sin(16) * 1.5) * 5, math.cos(CurTime() * math.sin(16) * 0.75) * 16, math.cos(CurTime() * math.sin(16) * 0.75) * 16) * deltaDrunk);
	view.angles = view.angles + Angle(math.sin( CurTime() * (client:GetStepSize() * 0.1) * ( deltaSpeed / client:GetRunSpeed() ) ) * (speed * 0.005), 0, 0) * percentage;

	local ragdoll = client:GetRagdollEntity();

	if ( IsValid(ragdoll) and !client:Alive() ) then
		local index = ragdoll:LookupAttachment("eyes");
		local attachment = ragdoll:GetAttachment(index);

		view.angles = attachment.Ang;
		view.origin = attachment.Pos;
	end;

	return view;
end;

function GM:OnPlayerChat(client, text, teamChat, dead)
	if ( IsValid(client) ) then
		if (dead) then
			return true;
		end;

		if (client:GetPos():Distance( LocalPlayer():GetPos() ) <= 256) then
			chat.AddText(Color(255, 250, 150), client:Name()..": "..text);

			return true;
		end;
	else
		chat.AddIconText("icon16/server.png", Color(100, 100, 100), "Console", Color(255, 255, 255), ": "..text);

		return true;
	end;

	return true;
end;

function GM:InitPostEntity()
	local delay = LocalPlayer():Ping() / 100;

	timer.Simple(delay, function()
		net.Start("ps_PlayerGetData");
		net.SendToServer();

		pistachio.chatBox:Toggle(true);
	end);
end;

function GM:DrawDeathNotice(x, y)
	return;
end;

function GM:PlayerNoClip(client, noclipping)
	return client:IsAdmin();
end;

function GM:HUDShouldDraw(element)
	if (element == "CHudHealth" or element == "CHudBattery" or element == "CHudAmmo" or element == "CHudCrosshair") then
		return false;
	end;

	return true;
end;

function GM:GetMarketItemName(itemTable)
	return itemTable.name;
end;

function GM:ShouldEnableOrderButton(itemTable)
	return true;
end;

function GM:GetOrderButtonText(itemTable)
	if (itemTable.price and itemTable.price > 0) then
		return "$"..itemTable.price;
	else
		return "Free";
	end;
end;

function GM:PreDrawHalos()
	local color = Color(255, 0, 0, 255);
	local mailBox = LocalPlayer():GetMailBox();
	local realItems = 0;

	for k, v in pairs(mailBox) do
		realItems = realItems + LocalPlayer():GetMailBoxAmount(k);
	end;

	if (realItems > 0) then
		color = Color(0, 255, 0, 255);
	end;

	halo.Add(ents.FindByClass("pistachio_mailbox"), color, 5, 5, 0.5);
end;

function GM:ForceDermaSkin()
	return "Pistachio";
end;

local nextPart = 0;
local nextTip = 0;

function GM:Think()
	if ( nextPart < CurTime() ) then
		for k, v in pairs( player.GetAll() ) do
			local name = v:GetPublicVar("particle");

			if (name and name != "") then
				local position = v:GetPos() + v:OBBCenter();
				local emitter = ParticleEmitter(position);
				local particle = emitter:Add( name, position + (VectorRand() * 25) );

				if (particle) then
					particle:SetColor(math.random(100, 255), math.random(100, 255), math.random(100, 255), 50);
					particle:SetStartAlpha(0);
					particle:SetEndAlpha(50);
					particle:SetRollDelta( math.random(0.25, 1) );
					particle:SetVelocity( Vector( math.random(-5, 5), math.random(-5, 5), math.random(-1, 1) ) );
					particle:SetDieTime(3);
					particle:SetLifeTime(1);
					particle:SetStartSize(5);
					particle:SetRoll( math.random(-360, 360) );
					particle:SetEndSize(0);
					particle:SetCollide(true);
					particle:SetBounce(0.25);
				end;

				emitter:Finish();
			end;
		end;

		nextPart = CurTime() + 0.2;
	end;

	if (!system.HasFocus() and !pistachio.lostFocus) then
		pistachio.lostFocus = true;
		pistachio.lostFocusTime = RealTime();
	elseif ( system.HasFocus() ) then
		pistachio.lostFocus = false;
	end;

	if ( nextTip < CurTime() ) then
		pistachio.tip = "Tip: "..table.Random(pistachio.tips);

		nextTip = CurTime() + 10;
	end;

	local shouldKick = cvars.Bool("ps_kickafk", true);

	if (shouldKick) then
		if (pistachio.lostFocus and RealTime() - pistachio.lostFocusTime >= 300) then
			RunConsoleCommand("melonsauce");
		end;
	end;
end;

net.Receive("ps_DeathTime", function(length)
	local deathTime = net.ReadInt(32);

	LocalPlayer().deathTime = deathTime;
end);

net.Receive("ps_ArrestTime", function(length)
	local arrestTime = net.ReadInt(32);

	LocalPlayer().arrestTime = arrestTime;
	
	local arrestMusic = CreateSound(LocalPlayer(), "music/HL2_song19.mp3");
	arrestMusic:Play();

	local time = math.ceil( LocalPlayer().arrestTime - CurTime() );

	if (time < 116) then
		timer.Simple(time, function()
			if (arrestMusic) then
				arrestMusic:FadeOut(10);
			end;
		end);
	end;
end)

function GM:HUDDrawScoreBoard()
end;

function GM:PlayerBindPress(client, bind, pressed)
	self.BaseClass:PlayerBindPress(client, bind, pressed);

	local value = self:ChatBoxBindPressed(client, bind, pressed);

	if (value == true) then
		return value;
	end;

	if ( string.find(string.lower(bind), "impulse 100") and client:InVehicle() ) then
		RunConsoleCommand("ps_honk");

		return true;
	end;
end;