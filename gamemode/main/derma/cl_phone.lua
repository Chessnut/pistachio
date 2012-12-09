if (SERVER) then
	util.AddNetworkString("ps_TogglePhone");

	return;
end;

local PANEL = {};

local PS_CVAR_LINES = CreateClientConVar("ps_phone_lines", "8", true, false);
local PS_CVAR_RED = CreateClientConVar("ps_phone_r", "100", true, false);
local PS_CVAR_GREEN = CreateClientConVar("ps_phone_g", "100", true, false);
local PS_CVAR_BLUE = CreateClientConVar("ps_phone_b", "100", true, false);

local phone = {};
phone.rows = {};
phone.offset = 0;
phone.color = Color(100, 100, 100);
phone.maxRows = 8;
phone.currentRow = 0;

surface.CreateFont("ps_PhoneFont", {
	font = "Tahoma",
	size = 14,
	weight = 400,
	antialias = true
} );

local COLORS = {
	{ "Black", Color(5, 5, 5) },
	{ "Dark Grey", Color(75, 75, 75) },
	{ "Grey", Color(125, 125, 125) },
	{ "Light Grey", Color(200, 200, 200) },
	{ "Red", Color(250, 25, 25) },
	{ "Pale Red", Color(250, 100, 100) },
	{ "Dark Red", Color(100, 0, 0) },
	{ "Orange", Color(250, 125, 25) },
	{ "Pale Orange", Color(250, 200, 150) },
	{ "Dark Orange", Color(100, 75, 0) },
	{ "Yellow", Color(250, 250, 25) },
	{ "Pale Yellow", Color(250, 250, 100) },
	{ "Dark Yellow", Color(100, 100, 0) },
	{ "Green", Color(25, 250, 25) },
	{ "Pale Green", Color(100, 250, 100) },
	{ "Dark Green", Color(0, 100, 0) },
	{ "Blue", Color(25, 25, 250) },
	{ "Pale Blue", Color(100, 100, 250) },
	{ "Dark Blue", Color(0, 0, 100) },
	{ "Magenta", Color(250, 25, 250) },
	{ "Pale Magenta", Color(250, 150, 250) },
	{ "Dark Magenta", Color(100, 0, 100) },
	{ "Pink", Color(250, 100, 250) },
	{ "Pale Pink", Color(250, 175, 250) },
	{ "Dark Pink", Color(100, 50, 100) },
	{ "Purple", Color(100, 0, 100) },
	{ "Pale Purple", Color(100, 75, 100) },
	{ "Dark Purple", Color(50, 0, 50) }
};

function phone:SetupRow(parent, index, name, Callback, isHomeRow)
	if (!parent) then
		return;
	end;

	if (parent != phone.rows and !parent.rows) then
		parent.rows = {};
	end;

	parent.rows[index] = {
		name = name,
		home = isHomeRow,
		Callback = Callback
	};

	if (parent != phone.rows) then
		parent.rows[index].parent = parent;
	end;

	return parent.rows[index];
end;

function phone:ClearScreen(row)
	self.currentRow = row or 0;
	self.rows = {};
	self.offset = 0;
end;

function phone:Init()
	self.maxRows = math.Clamp(PS_CVAR_LINES:GetInt(), 4, 12);

	self.color = Color( PS_CVAR_RED:GetInt(), PS_CVAR_GREEN:GetInt(), PS_CVAR_BLUE:GetInt() );

	self:SetupRow(self, 1, "Contacts", function(parent)
		self:ClearScreen();

		for k, v in SortedPairs( player.GetAll() ) do
			self:SetupRow( parent, k, v:Name(), function(parent2)
				self:SetupRow(parent2, 1, "Call");
				self:SetupRow(parent2, 2, "Text");
			end);
		end;
	end, true);

	self:SetupRow(self, 2, "Settings", function(parent)
		self:ClearScreen();

		self:SetupRow(parent, 1, "Lines", function(parent2)
			self:ClearScreen();

			for i = 4, 12 do
				self:SetupRow( parent2, i - 3, i, function()
					RunConsoleCommand("ps_phone_lines", i);

					self.maxRows = math.Clamp(i, 4, 12);
				end);
			end;
		end);

		self:SetupRow(parent, 2, "Color", function(parent2)
			self:ClearScreen();

			for k, v in ipairs(COLORS) do
				self:SetupRow( parent2, k, v[1], function()
					local color = v[2];

					RunConsoleCommand("ps_phone_r", color.r);
					RunConsoleCommand("ps_phone_g", color.g);
					RunConsoleCommand("ps_phone_b", color.b);

					self.color = color;
				end);
			end;
		end)
	end, true);
end;

function phone:Paint(w, h)
	local r, g, b = self.color.r or 100, self.color.g or 100, self.color.b or 100;

	surface.SetDrawColor(r, g, b, 255);
	surface.DrawRect(0, 0, w, h);

	local index = 0;
	local fraction = h / self.maxRows;

	for i = 0, self.maxRows - 1 do
		index = math.abs(index - 1);

		if (self.currentRow == i) then
			local glow = math.Clamp(math.abs(math.sin(CurTime() * 0.75) * 50), 25, 50);

			surface.SetDrawColor(255, 255, 255, glow);
		elseif (index == 1) then
			surface.SetDrawColor(0, 0, 0, 25);
		else
			surface.SetDrawColor(255, 255, 255, 0);
		end;

		surface.DrawRect(0, i * fraction, w, fraction);
	end;

	for k, v in ipairs(self.rows) do
		surface.SetFont("ps_PhoneFont");

		local row = self.rows[k + self.offset];

		if (row) then
			local w, h = surface.GetTextSize(row.name or "Missing string!");

			draw.SimpleText(row.name or "Missing string!", "ps_PhoneFont", 5, (k * fraction) - (fraction * 0.5), Color(0, 0, 0, 255), 0, 1);
			draw.SimpleText(row.name or "Missing string!", "ps_PhoneFont", 4, (k * fraction) - (fraction * 0.5) + 1, Color(255, 255, 255, 255), 0, 1);
		end;
	end;
end;

function phone:AdjustRows()
	if (#self.rows > self.maxRows) then
		if (self.currentRow == self.maxRows - 1) then
			self.offset = math.Clamp(self.offset + 1, 0, #self.rows - self.maxRows);
		elseif (self.currentRow == 0) then
			self.offset = math.Clamp(self.offset - 1, 0, #self.rows - self.maxRows);
		end;
	end;
end;

function PANEL:Init()
	self:SetSize(267, 480);
	self:SetPos( ScrW() - 331, ScrH() );

	self.screen = self:Add("DPanel");
	self.screen:Dock(FILL);
	self.screen:DockMargin(51, 51, 54, 213);
	self.screen:DockPadding(5, 5, 5, 5);
	self.screen.Paint = function(screen, w, h)
		phone:Paint(w, h);
	end;

	phone:Init();

	self:MoveTo(ScrW() - 331, ScrH() - 335, 0.5, 0, 2);
end;

local material = Material("pistachio/phone.png");

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(material);
	surface.DrawTexturedRect(0, 0, 267, 480);
end;

vgui.Register("ps_Phone", PANEL, "DPanel");

net.Receive("ps_TogglePhone", function(length)
	if ( IsValid(pistachio.phone) ) then
		pistachio.phone:Remove();
	else
		pistachio.phone = vgui.Create("ps_Phone");
	end;
end);

hook.Add("PlayerBindPress", "ps_PhoneBinds", function(client, bind, pressed)
	bind = string.lower(bind);

	if ( IsValid(pistachio.phone) ) then
		if (string.find(bind, "+forward") and pressed) then
			phone.currentRow = math.Clamp( phone.currentRow - 1, 0, math.min(#phone.rows - 1, phone.maxRows - 1) );

			phone:AdjustRows();

			return true;
		elseif (string.find(bind, "+back") and pressed) then
			phone.currentRow = math.Clamp( phone.currentRow + 1, 0, math.min(#phone.rows - 1, phone.maxRows - 1) );

			phone:AdjustRows();

			return true;
		elseif (string.find(bind, "+moveright") and pressed) then
			local row = phone.rows[phone.currentRow + 1 + phone.offset];

			if (row and row.Callback) then
				row.Callback(row);

				if (row.rows) then
					phone.rows = row.rows;
				end;
			end;

			return true;
		elseif (string.find(bind, "+moveleft") and pressed) then
			local row = phone.rows[phone.currentRow + 1 + phone.offset];

			if (row and row.parent and row.parent.parent and row.parent.parent.Callback) then
				row.parent.parent.Callback(row.parent.parent);

				phone.rows = row.parent.parent.rows;
			else
				phone:ClearScreen();
				phone:Init();
			end;

			return true;
		end;
	end;
end);