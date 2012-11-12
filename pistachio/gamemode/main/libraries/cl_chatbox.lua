local _R = debug.getregistry();

if (SERVER) then 
	concommand.Add("cHNfdHlwaW5n", function(p, c, a)
		local isTyping = tonumber( a[1] );

		if (IsValid(p) and isTyping) then
			p:SetNetworkedBool("typing", isTyping == 1);
		end;
	end);

	return;
end;

surface.CreateFont( "ps_ChatFont", {
	font = "Tahoma",
	size = 14,
	weight = 800,
	antialias = true,
} );

if (!pistachio.chatBox) then
	include("sh_chatbox.lua");
end;

pistachio.chatBox.width = 0.375;
pistachio.chatBox.height = 0.275;
pistachio.chatBox.padding = 10;
pistachio.chatBox.enabled = pistachio.chatBox.enabled or false;
pistachio.chatBox.messages = pistachio.chatBox.messages or {};

if ( IsValid(pistachio.chatBox.panel) ) then
	pistachio.chatBox.panel:Remove();
end;

function pistachio.chatBox:Toggle(preventShow)
	if ( !IsValid(self.panel) ) then
		self.panel = vgui.Create("EditablePanel");
		self.panel:ParentToHUD();
		self.panel:SetSize(ScrW() * self.width, ScrH() * self.height);
		self.panel:SetPos( self.padding, ScrH() - ( (ScrH() * self.height) + self.padding ) );
		self.panel:DockPadding(3, 3, 3, 3);
		self.panel:MakePopup();

		self.content = self.panel:Add("EditablePanel");
		self.content:Dock(FILL);
		self.content:DockPadding(3, 3, 3, 3);
		self.content:DockMargin(0, 0, 0, 3);

		self.panel.textBox = self.panel:Add("DTextEntry");
		self.panel.textBox:Dock(BOTTOM);
		self.panel.textBox:SetTabPosition(1);
		self.panel.textBox:SetAllowNonAsciiCharacters(true);
		self.panel.textBox:RequestFocus();

		self.panel.textBox.OnEnter = function(control)
			local text = control:GetValue();

			if (text and string.len(text) > 0) then
				RunConsoleCommand("say", text);
			end;

			self:Toggle();
		end;
	else
		self.panel.textBox:SetText("");

		if (preventShow) then
			self.enabled = false;
		else
			self.enabled = !self.enabled;
		end;
	end;

	if (self.enabled) then
		RunConsoleCommand("cHNfdHlwaW5n", "1");
	else
		RunConsoleCommand("cHNfdHlwaW5n", "0");
	end;

	self.panel:SetVisible(self.enabled);

	gui.EnableScreenClicker(self.enabled);
end;	

local pistachio = pistachio;
local surface = surface;
local math = math;
local draw = draw;
local string = string;

local function PUSH_INDEX(chatTable)
	if (chatTable.text and chatTable.currentIndex) then
		chatTable.currentIndex = chatTable.currentIndex + 1;

		local nextString = chatTable.text[chatTable.currentIndex];

		if (nextString and type(nextString) == "string") then
			return true;
		elseif (nextString) then
			local shouldStop = PUSH_INDEX(chatTable);

			return shouldStop;
		end;
	end;

	return false;
end;

function pistachio.chatBox:Paint()
	if (IsValid(self.panel) and self.messages and #self.messages > 0) then
		surface.SetFont("ps_ChatFont");

		local w, h = self.content:GetWide(), self.content:GetTall();
		local x, y = self.padding + 3, ScrH() * (1 - self.height) - 8;

		local realY = 0;

		for k, v in ipairs(self.messages) do
			local alpha = math.Clamp(255 * ( v.fade - CurTime() ), 0, 255);

			if (!v.fadedIn and CurTime() - v.fadeIn >= 0) then
				alpha = math.Clamp(765 * ( CurTime() - v.fadeIn ), 0, 255);

				if (alpha == 255) then
					v.fadedIn = true;
				end;
			elseif (!v.fadedIn) then
				alpha = 0;
			end;

			if (self.enabled) then
				alpha = 255;
			end;

			if (alpha > 0) then
				realY = realY + 1;
			end;

			if (!v.y) then
				v.y = 0;
			end;

			v.y = math.Approach(v.y, realY, FrameTime() * 30);

			v.currentText = "";
			v.currentColor = Color(255, 255, 255);
			v.lastX = 0;
			v.currentIndex = 1;

			for k2, v2 in ipairs(v.text) do
				local color = Color(v.currentColor.r, v.currentColor.g, v.currentColor.b, alpha);
				local outlineColor = Color(25, 25, 25, alpha);

				if (type(v2) == "table" and v2.r and v2.g and v2.b) then
					PUSH_INDEX(v);

					v.lastX = surface.GetTextSize(v.currentText);
					v.currentColor = Color(v2.r, v2.g, v2.b);
				elseif (type(v2) == "string" and string.len(v2) > 0 and k2 < #v.text) then
					local nextString = v.text[v.currentIndex + 1];

					v.currentText = v.currentText..v2;

					if (nextString and type(nextString) == "string") then
						v.currentIndex = v.currentIndex + 1;
						v.lastX = surface.GetTextSize(v.currentText);
						v.currentText = v.currentText..nextString;
					end;
				end;

				local additionalX = 0;

				if (v.icon) then
					surface.SetDrawColor(255, 255, 255, alpha);
					surface.SetMaterial( Material(v.icon) );
					surface.DrawTexturedRect(x + 6, y + ( (v.y - 1) * 16 ) + 5, 16, 16);

					additionalX = 20;
				end;

				if (type( v.text[v.currentIndex] ) == "string") then
					draw.SimpleTextOutlined(v.text[v.currentIndex], "ps_ChatFont", additionalX + (x + v.lastX) + 7, y + ( (v.y - 1) * 16 ) + 12, color, 0, 1, 1, outlineColor);
				end;
			end;
		end;

		if ( (#self.messages * 16) > h ) then
			table.remove(self.messages, 1);
		end;
	end;
end;

function pistachio.chatBox:Add(icon, ...)
	local index = #self.messages + 1;

	self.messages[index] = {
		icon = icon,
		text = {...},
		fade = CurTime() + 16,
		fadeIn = CurTime() + 0.05
	};

	local text = self:GetString(index);

	if (text) then
		print(text);
	end;

	surface.PlaySound("common/talk.wav");
end;

function pistachio.chatBox:GetString(index)
	local output = "";
	local chatTable = self.messages[index];

	if (chatTable and chatTable.text) then
		for k, v in pairs(chatTable.text) do
			if (type(v) == "string") then
				output = output..v;
			end;
		end;
	end;

	return output;
end;

function chat.AddText(...)
	pistachio.chatBox:Add(nil, ...);
end;

function chat.AddIconText(icon, ...)
	pistachio.chatBox:Add(icon, ...);
end;

function GM:ChatText(index, name, text, messageType)
	if (messageType == "none") then
		pistachio.chatBox:Add("icon16/comment.png", Color(255, 255, 255), text);
	end;

	return true;
end;

function GM:ChatBoxBindPressed(client, bind, pressed)
	if ( string.find(string.lower(bind), "messagemode") ) then
		if (!pressed) then
			pistachio.chatBox:Toggle();
		end;

		return true;
	end;
end;

concommand.Remove("lua_run_cl");

function GM:StartChat(teamSay)
	self.BaseClass:StartChat(teamSay);

	return true;
end;

function GM:FinishChat(teamSay)
	self.BaseClass:FinishChat(teamSay);

	return true;
end;

local playerMeta = _R.Player;

function playerMeta:IsTyping()
	return self:GetNetworkedBool("typing");
end;