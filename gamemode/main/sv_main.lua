AddCSLuaFile("sh_main.lua");
AddCSLuaFile("sh_commands.lua");
AddCSLuaFile("sh_vote.lua");
AddCSLuaFile("cl_skin.lua");

include("sh_main.lua");
include("cl_main.lua");
include("cl_skin.lua");

util.AddNetworkString("ps_MenuPanel");
util.AddNetworkString("ps_Progress");
util.AddNetworkString("ps_ArrestTime");
util.AddNetworkString("ps_DeathTime");
util.AddNetworkString("ps_ChangeModel");
util.AddNetworkString("ps_PlayerModel");
util.AddNetworkString("ps_Ownership");
util.AddNetworkString("ps_PlayerGetData");
util.AddNetworkString("ps_OrderItem");
util.AddNetworkString("ps_FinishLoading");
util.AddNetworkString("ps_TotalVars");
util.AddNetworkString("ps_SelectShirtColor");
util.AddNetworkString("ps_ChangeShirt");
util.AddNetworkString("ps_EditLaw");
util.AddNetworkString("ps_UpdateLaw");

pistachio.lastTen = pistachio.lastTen or {};

pistachio.pay = {};

pistachio.pay["unemployed"] = 0;
pistachio.pay[TEAM_CITIZEN] = 50;
pistachio.pay[TEAM_POLICE] = 100;
pistachio.pay[TEAM_MAYOR] = 150;

function GM:AllowPlayerPickup(client, entity)
	return false;
end;

function GM:EntityRemoved(entity)
	self.BaseClass:EntityRemoved(entity);

	if (entity.publicVars) then
		net.Start("ps_NetworkData");
			net.WriteUInt(entity:EntIndex(), 16);
			net.WriteTable( {} );
		net.Broadcast();
	end;

	if ( IsValid(entity) and string.find(entity:GetClass(), "prop_*") and !entity:IsDoor() ) then
		local owner = entity:GetAccessOwner();

		if (IsValid(owner) and entity.spawnCost and entity.spawnCost > 0) then
			local money = math.ceil(entity.spawnCost / 2);

			owner:AddMoney(money);
		end;
	end;
end;

function GM:CanExitVehicle(vehicle, client)
	local speed = vehicle:GetVelocity():Length2D();

	return (speed < 5) and !vehicle.locked;
end;

function GM:CanPlayerSuicide(client)
	return cvars.Bool("ps_allowsuicide", false);
end;

function GM:PlayerSay(client, message, public)
	local data = pistachio.command:PlayerSay(client, message, public);

	if (data and data == "") then
		return "";
	end;

	local class, prefix = pistachio.chatBox:GetClassByPrefix(message);

	if ( !client:Alive() ) then
		client:Notify("You cannot speak when dead!");

		return "";
	end;

	if (class) then
		if ( class.canTalk(client) ) then
			net.Start("ps_ChatText");
				net.WriteUInt(client:EntIndex(), 8);
				net.WriteString(message);
			net.Broadcast();

			if (class.Callback) then
				class.Callback(client, message);
			end;
		
			MsgN(client:Name()..": "..message);
		end;

		return "";
	end;

	return message;
end;

function GM:PlayerLoadData(client)
	client:RestoreVar("money", NET_PRIVATE);
	client:RestoreVar("karma", NET_PRIVATE);
	client:RestoreVar("title", NET_PUBLIC);
	client:RestoreVar("model", NET_PRIVATE);
	client:RestoreVar("hat", NET_PRIVATE);
	client:RestoreVar("particle", NET_PUBLIC);
	client:RestoreVar("color", NET_PRIVATE);
	client:RestoreVar("bank", NET_PRIVATE);
	client:RestoreInventory();
	client:RestoreMailBox();

	for k, v in ipairs(pistachio.laws) do
		net.Start("ps_UpdateLaw");
			net.WriteUInt(k, 8);
			net.WriteString(v);
		net.Send(client);
	end;

	local files = file.Find("*", "cstrike");

	if (#files == 0) then
		client:ChatPrint("Server is missing Counter-Strike content!");
	end;
end;

function GM:PlayerSaveData(client, final, stopMessage)
	if (IsValid(client) and client.ps_Loaded) then
		client:PersistVar("money", NET_PRIVATE);
		client:PersistVar("title", NET_PUBLIC);
		client:PersistVar("karma", NET_PRIVATE);
		client:PersistVar("model", NET_PRIVATE);
		client:PersistVar("hat", NET_PRIVATE);
		client:PersistVar("particle", NET_PUBLIC);
		client:PersistVar("color", NET_PRIVATE);
		client:PersistVar("bank", NET_PRIVATE);
		client:SaveInventory();
		client:SaveMailBox();

		if (!final) then
			client:SyncInventory();

			if (!stopMessage) then
				client:Notify("Your data has been saved.");
			end;
		end;
	end;
end;

function GM:PlayerDeathSound()
	return true;
end;

function GM:ShowHelp(client)
	if (!client.gotPrices) then
		net.Start("ps_StockData");
			net.WriteTable(pistachio.stocks);
		net.Send(client);

		pistachio.item:SendPrices(client);

		client.gotPrices = true;
	end;

	net.Start("ps_MenuPanel");
	net.Send(client);
end;

function GM:ShowTeam(client)
	local trace = client:GetEyeTraceNoCursor();
	local entity = trace.Entity;

	if ( client:IsArrested() or client:GetPublicVar("tied") ) then
		client:Notify("You cannot interact with this entity when tied!");

		return;
	end;

	if ( IsValid(entity) ) then
		if ( entity:IsOwnable() ) then
			net.Start("ps_Ownership");
				net.WriteEntity(entity);
			net.Send(client);
		else
			local owner = entity:GetAccessOwner();

			if (!entity:IsVehicle() and IsValid(owner) and owner == client) then
				entity:RemoveAccess();

				client:AddMoney(25);
				client:Notify("You have sold this entity for $25 dollars.");
			else
				client:Notify("This entity cannot be owned!");
			end;
		end;
	else
		client:Notify("You aren't looking at a valid entity!");
	end;
end;

function GM:PlayerLoadout(client)
	if (!client.privateVars) then
		return;
	end;
	
	local wait = 0.5;

	if (client:Team() == 1001) then
		wait = 5 + (client:Ping() / 100);
	end;

	client:SetRenderMode(RENDERMODE_TRANSALPHA);
	client:SetColor( Color(255, 255, 255, 50) );
	client:GodEnable();
	client:Freeze(true);

	timer.Simple(wait, function()
		if ( IsValid(client) ) then
			local correctModel = false;
			local modelTable = pistachio.playerModels[ client:Team() ];

			if (!modelTable) then
				modelTable = pistachio.playerModels[TEAM_CITIZEN];
			end;

			for k, v in pairs(modelTable) do
				if ( string.lower(v) == string.lower( client:GetPrivateVar("model") or client:GetModel() ) ) then
					correctModel = true;

					break;
				end;
			end;

			if (correctModel) then
				client:SetModel( client:GetPrivateVar("model") or table.Random( pistachio.playerModels[ client:Team() ] ) );
			else
				net.Start("ps_ChangeModel");
				net.Send(client);
			end;

			if (client:Team() == TEAM_POLICE) then
				client:Give("pistachio_baton");
			end;

			client:Give("pistachio_hands");
			client:Give("weapon_physcannon");

			local givePhysgun = cvars.Bool("ps_givephysgun", true);
			local giveToolgun = cvars.Bool("ps_givetool", true);

			if (givePhysgun) then
				client:Give("weapon_physgun");
			end;

			if (giveToolgun) then
				client:Give("gmod_tool");
			end;

			local walkSpeed = cvars.Int("ps_walkspeed", 125);
			local runSpeed = cvars.Int("ps_runspeed", 250);

			client:SetWalkSpeed(walkSpeed);
			client:SetRunSpeed(runSpeed);

			local hat = client:GetPrivateVar("hat") or "";

			if (hat and hat != "") then
				local itemTable = pistachio.item:Get(hat);

				if ( itemTable and client:HasItem(hat) ) then
					pistachio.hats:Give(client, hat);
				end;
			end;

			local weight = client:GetItemWeight() * 2;

			client:SetWalkSpeed( math.Clamp(walkSpeed - weight, 50, walkSpeed) );
			client:SetRunSpeed( math.Clamp(runSpeed - weight, 75, runSpeed) );

			local colorString = client:GetPrivateVar("color");

			if (colorString) then
				local explodedString = string.Explode(",", colorString);
				local r, g, b = explodedString[1], explodedString[2], explodedString[3];

				if (r and g and b) then
					local red, green, blue = tonumber(r), tonumber(g), tonumber(b);

					if (red and green and blue) then
						client:SetPlayerColor( Vector(red / 255, green / 255, blue / 255) );
					end;
				else
					client:SetPlayerColor( Vector(1, 1, 1) );
				end;
			else
				client:SetPlayerColor( Vector(1, 1, 1) );
			end;

			client:SetColor( Color(255, 255, 255, 255) );
			client:SetPublicVar("tied", false);
			client:SetPrivateVar("drunk", 0);
			client:SetPrivateVar("stamina", 100);
			client:GodDisable();
			client:Freeze(false);
			client:SetNoCollideWithTeammates(false);
			client:SetAvoidPlayers(false);
		end;
	end);
end;

function GM:PlayerRequestTeam(client, teamID)
	return;
end;

function GM:EntityTakeDamage(entity, damageInfo)
	self.BaseClass:EntityTakeDamage(entity, damageInfo);

	local attacker = damageInfo:GetAttacker();
	local amount = damageInfo:GetDamage();

	if (attacker == game.GetWorld() and amount == 200) then
		damageInfo:ScaleDamage(0);
	end;

	if ( IsValid(attacker) ) then
		if ( !attacker:IsPlayer() ) then
			if ( attacker:IsVehicle() ) then
				if ( IsValid( attacker:GetDriver() ) ) then
					attacker = attacker:GetDriver();
				else
					return;
				end;
			end;
		end;

		if ( attacker:IsPlayer() ) then
			local karma = tonumber(attacker:GetPrivateVar("karma") or 0);

			if (karma > 5) then
				karma = 5;
			end;

			local scale = 1 + (karma * 0.1);

			damageInfo:ScaleDamage(scale);
		end;
	end;

	if (entity:IsVehicle() and !entity.isSeat) then
		if (!entity.damage) then
			entity.damage = 75;
		end;

		entity.damage = entity.damage - (amount * 1000);

		if (entity.damage < 1) then
			entity:Fire("turnoff");

			if ( IsValid( entity:GetDriver() ) ) then
				entity:GetDriver():ExitVehicle();
			end;

			timer.Simple(1, function()
				if ( IsValid(entity) ) then
					local num = math.Clamp(255 + entity.damage, 25, 255);

					entity:Ignite(180, 128);
					entity:SetColor( Color(num, num, num, 255) );

					timer.Simple(10, function()
						if (IsValid(entity) and !entity.exploded) then
							entity.exploded = true;

							local explosion = ents.Create("env_explosion");
							explosion:SetOwner(entity.spawner or entity);
							explosion:SetPos( entity:GetPos() );
							explosion:Spawn();
							explosion:SetKeyValue("iMagnitude", "150");
							explosion:Fire("Explode");
							explosion:EmitSound("ambient/explosions/explode_"..math.random(1, 9)..".wav");

							local physicsObject = entity:GetPhysicsObject();

							if ( IsValid(physicsObject) ) then
								local mass = physicsObject:GetMass();

								physicsObject:ApplyForceCenter( Vector(math.random(mass * -128, mass * 128), math.random(mass * -128, mass * 128), mass * 768) );
							end;

							timer.Simple(120, function()
								if ( IsValid(entity) ) then
									entity:Remove();
								end;
							end);
						end;
					end);
				end;
			end);
		end;
	end;
end;

function GM:PlayerInitialSpawn(client)
	pistachio.chatBox:Message("Player "..client:Name().." has connected to the server.");
end;

function GM:StaminaTick(client)
	local velocity = client:GetVelocity():Length2D();
	local health = client:Health();

	if ( client:IsArrested() or client:GetPublicVar("tied") ) then
		client:SetRunSpeed(100);

		return;
	end;

	if ( (client.nextStamina or 0) < CurTime() ) then
		local stamina = client:GetPrivateVar("stamina") or 100;

		local value;
		local bonus = 0;
		local bonusTime = 0;

		if (client:Team() == TEAM_POLICE) then
			bonus = 1;
			bonusTime = 0.1;
		end;

		if ( client:KeyDown(IN_SPEED) and velocity >= (client:GetRunSpeed() - 5) ) then
			value = math.Clamp(stamina - 1, 0, 100);
			client:SetPrivateVar("stamina", value);

			client.nextStamina = CurTime() + (0.1 + bonusTime);
		else
			if ( client:KeyDown(IN_DUCK) ) then
				value = math.Clamp(stamina + 2 + bonus, 0, 100);
			else
				value = math.Clamp(stamina + 1 + bonus, 0, 100);
			end;

			client:SetPrivateVar("stamina", value);

			if (velocity < 5) then
				client.nextStamina = CurTime() + (0.5 + bonusTime) + ( (100 - health) / 100 );
			else
				client.nextStamina = CurTime() + (1.5 + bonusTime) + ( (100 - health) / 100 );
			end;
		end;

		local walkSpeed = client:GetWalkSpeed();

		if (stamina < 1) then
			client:SetRunSpeed(walkSpeed);
		else
			local weight = client:GetItemWeight() * 2;

			client:SetWalkSpeed( math.Clamp(125 - weight, 50, 125) );
			client:SetRunSpeed( math.Clamp(250 - weight, 75, 250) );
		end;
	end;
end;

function GM:FlashlightTick(client)
	if ( !client:GetPrivateVar("flashlight") ) then
		client:SetPrivateVar("flashlight", 100);
	end;

	if ( (client.nextFlashlight or 0) < CurTime() ) then
		local amount = client:GetPrivateVar("flashlight") or 100;

		if ( client:FlashlightIsOn() ) then
			local value = math.Clamp(amount - 1, 0, 100);

			client:SetPrivateVar("flashlight", value);
			client.nextFlashlight = CurTime() + 0.5;
		else
			local value = math.Clamp(amount + 1, 0, 100);

			client:SetPrivateVar("flashlight", value);
			client.nextFlashlight = CurTime() + 0.35;
		end;

		if (client:GetPrivateVar("flashlight") < 1) then
			client:Flashlight(false);
		end;

		client:AllowFlashlight(client:GetPrivateVar("flashlight") > 0);
	end;
end;

function GM:KarmaTick(client)
	if (!client.nextKarma) then
		client.nextKarma = CurTime() + 720;
	end;

	if ( (client.nextKarma or 0) < CurTime() ) then
		local karma = client:GetPrivateVar("karma") or 0;

		client:SetPrivateVar("karma", karma + 1);
		client.nextKarma = CurTime() + 720;
	end;
end;

function GM:ShouldPlayerGetPaid(client)
	if (client:Team() == TEAM_CRIMINAL) then
		return "Your paycheck has been skipped for being a criminal.";
	end;
end;

function GM:PayCheckTick(client)
	local calculatedTime = 300;
	local karma = client:GetPrivateVar("karma") or 0;

	calculatedTime = CurTime() + math.max(300 - (karma * 5), 180);

	if (!client.nextPayment) then
		client.nextPayment = calculatedTime;
	end;

	if ( (client.nextPayment or 0) < CurTime() ) then
		local shouldPay, fault = hook.Call("ShouldPlayerGetPaid", GAMEMODE, client);

		if (shouldPay != false) then
			local money = client:GetPrivateVar("money") or 0;
			local job = client:GetPrivateVar("job") or "";
			local pay = 0;

			if ( pistachio.pay[job] ) then
				pay = pistachio.pay[job];
			elseif ( pistachio.pay[ client:Team() ] ) then
				pay = pistachio.pay[ client:Team() ];
			end;

			if ( client:IsArrested() ) then
				pay = 0;
			end;

			if (pay > 0) then
				local amount = math.floor(pay / 50);
				local isDonator = false;

				if ( evolve and client:EV_IsRank("donator") ) then
					isDonator = true;
				elseif ( client:IsUserGroup("donator") ) then
					isDonator = true;
				end;

				if ( isDonator or client:IsAdmin() ) then
					amount = amount + 1;
					pay = pay + 50;
				end;

				client:AddMailBoxItem("paycheck", amount, 1);
				client:Notify("You've received a paycheck of $"..pay.." dollars!");
			end;
		else
			client:Notify(fault or "Your paycheck has been skipped.");
		end;

		client.nextPayment = calculatedTime;
	end;
end;

function GM:HandleSaveData(client)
	if (!client.nextSaveData) then
		client.nextSaveData = CurTime() + 300;
	end;

	if ( (client.nextSaveData or 0) < CurTime() ) then
		hook.Call("PlayerSaveData", GAMEMODE, client, false, true);

		client.nextSaveData = CurTime() + 300;
	end;
end;

function GM:PlayerTick(client)
	self:PayCheckTick(client);
	self:KarmaTick(client);
	self:StaminaTick(client);
	self:FlashlightTick(client);
	self:HandleSaveData(client);
end;

function GM:PlayerSpawnedProp(client, model, entity)
	local mass = entity:GetPhysicsObject():GetMass();

	if (client:IsAdmin() or mass < 480) then
		local cost = 0;
		local karma = client:GetPrivateVar("karma") or 0;
		
		if (karma < 1) then
			cost = math.ceil(mass * 0.25);

			if (tonumber(client:GetPrivateVar("money")) >= cost) then
				local value = client:GetPrivateVar("money") - cost;

				client:SetPrivateVar("money", value);
				client:Notify("You've spent $"..cost.." dollars on this prop.");
			else
				entity:Remove();
				client:Notify("You need $"..( cost - client:GetPrivateVar("money") ).." more dollars!");

				return;
			end;
		end;

		for k, v in pairs( player.GetAll() ) do
			if ( v:IsAdmin() ) then
				v:NotifyAdmin("Player "..client:Name().." has spawned a prop ("..model..")");
			end;
		end;

		entity.spawnCost = cost;
		entity:GiveAccess(client, true);
	else
		entity:Remove();
		client:Notify("This entity is too big!");
	end;
end;

local blacklist = {
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_phx/ball.mdl",
	"models/props_phx/cannonball.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/ww2bomb.mdl",
	"models/props_phx/misc/flakshell_big.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propane_tank001a.mdl"
};

function GM:PhysgunPickup(client, entity, gravityGun)
	if ( IsValid(entity) ) then
		if ( client:IsAdmin() ) then
			return true;
		end;
		
		if ( !entity:IsAccessed() or entity:HasAccess(client) ) then
			if (!entity:IsPlayer() and !entity:IsDoor() and !entity:IsVehicle() and entity:GetClass() != "pistachio_mailbox") then
				if (!gravityGun) then
					local physicsObject = entity:GetPhysicsObject();

					if ( IsValid(physicsObject) ) then
						if (physicsObject:GetMass() > 480) then
							return false;
						end;
					else
						return false;
					end;

					if (client:GetPos():Distance( entity:GetPos() ) > 128) then
						return false;
					end;
				end;

				if (!gravityGun) then
					entity:SetOwner(client);
				end;

				return true;
			end;
		end;
	end;

	return false;
end;

function GM:GravGunPickupAllowed(client, entity)
	return self:PhysgunPickup(client, entity, true);
end;

function GM:PhysgunDrop(client, entity)
	self.BaseClass:PhysgunDrop(client, entity);

	entity:SetVelocity( Vector(0, 0, 0) );
	entity:SetPos( entity:GetPos() );
	entity:SetOwner();
end;

function GM:PlayerSpawnedVehicle(client, vehicle)
	if ( client:IsAdmin() ) then
		self.BaseClass:PlayerSpawnedVehicle(client, vehicle);

		for k, v in pairs( player.GetAll() ) do
			if ( v:IsAdmin() ) then
				v:NotifyAdmin("Player "..client:Name().." has spawned a "..vehicle:GetClass()..".");
			end;
		end;

		vehicle:Lock();
		vehicle.locked = true;
	else
		vehicle:Remove();
	end;
end;

function GM:PlayerSpawnVehicle(client, model, name, vehicleTable)
	return client:IsAdmin();
end;

function GM:PlayerSpawnRagdoll(client)
	return client:IsAdmin();
end;

function GM:InitPostEntity()
	if (game.GetMap() == "rp_downtown_v2") then
		local positions = {
			Vector(1632.000000, -1535.500000, -114.000000),
			Vector(1632.000000, -1535.500000, -120.500000),
		};

		for k, v in pairs(positions) do
			for k2, v2 in pairs( ents.FindInSphere(v, 5) ) do
				SafeRemoveEntity(v2);
			end;
		end;
	end;

	for k, v in pairs( ents.FindByClass("prop_physics") ) do
		SafeRemoveEntity(v);
	end;

	for k, v in pairs( ents.FindByClass("prop_physics_*") ) do
		SafeRemoveEntity(v);
	end;
end;

local toolBlacklist = {
	"dynamite",
	"hoverball",
	"lamp",
	"light",
	"thruster",
	"turret",
	"rtcamera",
	"spawner",
	"slider",
	"hydraulic",
	"rope",
	"winch",
	"elastic",
	"muscle",
	"motor"
};

local duplicatorBlacklist = {
	"pistachio_mailbox",
	"pistachio_money",
	"pistachio_create",
	"pistachio_item",
	"pistachio_hat",
	"pistachio_note",
	"pistachio_printer",
	"pistachio_atm"
};

function GM:CanTool(client, trace, tool)
	self.BaseClass:CanTool(client, trace, tool);

	local entity = trace.Entity;

	if ( client:IsAdmin() ) then
		for k, v in pairs( player.GetAll() ) do
			if ( v:IsAdmin() ) then
				v:NotifyAdmin(client:Name().." has used "..tool..".");
			end;
		end;
		
		return true;
	end;

	if ( table.HasValue(toolBlacklist, tool) ) then
		return false;
	end;

	if (tool == "duplicator") then
		for k, v in pairs( player.GetAll() ) do
			if ( v:IsAdmin() ) then
				v:NotifyAdmin(client:Name().." has used "..tool..".");
			end;
		end;

		return client:IsAdmin();
	end;

	if ( entity:IsWorld() ) then
		for k, v in pairs( player.GetAll() ) do
			if ( v:IsAdmin() ) then
				v:NotifyAdmin(client:Name().." has used "..tool..".");
			end;
		end;

		return true;
	end;

	if ( IsValid(entity) ) then
		if ( !entity:IsAccessed() or !entity:HasAccess(client) ) then
			return false;
		end;
	end;

	for k, v in pairs( player.GetAll() ) do
		if ( v:IsAdmin() ) then
			v:NotifyAdmin(client:Name().." has used "..tool..".");
		end;
	end;

	return true;
end;

function GM:PlayerSpawnProp(client, model)
	self.BaseClass:PlayerSpawnProp(client, model);

	for k, v in pairs(blacklist) do
		if ( string.find(model, v) and !client:IsAdmin() ) then
			client:Notify("That prop is blacklisted!");

			return false;
		end;
	end;

	if ( (client.nextSpawnProp or 0) > CurTime() ) then
		return false;
	end;

	client.nextSpawnProp = CurTime() + 1;

	return true;
end;

function GM:PlayerSpawnObject(client)
	return !client:IsArrested() and !client:GetPublicVar("tied");
end;

function GM:PlayerUse(client, entity)
	local canUse = !client:IsArrested() and !client:GetPublicVar("tied");

	if ( (client.nextUseKey or 0) >= CurTime() ) then
		return false;
	end;

	if (client:InVehicle() and client:GetVehicle().isSeat) then
		local vehicle = client:GetVehicle();

		client:ExitVehicle(vehicle);

		if (vehicle.exit) then
			local position = entity:GetPos() + (angle:Forward() * vehicle.exit.x) + (angle:Right() * vehicle.exit.y) + (angle:Up() * vehicle.exit.z);

			client:SetPos(position);
		end;

		return true;
	end;

	if (canUse) then
		if (IsValid(entity) and entity:IsVehicle() and IsValid( entity:GetDriver() ) and entity.seats and !entity.locked and !entity.isSeat) then
			if ( entity:HasAccess(client) ) then
				for k, v in pairs(entity.seats) do
					if ( !IsValid( v:GetDriver() ) ) then
						client.nextUseKey = CurTime() + 0.75;
						client:EnterVehicle(v);

						return true;
					end;
				end;
			end;
		end;
	end;

	client.nextUseKey = CurTime() + 0.5;

	return canUse;
end;

function GM:KeyPress(client, key)
	local canUse = !client:IsArrested() and !client:GetPublicVar("tied");

	if ( (client.nextKeyPress) or 0 < CurTime() ) then
		if (key != IN_USE) then
			return;
		end;

		local trace = client:GetEyeTraceNoCursor();
		local entity = trace.Entity;

		if ( canUse and IsValid(entity) and entity:GetPos():Distance( client:GetPos() ) <= 128 and entity:IsPlayer() and entity:GetPublicVar("tied") ) then
			if (entity:IsPlayer() and !entity.beingUnTied) then
				entity.beingUnTied = true;

				local clientOldPos = client:GetPos();
				local oldPos = entity:GetPos();

				entity:EmitSound("npc/strider/creak1.wav");

				timer.Simple(1.5, function()
					if (IsValid(client) and IsValid(entity) and client:GetPos() == clientOldPos and entity:GetPos() == oldPos) then
						client:EmitSound("npc/roller/blade_cut.wav");

						if (entity.tiedWeapons) then
							for k, v in pairs(entity.tiedWeapons) do
								entity:Give(v);
							end;
						end;

						entity:SetPublicVar("tied", false);
						entity.beingUnTied = false;
						entity:EmitSound("npc/combine_soldier/gear4.wav");
					else
						if ( IsValid(client) ) then
							client:Notify("Both of you must stay still while untieing!");
						end;

						if ( IsValid(entity) ) then
							entity:Notify("Both of you must stay still while untieing!");
						end;

						entity.beingUnTied = false;
					end;
				end);
			end;
		end;

		client.nextKeyPress = CurTime() + 3.5;
	end;
end;

function GM:PlayerDeathThink(client)
	if ( (client.deathTime or 0) < CurTime() ) then
		client:Spawn();
	end;

	return false;
end;

function GM:GetGameDescription()
	return "PistachioRP";
end;

function GM:PlayerDeath(client, weapon, killer)
	self.BaseClass:PlayerDeath(client, weapon, killer);

	if ( IsValid(killer) ) then
		if ( killer:IsVehicle() ) then
			if ( IsValid( killer:GetDriver() ) ) then
				killer = killer:GetDriver();
			end;
		end;

		if ( string.find(killer:GetClass(), "prop_*") ) then
			killer = killer:GetAccessOwner();
		end;

		if ( IsValid(killer) and killer:IsPlayer() ) then
			local karma = killer:GetPrivateVar("karma") or 0;
			killer:SetPrivateVar("karma", karma - 1);
		end;
	end;

	client.deathTime = CurTime() + 60;

	local victimKarma = client:GetPrivateVar("karma") or 0;
	local addition = (0 - victimKarma);

	client.deathTime = math.max(client.deathTime + (addition * 5), CurTime() + 5);

	local isFemale = string.find(string.lower( client:GetModel() ), "female") or string.find(string.lower( client:GetModel() ), "alyx") or string.find(string.lower( client:GetModel() ), "mossman");

	if (isFemale) then
		client:EmitSound("vo/npc/female01/pain0"..math.random(1, 9)..".wav");
	else
		client:EmitSound("vo/npc/male01/pain0"..math.random(1, 9)..".wav");
	end;

	local percentage = cvars.Number("ps_deathtax", 0.2);

	if (client:HasItem("insurance") and percentage != 0) then
		percentage = 0.05;
	end;

	local money = tonumber( client:GetPrivateVar("money") or 0);
	local value = math.max(math.floor( money - (money * percentage) ), 0);

	if (math.floor(money * percentage) > 0) then
		local entity = ents.Create("pistachio_money");
		entity:SetPos( client:GetPos() + Vector(0, 0, 8) );
		entity:SetSolid(SOLID_VPHYSICS);
		entity:SetMoveType(MOVETYPE_VPHYSICS);
		entity:PhysicsInit(SOLID_VPHYSICS);
		entity:SetUseType(SIMPLE_USE);
		entity:Spawn();
		entity:SetMoney( math.floor(money * percentage) );
	end;

	client:SetPrivateVar("money", value);

	if (client:Team() == TEAM_MAYOR) then
		for k, v in pairs( player.GetAll() ) do
			v:Notify("Mayor "..client:Name().." has passed away.");
		end;

		client:SetTeam(TEAM_CITIZEN);
	end;

	net.Start("ps_DeathTime");
		net.WriteInt(client.deathTime, 32);
	net.Send(client);

	for k, v in pairs( player.GetAll() ) do
		if ( v:IsAdmin() ) then
			if ( IsValid(client) and IsValid(killer) and client:IsPlayer() and killer:IsPlayer() ) then
				v:NotifyAdmin("Player "..client:Name().." was killed by "..killer:Name().." with "..weapon:GetClass()..".");
			end;
		end;
	end;
end;

function GM:PlayerDisconnected(client)
	self.BaseClass:PlayerDisconnected(client);

	client:RemoveOwnedEntities();
	
	pistachio.chatBox:Message("Player "..client:Name().." has disconnected from the server.");

	table.insert( pistachio.lastTen, {client:Name(), client:SteamID()} );

	if (#pistachio.lastTen > 10) then
		table.remove(pistachio.lastTen, 1);
	end;

	for k, v in pairs( ents.GetAll() ) do
		local owner = v:GetAccessOwner();

		if (IsValid(owner) and owner == client) then
			v:RemoveAccess();
		end;
	end;

	hook.Call("PlayerSaveData", GAMEMODE, client, true);
end;

concommand.Add("ps_lastten", function(p, c, a)
	for k, v in pairs(pistachio.lastTen) do
		if ( v[1] and v[2] ) then
			p:PrintMessage(HUD_PRINTCONSOLE, k..".) "..v[1].." - "..v[2]);
		end;
	end;
end);

function GM:PlayerSpawnSENT(client, class)
	return client:IsAdmin();
end;

function GM:PlayerSpawnSWEP(client, class, weapon)
	return client:IsAdmin();
end;

function GM:PlayerGiveSWEP(client, class, weapon)
	return client:IsAdmin();
end;

function GM:PlayerSpawnEffect(client, model)
	return false;
end;

function GM:PlayerNoClip(client, noclipping)
	return client:IsAdmin();
end;

function GM:PlayerSpawnNPC(client)
	return client:IsAdmin();
end;

function GM:ShutDown()
	for k, v in pairs( player.GetAll() ) do
		hook.Call("PlayerSaveData", GAMEMODE, v);
	end;
end;

function GM:CanPlayerOrderItem(client, itemTable)
	return true;
end;

function GM:PlayerOrderItem(client, itemTable)
end;

function GM:PlayerCanHearPlayersVoice(speaker, listener)
	local enabled = cvars.Bool("ps_enablevoiceradius", true);

	return true, enabled;
end;

function pistachio:CreateItemVehicle(client, itemTable)
	if ( IsValid(client.vehicle) ) then
		return "You already have a vehicle spawned!";
	elseif ( (client.vehicleTime or 0) > CurTime() ) then
		return "You can't spawn a vehicle right now.";
	end;

	local position = client:GetEyeTraceNoCursor().HitPos;

	if (client:GetPos():Distance(position) > 256) then
		position = client:GetShootPos() + (client:GetAimVector() * 72);
	end;

	if (position) then
		local entity = ents.Create("prop_vehicle_jeep");
		entity:SetModel(itemTable.model);
		entity:SetKeyValue("vehiclescript", "scripts/vehicles/"..itemTable.vehicleScript..".txt");
		entity:SetPos( position + Vector(0, 0, 48) );
		entity:SetAngles( client:EyeAngles() );
		entity:Spawn();
		entity:Activate();
		entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);
		entity:SetRenderMode(RENDERMODE_TRANSALPHA);
		entity:SetColor( Color(255, 255, 255, 50) );
		entity:Fire("lock");
		entity.itemTable = itemTable;
		entity.locked = true;
		entity:GiveAccess(client, true);

		if (itemTable.exit) then
			entity.exit = itemTable.exit;
		end;

		local physicsObject = entity:GetPhysicsObject();

		--[[
		if ( IsValid(physicsObject) ) then
			if ( physicsObject:IsPenetrating() ) then
				entity:Remove();

				return "Unable to find space for your vehicle!";
			end;
		else
		--]]

		if ( !IsValid(physicsObject) ) then
			return "Invalid vehicle physics!";
		end;

		timer.Simple(5, function()
			if ( IsValid(entity) and IsValid(client) ) then
				entity:SetCollisionGroup(COLLISION_GROUP_NONE);
				entity:SetColor( Color(255, 255, 255, 255) );
			end;
		end);

		if (itemTable.seats) then
			for k, v in ipairs(itemTable.seats) do
				local angle = entity:GetAngles();
				local position = entity:GetPos() + (angle:Forward() * v.offset.x) + (angle:Right() * v.offset.y) + (angle:Up() * v.offset.z);

				local seat = ents.Create("prop_vehicle_prisoner_pod");
				seat:SetModel("models/nova/jeep_seat.mdl");
				seat:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				seat:SetPos(position);
				seat:SetAngles(angle + v.rotation);
				seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
				seat:SetRenderMode(RENDERMODE_TRANSALPHA);
				seat:SetColor( Color(255, 255, 255, 0) );
				seat:SetParent(entity);
				seat:Spawn();
				seat:Activate();
				seat:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				seat:Fire("lock");
				seat.isSeat = true;
				seat:GiveAccess(client, true);

				if (v.exit) then
					seat.exit = v.exit;
				end;

				entity:DeleteOnRemove(seat);
				entity.seats = entity.seats or {};

				table.insert(entity.seats, seat);
			end;
		end;

		local vehicleDelay = cvars.Number("ps_carspawndelay", 600);

		client.vehicle = entity;
		client.vehicleTime = CurTime() + vehicleDelay;

		return "You've spawned a vehicle.";
	else
		return "You can't spawn a vehicle that far away!";
	end;

	return "An error has occured while spawning your vehicle!";
end;

function GM:PlayerLeaveVehicle(client, vehicle)
	if (vehicle.exit) then
		local position = entity:GetPos() + (angle:Forward() * vehicle.exit.x) + (angle:Right() * vehicle.exit.y) + (angle:Up() * vehicle.exit.z);

		client:SetPos(position);
	end;

	if (!vehicle.isSeat) then
		vehicle:Lock();
		vehicle:EmitSound("doors/door_latch3.wav");
	end;
end;

net.Receive("ps_PlayerModel", function(length, client)
	local model = net.ReadString();
	local modelTable = pistachio.playerModels[ client:Team() ];

	if (!modelTable) then
		modelTable = pistachio.playerModels[TEAM_CITIZEN];
	end;

	for k, v in pairs(modelTable) do
		if ( string.lower(v) == string.lower(model) ) then
			client:SetModel(v);
			client:Notify("You've changed your model to: "..v);

			if (client:Team() == TEAM_CITIZEN) then
				client:SetPrivateVar("model", v);
			end;

			return;
		end;
	end;

	net.Start("ps_ChangeModel");
	net.Send(client);
end);

net.Receive("ps_PlayerGetData", function(length, client)
	if ( IsValid(client) ) then
		client:ChatPrint("Loading Pistachio...");

		local count = 0;

		for k, v in pairs( ents.GetAll() ) do
			if (v.publicVars) then
				count = count + table.Count(v.publicVars);
			end;

			if (v.access) then
				count = count + table.Count(v.access);
			end;
		end;

		net.Start("ps_TotalVars");
			net.WriteUInt(count, 16);
		net.Send(client);

		local index = 0;
		local variableEntities = {};

		for k, v in pairs( ents.GetAll() ) do
			if (v.publicVars or v.access) then
				variableEntities[#variableEntities + 1] = v;
			end;
		end;

		local totalTime = 0;

		for k, v in pairs(variableEntities) do
			local variables = 0;

			if (v.publicVars) then
				variables = variables + table.Count(v.publicVars);
			end;

			if (v.access) then
				variables = variables + table.Count(v.access);
			end;

			local expectedTime = (k * 0.0005) + (variables * 0.05) + (client:Ping() / 250);
			local uniqueID = "ps_Progress"..client:UniqueID()..k;

			totalTime = totalTime + expectedTime;

			timer.Create(uniqueID, expectedTime, 1, function()
				if ( IsValid(client) and IsValid(v) ) then
					v:SendData(client);
					v:SendAccess(client);
				end;

				net.Start("ps_Progress");
					net.WriteUInt(variables, 8);
				net.Send(client);

				timer.Destroy(uniqueID)
			end);
		end;

		timer.Simple(client:Ping() / 100, function()
			if ( IsValid(client) ) then
				local defaultMoney = cvars.Number("ps_defaultmoney", 50);

				client:SetTeam(TEAM_CITIZEN);
				client:SetPublicVar("job", "Unemployed");
				client:SetPrivateVar("money", defaultMoney);
				client:SetPrivateVar("stamina", 100);

				hook.Call("PlayerLoadData", GAMEMODE, client);
				hook.Call("PlayerLoadout", GAMEMODE, client);

				client.ps_Loaded = true;
				client:ChatPrint("Pistachio has been loaded!");
			end;
		end);
	end;
end);

pistachio.laws = pistachio.laws or {
	"Having weapons is not permitted.",
	"Do not cause public disturbances.",
	"Do not block public areas with your property.",
	"Murder is illegal.",
	"Stealing is illegal.",
	"You are not allowed to consume alcohol in public.",
	"Regular civilians are not allowed in the police department.",
	"Gambling in public is not allowed.",
	"Contraband is not allowed at all times.",
	"Assault is not allowed.",
	"Follow all traffic signals.",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	""
};

net.Receive("ps_EditLaw", function(length, client)
	if (IsValid(client) and client:Team() == TEAM_MAYOR) then
		if ( (client.nextLaw or 0) < CurTime() ) then
			local index = net.ReadUInt(8);
			local text = net.ReadString() or "";

			if ( pistachio.laws[index] ) then
				pistachio.laws[index] = text;

				net.Start("ps_UpdateLaw");
					net.WriteUInt(index, 8);
					net.WriteString(text);
				net.Broadcast();

				for k, v in pairs( player.GetAll() ) do
					v:Notify("Mayor "..client:Name().." has updated law #"..index..".");
				end;
			else
				client:Notify("Exception (EW) - Non-existent index!");

				return;
			end;

			client.nextLaw = CurTime() + 10;
		else
			client:Notify("You cannot modify another law yet!");
		end;
	end;
end);

net.Receive("ps_OrderItem", function(length, client)
	local uniqueID = net.ReadString();

	if (uniqueID) then
		local itemTable = pistachio.item:Get(uniqueID);

		if (itemTable) then
			if ( client:IsArrested() ) then
				client:Notify("You cannot order items while being arrested!");

				return;
			end;

			local shouldOrderItem = hook.Call("CanPlayerOrderItem", GAMEMODE, client, itemTable);

			if (shouldOrderItem) then
				local cost = itemTable.price or 0;
				local money = client:GetPrivateVar("money") or 0;

				if (money - cost < 1) then
					client:Notify("You cannot afford this item!");

					return;
				else
					client:SetPrivateVar("money", money - cost);
				end;

				client:Notify("You've placed an order and it'll be mailed shortly.");

				hook.Call("PlayerOrderItem", GAMEMODE, client, itemTable);

				local time = math.random(180, 300);

				client:AddMailBoxItem(uniqueID, 1, time);
			end;
		end;
	end;
end);

net.Receive("ps_SelectShirtColor", function(length, client)
	local red = net.ReadUInt(8);
	local green = net.ReadUInt(8);
	local blue = net.ReadUInt(8);

	if ( !client:HasItem("dye") ) then
		return;
	end;

	if (red and green and blue) then
		client:SetPrivateVar("color", red..","..green..","..blue);

		if (client:Team() == TEAM_CITIZEN) then
			client:SetColor( Color(red, green, blue, 255) );
			client:Notify("You've changed the color of your shirt.");
		else
			client:Notify("Your shirt color will change when you're a citizen again.");
		end;
		
		client:TakeItem("dye");

		hook.Call("PlayerSaveData", GAMEMODE, client, false, true);
	end;
end);

concommand.Add("melonsauce", function(p, c, a)
	local shouldKick = cvars.Bool("ps_kickafk", true);

	if (IsValid(p) and shouldKick) then
		p:Kick("Away from keyboard");
	end;
end);

concommand.Add("ps_honk", function(p, c, a)
	if ( (p.lastHonk or 0) < CurTime() ) then
		local vehicle = p:GetVehicle();

		if ( IsValid(vehicle) ) then
			local itemTable = vehicle.itemTable;

			if (itemTable and itemTable.honk) then
				vehicle:EmitSound("vehicles/"..itemTable.honk..".wav", 125);
			end;
		end;

		p.lastHonk = CurTime() + 5;
	end;
end);