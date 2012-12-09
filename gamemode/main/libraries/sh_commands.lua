pistachio.command = pistachio.command or {};
pistachio.command.stored = pistachio.command.stored or {};

function pistachio.command:CreateFake(command, help)
	self.stored[ string.lower(command) ] = {fake = true, help = help};
end;

function pistachio.command:Create(command, help, info, Callback, allowDead, userGroup)
	self.stored[ string.lower(command) ] = {info = info, help = help, Callback = Callback, allowDead = allowDead, userGroup = userGroup};
end;

function pistachio.command:Get(command)
	return self.stored[ string.lower( tostring(command) ) ];
end;

function pistachio.command:Run(commandTable, client, arguments)
	if ( !IsValid(client) ) then
		return;
	end;

	if (!client:Alive() and !commandTable.allowDead) then
		client:Notify("You cannot do that right now!");

		return;
	end;

	if (!commandTable) then
		client:Notify("The command \""..command.."\" is not valid!");

		return;
	end;

	if (commandTable.fake) then
		return;
	end;

	local userGroup = client:GetNWString("usergroup");
	
	if ( commandTable.userGroup and !string.find(userGroup, commandTable.userGroup) ) then
		client:Notify("You don't have permission to do that.");

		return;
	end;

	if (#arguments < 1 and commandTable.arguments) then
		client:Notify(commandTable.help or "This command doesn't have any help!");
	end;

	commandTable.Callback(client, arguments);
end;

function pistachio.command:PlayerSay(client, message, public)
	if (string.sub(message, 1, 1) == "/") then
		local command = string.match(message, "^.(%S+)");
		local commandTable = self:Get(command);

		if ( ( !commandTable or (commandTable and commandTable.fake) ) and pistachio.chatBox:GetClassByPrefix(message) ) then
			return message;
		end;

		message = string.gsub(message, "/", "");

		if (commandTable) then
			local arguments = string.gsub(message, command, "");

			client:ConCommand("pistachio "..command.." "..arguments);
		else
			client:Notify("That command doesn't exist!");
		end;

		return "";
	end;

	return message;
end;

if (SERVER) then
	concommand.Add("pistachio", function(client, command, arguments)
		if ( (client.nextCommand or 0) < CurTime() ) then
			if ( IsValid(client) and arguments[1] ) then
				local commandTable = pistachio.command:Get( arguments[1] );

				if (commandTable) then
					table.remove(arguments, 1);

					pistachio.command:Run(commandTable, client, arguments);
				end;
			end;

			client.nextCommand = CurTime() + 0.25;
		end;
	end);
end;