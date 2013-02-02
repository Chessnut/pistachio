--[[
	The use of a MySQL database is completely optional.
	This gamemode will be using gmsv_mysqloo which can be
	found at: http://facepunch.com/showthread.php?t=1220537

	Thanks to Drakehawke.
--]]

PS_USE_MYSQL = false; -- True/false to set whether MySQL is used. Default false to use SQLite.

local MYSQL_HOSTNAME = "localhost";		-- The host of your database.
local MYSQL_USERNAME = "root";			-- Which user it will be logged in with.
local MYSQL_PASSWORD = "password";		-- The password for the user.
local MYSQL_DATABASE = "pistachio";		-- Which database contains the tables.
local MYSQL_PORT = 3306;				-- The port for the database. Default is 3306.

-- You shouldn't be changing anything below this line
-- unless you want to modify which module to use or something else.

pistachio.db = pistachio.db or {};

-- These are assumed tables that are assumed already made.
-- Used in the persist functions.
pistachio.db.tables = {
	money = {table = "Money", data = "number"},
	title = {table = "Title", data = "string"},
	karma = {table = "Karma", data = "number"},
	model = {table = "Model", data = "string"},
	hat = {table = "Hat", data = "string"},
	particle = {table = "Particle", data = "string"},
	color = {table = "Color", data = "string"},
	bank = {table = "Bank", data = "number"}
};

function pistachio.db:Connect()
	if (self.obj) then
		print("[Pistachio] MySQL connection already exists.");

		return;
	end;

	print("[Pistachio] Loading MySQL...");

	local database = mysqloo.connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE, MYSQL_PORT);

	function database:onConnected()
		pistachio.db.obj = self;

		MsgC(Color(0, 255, 0), "[Pistachio] Connected to the database!\n");
	end;

	function database:onConnectionFailed(message)
		MsgC(Color(255, 0, 0), "[Pistachio] Connection failed! "..message.."\n");
		MsgC(Color(255, 0, 0), "[Pistachio] Reverting to file/SQLite storage.\n");

		PS_USE_MYSQL = false;
	end;

	if (database) then
		database:connect();
	end;
end;

function pistachio.db:Query(query, Callback)
	if (!query) then
		return;
	end;

	if (!PS_USE_MYSQL or !self.obj) then
		MsgC(Color(255, 255, 0), "[Pistachio MySQL] Warning! A query is being made but no database!\n");

		return;
	end;

	local query = self.obj:query(query);
		if (Callback) then
			function query:onSuccess(data)
				Callback(data);
			end;
		end;

		function query:onError(message, sql)
			MsgC(Color(255, 0, 0), "[Pistachio] Query Error! "..message.."\n");
			MsgC(Color(255, 0, 0), "[Pistachio] "..sql.."\n");			
		end;
	query:start();
end;

if (!PS_USE_MYSQL) then
	MsgC(Color(255, 0, 0), "[Pistachio] Not using MySQL, switching to file/SQLite storage.\n");

	return;
else
	require("mysqloo");

	pistachio.db:Connect();
end;
