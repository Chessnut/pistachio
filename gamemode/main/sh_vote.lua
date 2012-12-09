local VOTE = {};
VOTE.uniqueID = "cop";

function VOTE:ShouldPlayerStartVote(client)
	if ( #team.GetPlayers(TEAM_POLICE) > math.floor(#player.GetAll() * 0.25) ) then
		return "There are enough police officers!";
	end;

	local karma = client:GetPrivateVar("karma") or 0;

	if ( client:IsArrested() or client:GetPublicVar("tied") ) then
		return "You cannot change jobs when tied!";
	end;

	if (karma < 1) then
		return "You need at least one karma point!";
	end;

	if (client:Team() != TEAM_CITIZEN) then
		return "You must be a citizen to become a police officer!";
	end;

	return true;
end;

function VOTE:GetStartText(client)
	return client:Name().." has started a vote to become a police officer.";
end;

function VOTE:OnSuccess(client)
	for k, v in pairs( player.GetAll() ) do
		v:Notify(client:Name().." has been made a police officer!");
	end;

	client:SetPublicVar("warranted", false);
	client:SetTeam(TEAM_POLICE);
	client:SetPublicVar("job", "Police Officer");

	timer.Simple(0.5, function()
		hook.Call("PlayerLoadout", GAMEMODE, client);
	end);
end;

pistachio.vote:Register(VOTE);

pistachio.command:Create("votecop", nil, "Start a vote to become a police officer.", function(client, arguments)
	pistachio.vote:StartVote("cop", client);
end);

local VOTE = {};
VOTE.uniqueID = "mayor";

function VOTE:ShouldPlayerStartVote(client)
	if (#team.GetPlayers(TEAM_MAYOR) == 1) then
		return "There can only be one mayor!";
	end;

	local karma = client:GetPrivateVar("karma") or 3;

	if (karma < 3) then
		return "You need at least three karma points!";
	end;


	if ( client:IsArrested() or client:GetPublicVar("tied") ) then
		return "You cannot change jobs when tied!";
	end;

	if (client:Team() != TEAM_CITIZEN) then
		return "You must be a citizen to become a mayor!";
	end;

	return true;
end;

function VOTE:GetStartText(client)
	return client:Name().." has started a vote to become a mayor.";
end;

function VOTE:OnSuccess(client)
	for k, v in pairs( player.GetAll() ) do
		v:Notify(client:Name().." is the new mayor!");
	end;

	client:SetTeam(TEAM_MAYOR);
	client:SetPublicVar("job", "Mayor");

	timer.Simple(0.5, function()
		hook.Call("PlayerLoadout", GAMEMODE, client);
	end);
end;

pistachio.vote:Register(VOTE);

pistachio.command:Create("votemayor", nil, "Start a vote to become a mayor.", function(client, arguments)
	pistachio.vote:StartVote("mayor", client);
end);