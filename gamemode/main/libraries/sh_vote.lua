if (!pistachio.command) then
	include("sh_commands.lua");
end;

pistachio.vote = pistachio.vote or {};
pistachio.vote.stored = pistachio.vote.stored or {};
pistachio.vote.current = pistachio.vote.current or "";
pistachio.vote.player = pistachio.vote.player or NULL;

local nextVote = 0;

pistachio.vote.yes = pistachio.vote.yes or 0;
pistachio.vote.no = pistachio.vote.no or 0;

function pistachio.vote:Register(voteTable)
	self.stored[voteTable.uniqueID] = voteTable;
end;

function pistachio.vote:Get(key)
	return self.stored[key];
end;

if (SERVER) then
	function pistachio.vote:HandlePlayerVote(client, isYes)
		if ( !client.voted and timer.Exists("ps_Vote") ) then
			if (client == self.player) then
				client:Notify("You are not allowed to vote for yourself!");

				return;
			end;

			if (isYes) then
				self.yes = self.yes + 1;

				if (client:GetInfoNum("ps_showmyvote", 1) > 0) then
					for k, v in pairs( player.GetAll() ) do
						v:Notify(client:Name().." has voted yes.");
					end;
				else
					client:Notify("You have silently voted yes.");
				end;
			else
				self.no = self.no + 1;

				if (client:GetInfoNum("ps_showmyvote", 1) > 0) then
					for k, v in pairs( player.GetAll() ) do
						v:Notify(client:Name().." has voted no.");
					end;
				else
					client:Notify("You have silently voted no.");
				end;
			end;

			client.voted = true;
		else
			client:Notify("You cannot vote right now!");
		end;
	end;

	function pistachio.vote:StartVote(key, client)
		local voteTable = self:Get(key);

		if (voteTable) then
			local canVote = true;

			if (voteTable.ShouldPlayerStartVote) then
				canVote = voteTable:ShouldPlayerStartVote(client);
			end;

			if ( canVote and type(canVote) != "string" and (client.nextVote or 0) < CurTime() and !timer.Exists("ps_Vote") ) then
				for k, v in pairs( player.GetAll() ) do
					if ( IsValid(v) ) then
						v.voted = false;
					end;
				end;
				
				self.player = client;
				self.current = key;

				local message = voteTable:GetStartText(client);

				for k, v in pairs( player.GetAll() ) do
					v:Notify(message);
					v:Notify("Type /voteyes or /voteno to choose.");
				end;

				timer.Create("ps_Vote", 60, 1, function()
					if ( IsValid(client) ) then
						self:FinishVote(voteTable, client);
					end;
				end);
			else
				if (type(canVote) == "string") then
					client:Notify(canVote);
				else
					client:Notify("A vote can not be started right now.");
				end;
			end;
		end;
	end;

	function pistachio.vote:FinishVote(voteTable, client)
		if (self.yes > self.no) then
			voteTable:OnSuccess(client);
		else
			if (voteTable.OnFail) then
				voteTable:OnFail(client);
			else
				for k, v in pairs( player.GetAll() ) do
					v:Notify("The vote has failed! ("..self.yes.." > "..self.no..")");
				end;
			end;
		end;

		self.player = nil;
		self.current = nil;
		self.yes = 0;
		self.no = 0;

		timer.Destroy("ps_Vote");

		for k, v in pairs( player.GetAll() ) do
			v.voted = false;
		end;

		client.nextVote = CurTime() + 120;
	end;
end;

pistachio.command:Create("voteyes", nil, "Votes yes to current active vote.", function(client, arguments)
	pistachio.vote:HandlePlayerVote(client, true);
end);

pistachio.command:Create("voteno", nil, "Votes no to the current active vote.", function(client, arguments)
	pistachio.vote:HandlePlayerVote(client);
end);