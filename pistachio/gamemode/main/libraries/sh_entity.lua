local _R = debug.getregistry();
local entityMeta = _R.Entity;

function entityMeta:IsDoor()
	if ( IsValid(self) ) then
		return string.find(self:GetClass(), "door");
	else
		return false;
	end;
end;

function entityMeta:IsOwnable()
	if ( IsValid(self) and ( self:IsDoor() or self:IsVehicle() ) and !self:IsAccessed() ) then
		return true;
	end;

	return false;
end;

function entityMeta:Lock()
	if ( IsValid(self) ) then
		self:Fire("lock");
		self.locked = true;
	end;
end;

function entityMeta:UnLock()
	if ( IsValid(self) ) then
		self:Fire("unlock");
		self.locked = false;
	end;
end;