local _R = debug.getregistry();
local playerMeta = _R.Player;

if (SERVER) then
	util.AddNetworkString("ps_Notify");
	util.AddNetworkString("ps_NotifyAdmin");

	function playerMeta:Notify(...)
		net.Start("ps_Notify");
			net.WriteTable( {...} );
		net.Send(self);
	end;

	function playerMeta:NotifyAdmin(text)
		net.Start("ps_NotifyAdmin");
			net.WriteString(text);
		net.Send(self);
	end;

	function playerMeta:RemoveOwnedEntities()
		for k, v in pairs( ents.GetAll() ) do
			if ( v:GetAccessOwner() == self and !v:IsDoor() ) then
				SafeRemoveEntity(v);
			end;
		end;
	end;

	function playerMeta:AddMoney(amount)
		local money = self:GetPrivateVar("money") or 0;

		self:SetPrivateVar("money", money + amount);
	end;

	function playerMeta:GetMoney()
		return self:GetPrivateVar("money") or 0;
	end;
	
	function playerMeta:TakeMoney(amount)
		self:AddMoney(-amount);
	end;

	function playerMeta:AddKarma(amount)
		if (!amount) then
			amount = 1;
		end;

		local karma = self:GetPrivateVar("karma") or 0;

		self:SetPrivateVar("karma", karma + amount);
	end;

	function playerMeta:TakeKarma(amount)
		if (!amount) then
			amount = 1;
		end;

		self:AddKarma(-amount);
	end;

	function playerMeta:SetArrested(arrested)
		self:SetPublicVar("arrested", arrested);

		if (arrested) then
			self.runSpeed = self:GetRunSpeed();

			self:SetRunSpeed(100);

			local position = pistachio:GetJailPosition();

			if (position) then
				self:SetPos(position);
			end;

			self:SetPublicVar("warranted", false);
			self:SetTeam(TEAM_ARRESTED);
			self.arrestTime = CurTime() + 300;

			local karma = self:GetPrivateVar("karma") or 0;
			local addition = (0 - karma);

			self.arrestTime = math.max(self.arrestTime + (addition * 5), CurTime() + 90);

			timer.Create("ps_Arrest"..self:EntIndex(), math.ceil( self.arrestTime - CurTime() ) - 1, 1, function()
				if ( IsValid(self) ) then
					self:SetTeam(TEAM_CITIZEN);
					self:SetArrested(false);
					self:Spawn();

					if (self.loadout) then
						self:StripWeapons();

						for k, v in pairs(self.loadout) do
							self:Give(v);
						end;
					end;
				end;
			end);

			net.Start("ps_ArrestTime");
				net.WriteInt(self.arrestTime, 32);
			net.Send(self);
		else
			self:SetRunSpeed(self.runSpeed or 250);
			self:SetTeam(TEAM_CITIZEN);
		end;
	end;
else
	net.Receive("ps_Notify", function(length)
		local content = unpack( net.ReadTable() );

		LocalPlayer():Notify(content);
	end);

	net.Receive("ps_NotifyAdmin", function(length)
		local text = net.ReadString();

		MsgC(Color(255, 125, 50), "[ADMIN] "..text.."\n");
	end);

	function playerMeta:Notify(...)
		chat.AddIconText("icon16/error.png", Color(225, 175, 85), "[Pistachio] ", color_white, ...);

		LocalPlayer():EmitSound("buttons/button24.wav");
	end;
end;

function playerMeta:IsDeveloper()
	return self:SteamID() == "STEAM_0:1:1486564";
end;

function playerMeta:IsArrested()
	return self:GetPublicVar("arrested") or false;
end;