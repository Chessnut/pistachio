pistachio.command:Create("job", "<job>", "Specifies a job you want to be.", function(client, arguments)
	local data = table.concat(arguments, " ");

	if ( client:IsArrested() ) then
		client:Notify("You cannot change jobs while arrested!");

		return;
	end;

	if (string.find(data, "police") and client:Team() != TEAM_POLICE) then
		client:Notify("You must use /votecop to become a police officer!");

		return;
	end;

	if (string.len(data) < 1) then
		client:SetPublicVar("job", "Unemployed");
		client:Notify("You're now unemployed.");

		return;
	end;

	client:SetPublicVar("job", data);
	client:Notify("You've set your job to: "..data..".");
end);

pistachio.command:Create("setname", "<name>", "Specifies a name you want to be.", function(client, arguments)
	local data = table.concat(arguments, " ");

	if ( (client.nextNameChange or 0) < CurTime() ) then
		if (!data or string.len(data) < 1) then
			client:Notify("You must enter a valid name!");

			return;
		end;

		if (string.len(data) > 32) then
			data = string.sub(data, 1, 32);
		end;

		client:SetPublicVar("name", data);
		client:Notify("You've set your name to: "..data..".");
		client.nextNameChange = CurTime() + 30;
	else
		client:Notify("You cannot change your name yet!");
	end;
end);

pistachio.command:Create("title", "<title>", "Specifies a physics title about you.", function(client, arguments)
	local data = table.concat(arguments, " ");

	if (string.len(data) > 33) then
		data = string.sub(data, 1, 32);
	end;

	if (string.len(data) < 1) then
		client:SetPublicVar("title", "");
		client:Notify("You've removed your title.");

		return;
	end;

	client:SetPublicVar("title", data);
	client:Notify("You've set your title to: "..data..".");
end);

pistachio.command:Create("givemoney", "<amount>", "Gives money to the player you're looking at.", function(client, arguments)
	local amount = tonumber(arguments[1] or 0);

	if (amount and amount > 0) then
		amount = math.floor(amount);

		local trace = client:GetEyeTraceNoCursor();
		local entity = trace.Entity;

		if (IsValid(entity) and entity:IsPlayer() and entity:GetPos():Distance( client:GetPos() ) <= 256) then
			local money = client:GetPrivateVar("money");

			if (money - amount >= 0) then
				client:SetPrivateVar("money", money - amount);
				client:Notify("You've given $"..amount.." dollars to "..entity:Name()..".");

				local otherMoney = entity:GetPrivateVar("money");

				entity:SetPrivateVar("money", otherMoney + amount);
				entity:Notify("You've received $"..amount.." dollars from "..client:Name()..".");

				hook.Call("PlayerSaveData", GAMEMODE, client, false, true);
				hook.Call("PlayerSaveData", GAMEMODE, entity, false, true);
			else
				client:Notify("You don't have enough to give!");
			end;
		end;
	else
		client:Notify("You need to enter a valid amount!");
	end;
end);

pistachio.command:Create("changemodel", nil, "Opens a menu that allows you to change your model.", function(client, arguments)
	net.Start("ps_ChangeModel");
	net.Send(client);
end);

pistachio.command:Create("awardmoney", "<name> <amount>", "Give money to a person if needed to be refunded or if they have donated. <Super Admin only>", function(client, arguments)
if client:IsSuperAdmin() then
local name = tostring( arguments[1] );
local target = pistachio:GetPlayerByName(name);

if not target then
client:Notify("That's not a valid player!")
return
end

local amount = tonumber(arguments[2])
if not amount or not arguments[2] then
client:Notify("You need to enter a valid amount!")
return
end
local person = target:Nick()
if target == client then
person = "yourself"
end
target:ChatPrint("You awarded "..person.." with $"..amount..".")
target:AddMoney(amount);
target:ChatPrint("You have been awarded with $"..amount.." by "..client:Nick()..".")
else

client:Notify("You need to be a super admin!")
end
end);

pistachio.command:Create("awardkarma", "<name> <amount>", "Give karma to a person if needed to be refunded or if they have donated. <Super Admin only>", function(client, arguments)
if client:IsSuperAdmin() then
local name = tostring( arguments[1] );
local target = pistachio:GetPlayerByName(name);

if not target then
client:Notify("That's not a valid player!")
return
end

local amount = tonumber(arguments[2])
if not amount or not arguments[2] then
client:Notify("You need to enter a valid amount!")
return
end
local person = target:Nick()
if target == client then
person = "yourself"
end
target:ChatPrint("You awarded "..person.." with "..amount.." Karma.")
target:AddMoney(amount);
target:ChatPrint("You have been awarded with "..amount.." karma by "..client:Nick()..".")
else

client:Notify("You need to be a super admin!")
end
end);

pistachio.command:Create("resign", nil, "Resign your job if you aren't a civilian.", function(client, arguments)
	if (client:Team() != TEAM_CITIZEN) then
		client:SetTeam(TEAM_CITIZEN);
		client:SetPublicVar("job", "Unemployed");
		client:SetModel(client:GetPrivateVar("model") or "models/player/Group01/Female_01.mdl");
		client:StripWeapons();

		timer.Simple(0.5, function()
			hook.Call("PlayerLoadout", GAMEMODE, client);
		end);
	else
		client:Notify("You can't resign as a civilian!");
	end;
end);

pistachio.command:Create("demote", "<person> <reason>", "Demote a person from an official position.", function(client, arguments)
	if ( (client.nextDemote or 0) < CurTime() ) then
		if ( client:Team() != TEAM_MAYOR and !client:IsAdmin() ) then
			client:Notify("You are not the mayor!");

			return;
		end;

		local name = tostring( string.lower( arguments[1] ) );

		if (string.len(name) < 1) then
			client:Notify("You didn't specify enough text!");

			return;
		end;

		local target = pistachio:GetPlayerByName(name);

		if (type(target) == "table" and #target < 1) then
			client:Notify("That player could not be found!");

			return;
		elseif (type(target) == "table" and #target > 1) then
			client:Notify("Multiple people were found with that name!");

			return;
		end;

		table.remove(arguments, 1);

		local reason = table.concat(arguments, " ");

		if (string.len(reason) < 1) then
			client:Notify("You didn't specify a valid reason!");

			return;
		end;

		if ( IsValid(target) ) then
			if (target:Team() == TEAM_CITIZEN) then
				client:Notify("You cannot demote this person!");

				return;
			end;

			target:StripWeapons();
			target:SetTeam(TEAM_CITIZEN);
			target:SetModel(target:GetPrivateVar("model") or "models/player/Group01/Female_01.mdl");
			target:SetPublicVar("job", "Unemployed");
			target:Spawn();
			target.nextJob = CurTime() + 300;

			hook.Call("PlayerLoadout", GAMEMODE, target);

			for k, v in pairs( player.GetAll() ) do
				v:Notify(client:Name().." has demoted "..target:Name().." because: "..reason..".");
			end;

			if ( !client:IsAdmin() ) then
				client.nextDemote = CurTime() + 60;
			end;
		else
			client:Notify("The player could not be found!");
		end;
	else
		client:Notify("You cannot demote another person yet.");
	end;
end);

pistachio.command:Create("write", "<text>", "Writes a note onto a piece of paper.", function(client, arguments)
	local text = table.concat(arguments, " ");

	if ( !client:HasItem("paper") ) then
		client:Notify("You need paper to write on!");

		return;
	end;

	if (string.len(text) < 1) then
		client:Notify("You didn't specify enough text!");

		return;
	elseif (string.len(text) < 500) then
		text = string.sub(text, 1, 500);
	end;

	local trace = client:GetEyeTraceNoCursor();
	local position = trace.HitPos + Vector(0, 0, 8);

	if (client:GetPos():Distance(position) > 256) then
		client:Notify("You cannot write on paper that far away!");

		return;
	end;

	local paper = ents.Create("pistachio_note");
	paper:SetPos(position);
	paper:Spawn();
	paper:Activate();
	paper.text = text;
	paper.owner = client;

	paper:GiveAccess(client, true);
	
	client:TakeItem("paper");
end);

pistachio.command:Create("giveownership", "<name>", "Allow a player ownership if the thing you're looking at.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) ) then
		if (IsValid( entity:GetAccessOwner() ) and entity:GetAccessOwner() == client) then
			local text = tostring( table.concat(arguments, " ") );

			if (string.len(text) > 0) then
				local target = pistachio:GetPlayerByName(text);

				if ( type(target) != "table" and IsValid(target) ) then
					entity:GiveAccess(target);

					client:Notify("You've given "..target:Name().." access to this entity.");
				elseif (type(target) == "table" and #target > 1) then
					client:Notify("There was more than one person found with that name!");
				else
					client:Notify("A player couldn't be found!");
				end;
			else
				client:Notify("You didn't specify enough text!");
			end;
		else
			client:Notify("You don't own this entity!");
		end;
	else
		client:Notify("That isn't a valid entity!");
	end;
end);

pistachio.command:Create("pm", "<name> <text>", "Private message a player.", function(client, arguments)
	local name = tostring( arguments[1] );

	if (string.len(name) > 0) then
		local target = pistachio:GetPlayerByName(name);

		if ( type(target) != "table" and IsValid(target) ) then
			table.remove(arguments, 1);

			local text = table.concat(arguments, " ");

			client:ChatPrint("You > "..text);
			target:ChatPrint(client:Name().." > "..text);
		elseif (type(target) == "table" and #target > 1) then
			client:Notify("There was more than one person found with that name!");
		else
			client:Notify("A player couldn't be found!");
		end;
	else
		client:Notify("You didn't specify enough text!");
	end;
end);

pistachio.command:Create("takeownership", "<name>", "Disallow a player ownership if the thing you're looking at.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) ) then
		if (IsValid( entity:GetAccessOwner() ) and entity:GetAccessOwner() == client) then
			local text = tostring( table.concat(arguments, " ") );

			if (string.len(text) > 0) then
				local target = pistachio:GetPlayerByName(text);

				if ( type(target) != "table" and IsValid(target) ) then
					if ( entity:HasAccess(target) ) then
						entity:TakeAccess(target);

						client:Notify("You've take "..target:Name().."'s access to this entity.");
					else
						client:Notify(target:Name().." doesn't have access to this entity!");
					end;
				elseif (type(target) == "table" and #target > 1) then
					client:Notify("There was more than one person found with that name!");
				else
					client:Notify("A player couldn't be found!");
				end;
			else
				client:Notify("You didn't specify enough text!");
			end;
		else
			client:Notify("You don't own this entity!");
		end;
	else
		client:Notify("That isn't a valid entity!");
	end;
end);

pistachio.command:Create("warrant", "<name> <reason>", "Allow a player ownership if the thing you're looking at.", function(client, arguments)
	if (client:Team() != TEAM_MAYOR) then
		client:Notify("You need to be a mayor to warrant!");

		return;
	end;

	local name = tostring( arguments[1] );
	local target = pistachio:GetPlayerByName(name);

	if ( (client.nextWarrant or 0) < CurTime() ) then
		if ( type(target) != "table" and IsValid(target) ) then
			if (target:Team() != TEAM_CITIZEN) then
				client:Notify("You can only warrant citizens.");

				return;
			end;

			table.remove(arguments, 1);

			local reason = table.concat(arguments, " ");

			if (string.len(reason) < 1) then
				client:Notify("You need to specify a reason!");

				return;
			end;

			for k, v in pairs( player.GetAll() ) do
				v:Notify("Mayor "..client:Name().." has warranted "..target:Name().."! ("..reason..")");
			end;

			target:SetPublicVar("warranted", true);

			timer.Simple(300, function()
				if ( IsValid(target) ) then
					for k, v in pairs( player.GetAll() ) do
						v:Notify(target:Name().." is no longer warranted.");
					end;

					target:SetPublicVar("warranted", false);
				end;
			end);
		elseif (type(target) == "table" and #target > 1) then
			client:Notify("There was more than one person found with that name!");
		else
			client:Notify("A player couldn't be found!");
		end;

		client.nextWarrant = CurTime() + 120;
	else
		client:Notify("You cannot issue another warrant yet!");
	end;
end);


pistachio.command:Create("settitle", "<title>", "Sets the title of something you own.", function(client, arguments)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( IsValid(entity) ) then
		if (IsValid( entity:GetAccessOwner() ) and entity:GetAccessOwner() == client) then
			local text = tostring( table.concat(arguments, " ") );

			if (string.len(text) > 0) then
				entity:SetPublicVar("title", text);
				client:Notify("You've changed this entity's title to: "..text);
			else
				client:Notify("You didn't specify enough text!");
			end;
		else
			client:Notify("You don't have access to this entity!");
		end;
	else
		client:Notify("That isn't a valid entity!");
	end;
end);

pistachio.command:Create("dropmoney", "<amount>", "Drop a certain amount of money on the floor.", function(client, arguments)
	local amount = tonumber( arguments[1] );
	local money = client:GetPrivateVar("money") or 0;

	if (amount and amount > 0) then
		amount = math.floor(amount);

		if (amount < 5) then
			client:Notify("You need to drop at least $5 dollars!");

			return;
		end;

		if (money - amount >= 0) then
			client:SetPrivateVar("money", money - amount);
			
			local trace = client:GetEyeTraceNoCursor();
			local position = trace.HitPos + Vector(0, 0, 16);

			if (client:GetPos():Distance(position) > 256) then
				client:Notify("You can't drop money that far away!");

				return;
			end;

			local money = ents.Create("pistachio_money");
			money:SetPos(position);
			money:SetSolid(SOLID_VPHYSICS);
			money:SetMoveType(MOVETYPE_VPHYSICS);
			money:PhysicsInit(SOLID_VPHYSICS);
			money:SetUseType(SIMPLE_USE);
			money:Spawn();
			money:SetMoney(amount);
			money:GiveAccess(client);

			client:DeleteOnRemove(money);
			client:Notify("You've dropped $"..amount.." dollars.");

			hook.Call("PlayerSaveData", GAMEMODE, client, false, true);
		else
			client:Notify("You don't have that much money!");
		end;
	else
		client:Notify("That is not a valid amount!");
	end;
end);

pistachio.command:Create("holster", nil, "Holster your current weapon.", function(client, arguments)
	local weapon = client:GetActiveWeapon();

	if ( IsValid(weapon) ) then
		local class = string.lower( weapon:GetClass() );
		local itemTable = pistachio.item:Get(class);

		if (itemTable) then
			client:EmitSound("npc/metropolice/gear"..math.random(1, 6)..".wav");
			client:StripWeapon(class);
			client:AddItem(class);

			hook.Call("PlayerSaveData", GAMEMODE, client, false, true);
		else
			client:Notify("You cannot holster that weapon!");
		end;
	end;
end);

pistachio.command:Create("pickup", nil, "Pickup a vehicle you're in.", function(client, arguments)
	local vehicle = client:GetVehicle();

	if (IsValid(vehicle) and vehicle:IsAccessed() and vehicle:GetAccessOwner() == client) then
		client:Notify("Wait five seconds before your vehicle is picked up.");

		local oldPos = vehicle:GetPos();

		timer.Simple(5, function()
			local vehicle = client:GetVehicle();

			if ( IsValid(vehicle) and IsValid(client) ) then
				if (vehicle:GetPos():Distance(oldPos) <= 5) then
					vehicle:Remove();

					client:Notify("You've picked up your vehicle.");
				else
					client:Notify("You must stay still while picking your vehicle up!");

					return;
				end;
			end;
		end);
	else
		client:Notify("You cannot pick up this vehicle!");
	end;
end);
