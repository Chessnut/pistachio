include("sh_commands.lua");

pistachio.chatBox = pistachio.chatBox or {};
pistachio.chatBox.stored = pistachio.chatBox.stored or {};

function pistachio.chatBox:AddClass(class, prefixTable, canHear, appearance, canTalk, icon)
	if (CLIENT) then
		if (!canHear) then
			canHear = function(client)
				return LocalPlayer():GetPos():Distance( client:GetPos() ) <= 256 and client:Alive() and LocalPlayer():Alive();
			end;
		end;

		if (!appearance) then
			appearance = function(client, text, teamChat)
				local teamColor = team.GetColor( client:Team() );

				return {teamColor, client:Name()..": ", Color(255, 255, 255), text};
			end;
		end;
	end;

	if (!canTalk) then
		canTalk = function()
			return true;
		end;
	end;

	local commandString = "";

	for k, v in ipairs(prefixTable) do
		if (k != #prefixTable) then
			commandString = commandString..v..", ";
		else
			commandString = commandString..v;
		end;
	end;

	pistachio.command:CreateFake(commandString, "<text>");

	self.stored[class] = {class = class, canHear = canHear, prefixTable = prefixTable, appearance = appearance, canTalk = canTalk, icon = icon};
end;

function pistachio.chatBox:AddCallback(class, Callback)
	if ( self.stored[class] ) then
		self.stored[class].Callback = Callback;
	end;
end;

function pistachio.chatBox:GetClassByPrefix(message)
	for k, v in pairs(self.stored) do
		local prefixTable = v.prefixTable;

		for k2, v2 in pairs(prefixTable) do
			local length = string.len(v2);

			if ( string.sub(string.lower(message), 1, length) == string.lower(v2) ) then
				return v, v2;
			end;
		end;
	end;
end;

if (CLIENT) then
	net.Receive("ps_ChatText", function(length)
		local client = player.GetByID( net.ReadUInt(8) );
		local text = net.ReadString();
		local class, prefix = pistachio.chatBox:GetClassByPrefix(text);

		if (class) then
			if (class.class == "ooc" and PS_CVAR_OOC:GetInt() < 1) then
				return;
			end;

			if ( !class.canHear(client) ) then
				return;
			else
				text = string.sub(text, string.len(prefix) + 1);

				local content = class.appearance(client, text, teamChat);
				local icon;

				if (class.icon) then
					icon = class.icon(client);
				end;

				if (icon) then
					chat.AddIconText( icon, unpack(content) );
				else
					chat.AddText( unpack(content) );
				end;
			end;
		end;
	end);

	function pistachio.chatBox:Message(text)
		local text = net.ReadString();

		chat.AddIconText("icon16/world.png", Color(25, 255, 30), text);
	end;

	net.Receive("ps_GlobalMessage", function(length)
		pistachio.chatBox:Message(text);
	end);
else
	util.AddNetworkString("ps_ChatText");
	util.AddNetworkString("ps_GlobalMessage");

	function pistachio.chatBox:Message(text)
		net.Start("ps_GlobalMessage");
			net.WriteString(text);
		net.Broadcast();
	end;
end;

pistachio.chatBox:AddClass("ooc", {"//", "/ooc"}, function()
	return true;
end, function(client, text, teamChat)
	local teamColor = team.GetColor( client:Team() );

	return {Color(255, 25, 25), "[OOC] ", teamColor, client:Name(), Color(255, 255, 255), ":"..text};
end, function()
	return true
end, function(client)
	local isDonator = false;

	if ( evolve and client:EV_IsRank("donator") ) then
		isDonator = true;
	elseif ( client:IsUserGroup("donator") ) then
		isDonator = true;
	end;

	if ( client:IsSuperAdmin() ) then
		return "icon16/shield.png";
	elseif ( client:IsAdmin() ) then
		return "icon16/star.png";
	elseif (isDonator) then
		return "icon16/heart.png";
	end;
end);

pistachio.chatBox:AddClass("looc", {".//", "/looc"}, nil, function(client, text, teamChat)
	return {Color(255, 25, 25), "[LOOC] ", Color(255, 250, 150), client:Name()..":"..text};
end);

pistachio.chatBox:AddClass("me", {"/me"}, nil, function(client, text)
	return {Color(255, 250, 150), "**"..client:Name()..text};
end);

pistachio.chatBox:AddClass("yell", {"/yell", "/y"}, function(client)
	return LocalPlayer():GetPos():Distance( client:GetPos() ) <= 256 and client:Alive() and LocalPlayer():Alive();
end, function(client, text)
	return {Color(200, 250, 200), client:Name()..":"..text};
end);

pistachio.chatBox:AddClass("whisper", {"/whisper", "/w"}, function(client)
	return LocalPlayer():GetPos():Distance( client:GetPos() ) <= 72 and client:Alive() and LocalPlayer():Alive();
end, function(client, text)
	return {Color(200, 225, 250), client:Name()..":"..text};
end);

pistachio.chatBox:AddClass("radio", {"/radio", "/r"}, function(client)
	return (LocalPlayer():Team() == TEAM_POLICE or LocalPlayer():Team() == TEAM_MAYOR) and (client:Team() == TEAM_POLICE or client:Team() == TEAM_MAYOR);
end, function(client, text)
	return {Color(125, 255, 25), "[RADIO] "..client:Name(), Color(255, 255, 255), ":"..text};
end, function(client)
	if (client:Team() == TEAM_POLICE or client:Team() == TEAM_MAYOR) then
		return true;
	else
		client:Notify("You must be a government official to use the radio!");

		return false;
	end;
end, function()
	return "icon16/transmit_blue.png";
end);

pistachio.chatBox:AddClass("emergency", {"/911"}, function(client)
	return LocalPlayer():Team() == TEAM_POLICE;
end, function(client, text)
	return {Color(255, 25, 25), "[911] "..client:Name(), Color(255, 200, 200), ":"..text};
end, function(client)
	if (client:Team() != TEAM_CITIZEN and client:Team() != TEAM_CRIMINAL) then
		client:Notify("You must use /radio to contact your team!")

		return false;
	elseif (client:Team() == TEAM_CRIMINAL) then
		client:Notify("You aren't allowed to use /911!");

		return false;
	elseif ( (client.next911 or 0) < CurTime() ) then
		client.next911 = CurTime() + 5;

		return true;
	else
		client:Notify("You cannot use /911 yet!");
	end;
end, function()
	return "icon16/telephone.png";
end);

pistachio.chatBox:AddClass("broadcast", {"/broadcast"}, function(client)
	return true;
end, function(client, text)
	return {Color(255, 25, 25), "[Broadcast] "..client:Name(), Color(255, 255, 255), ":"..text};
end, function(client)
	if (client:Team() == TEAM_MAYOR) then
		return true;
	else
		client:Notify("You must be the mayor to broadcast a message!");

		return false;
	end;
end, function()
	return "icon16/bell.png"
end);

pistachio.chatBox:AddClass("advert", {"/advertise"}, function(client)
	return true;
end, function(client, text)
	return {Color(255, 200, 25), "[Advertisement] "..client:Name(), Color(255, 255, 255), ":"..text};
end, function(client)
	local money = client:GetMoney();

	if (money - 50 >= 0) then
		if ( (client.nextAdvert or 0) < CurTime() ) then
			client.nextAdvert = CurTime() + 60;

			return true;
		else
			client:Notify("You cannot make another advertisment yet!");

			return false;
		end;
	else
		client:Notify("You need $50 dollars to make an advertisement!");

		return false;
	end;
end, function()
	return "icon16/note.png"
end);

pistachio.chatBox:AddCallback("advert", function(client, text)
	if (client:GetMoney() - 50 >= 0) then
		client:TakeMoney(50);
	end;
end);