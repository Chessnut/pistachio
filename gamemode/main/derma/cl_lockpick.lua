if (SERVER) then
	util.AddNetworkString("ps_LockPickPanel");
	util.AddNetworkString("ps_LockPickPass");
	util.AddNetworkString("ps_LockPickFail");

	net.Receive("ps_LockPickPass", function(length, client)
		local entity = net.ReadEntity();

		if (IsValid(entity) and IsValid(entity.picker) and entity.picker == client and entity:GetPos():Distance( client:GetPos() ) <= 128) then
			entity.locked = false;
			entity.picker = nil;
			entity:Fire("unlock");

			if ( entity:IsDoor() ) then
				entity:Fire("open");
			elseif ( entity:IsVehicle() and !IsValid( entity:GetDriver() ) ) then
				client:EnterVehicle(entity);
			end;
		end;
	end);

	net.Receive("ps_LockPickFail", function(length, client)
		local entity = net.ReadEntity();

		if (IsValid(entity) and IsValid(entity.picker) and entity.picker == client) then
			entity.picker = nil;
		end;
	end);

	return;
end;

local PANEL = {};

PANEL.alphaDelta = 0;
PANEL.alpha = 0;

local PEICE_HEIGHT = 360;
local MAX_TIME = 16;

function PANEL:Init()
	if ( IsValid(pistachio.menu) ) then
		pistachio.menu:Remove();
	end;

	self:SetSize( ScrW(), ScrH() );
	
	self.panel = self:Add("DPanel");
	self.panel:SetPos( (ScrW() * 0.5) - 640, (ScrH() * 0.5) - 640 );
	self.panel:SetSize(640, 640);
	self.panel:SetDrawBackground(false);
	self.panel:Center();

	self.lock = self.panel:Add("DModelPanel");
	self.lock:SetModel("models/props_wasteland/prison_padlock001a.mdl");
	self.lock:Dock(FILL);
	self.lock:SetCamPos( Vector(120, 0, 0) );
	self.lock:SetFOV(4);
	self.lock:SetLookAt( Vector(0, 0, 0) );
	self.lock:SetColor( Color(255, 255, 255, 255) );
	self.lock:Center();
	self.lock.LayoutEntity = function(self, entity)
		if (self.bAnimated) then
			self:RunAnimation();
		end;
	end;

	self.pick = self.panel:Add("DModelPanel");
	self.pick:SetModel("models/weapons/w_crowbar.mdl");
	self.pick:SetSize(640, 640);
	self.pick:SetCamPos( Vector(0, -30, -30) );
	self.pick:SetFOV(50);
	self.pick:SetAlpha(0);
	self.pick:SetLookAt( Vector(0, 90, 90) );
	self.pick.LayoutEntity = function(self, entity)
		if (self.bAnimated) then
			self:RunAnimation();
		end;
	end;

	self.pick.Think = function(self)
		local x = gui.MouseX() - 560;
		local click = math.Clamp( (self.lastClick or 0) - CurTime(), 0, 1 ) * 360;
		local positionX, positionY = self:GetParent():GetPos();

		x = math.Clamp(x, positionX - 640, positionX);

		self:SetPos(x, -click + PEICE_HEIGHT - 80);
	end;

	self.pick.DoPickAction = function(self)
		if ( (self.lastClick or 0) < CurTime() ) then
			self.lastClick = CurTime() + 0.1;
		end;

		LocalPlayer():EmitSound("physics/metal/metal_grenade_impact_hard"..math.random(1, 3)..".wav", 150);
	end;

	self.peices = {};

	local order = {1, 2, 3, 4, 5};

	for i = 1, 5 do
		local index = math.random(1, #order);
		local chosen = order[index];

		table.remove(order, index);

		local peice = self.panel:Add("ps_LockPeice");
		peice:SetAlpha(0);
		peice.id = chosen;
		peice:SetPos(i * 96, PEICE_HEIGHT);

		table.insert(self.peices, peice);
	end;

	self.overlay = self:Add("DButton");
	self.overlay:Dock(FILL);
	self.overlay:SetText("");
	self.overlay.Paint = function()
	end;

	self.overlay.DoClick = function(overlay)
		if (self.shouldRemove) then
			return;
		end;

		local x, y = gui.MousePos();

		for k, v in pairs(self.peices) do
			local positionX = self.panel:LocalToScreen( v:GetPos() );

			if (x <= positionX + 64 and x >= positionX) then
				self.pick:DoPickAction();

				v:PerformPick();

				return;
			end;
		end;
	end;

	self.finish = CurTime() + MAX_TIME;
	self.initialized = true;
	self.alpha = 255;

	gui.EnableScreenClicker(true);
end;

function PANEL:SetEntity(entity)
	self.entity = entity;
end;

function PANEL:Think()
	if (self.initialized) then
		if (IsValid(self.entity) and !self.shouldRemove and self.finish - CurTime() <= 0) then
			LocalPlayer():EmitSound("weapons/crowbar/crowbar_impact"..math.random(1, 2)..".wav", 130);

			self.shouldRemove = true;
			self.alpha = 0;

			net.Start("ps_LockPickFail");
				net.WriteEntity(self.entity);
			net.SendToServer();

			return;
		elseif (IsValid(self.entity) and !self.shouldRemove) then
			local amount = 0;

			for k, v in pairs(self.peices) do
				local x, y = v:GetPos();

				if (y < PEICE_HEIGHT) then
					amount = amount + 1;
				end;
			end;

			if (amount == 5) then
				LocalPlayer():EmitSound("weapons/357/357_reload4.wav", 150);

				self.shouldRemove = true;
				self.removeTime = CurTime() + 4;
				self.lock:SetModel("models/props_wasteland/prison_padlock001b.mdl");

				net.Start("ps_LockPickPass");
					net.WriteEntity(self.entity);
				net.SendToServer();

				return;
			end;
		elseif ( self.removeTime and self.removeTime < CurTime() ) then
			self.alpha = 0;
		end;
	end;
end;

function PANEL:Paint(w, h)
	self.alphaDelta = math.Approach(self.alphaDelta, self.alpha, FrameTime() * 300);

	surface.SetDrawColor(0, 0, 0, self.alphaDelta);
	surface.DrawRect(0, 0, w, h);

	if (self.initialized) then
		self.pick:SetColor( Color(255, 255, 255, self.alphaDelta) );
		self.lock:SetColor( Color(255, 255, 255, self.alphaDelta - 1) );

		for k, v in pairs(self.peices) do
			v:SetAlpha(self.alphaDelta);
		end;
	end;

	if (self.shouldRemove and self.alphaDelta == 0) then
		self:Remove();

		gui.EnableScreenClicker(false);

		return;
	end;

	local time = math.Clamp( ( self.finish - CurTime() ) / MAX_TIME, 0, 1 );

	surface.SetDrawColor(255 - (255 * time), 255 * time, 0, self.alphaDelta);
	surface.DrawRect(ScrW() * 0.25, ScrH() - 32, ScrW() * (0.5 * time), 16);

	surface.SetDrawColor(255, 255, 255, self.alphaDelta * 0.1);
	surface.DrawOutlinedRect(ScrW() * 0.25, ScrH() - 32, ScrW() * 0.5, 16);
end;

vgui.Register("ps_LockPick", PANEL, "DPanel");

local PANEL = {};

function PANEL:Init()
	self:SetSize(64, 128);
	self:SetFOV(8);
	self:SetCamPos( Vector(270, 0, 90) );
	self:SetModel("models/props_c17/oildrum001.mdl");
end;

function PANEL:SetAlpha(alpha)
	self.alpha = alpha;
end;

function PANEL:LayoutEntity(entity)
	if (self.bAnimated) then
		self:RunAnimation();
	end;

	entity:SetSkin(1);
	self:SetColor( Color(255, 255, 255, self.alpha or 0) );
end;

local factor = 0.37225;

function PANEL:Think()
	local x = self:GetPos();
	local y = PEICE_HEIGHT - ( math.Clamp( ( (self.pickTime or 0) - CurTime() ) / (self.id * factor), 0, 1 ) * 160 );

	self:SetPos(x, y);
end;

function PANEL:PerformPick()
	self.pickTime = CurTime() + (self.id * factor);
end;

vgui.Register("ps_LockPeice", PANEL, "DModelPanel");

pistachio.lockpick = pistachio.lockpick or nil;

net.Receive("ps_LockPickPanel", function(length)
	local entity = net.ReadEntity();

	if ( !IsValid(pistachio.lockpick) and IsValid(entity) ) then
		pistachio.lockpick = vgui.Create("ps_LockPick");
		pistachio.lockpick:SetEntity(entity);
	end;
end);