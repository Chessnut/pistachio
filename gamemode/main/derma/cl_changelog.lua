if (SERVER) then return; end;

local PANEL = {};

local changeLog = [[
:10/16/2012
- Added more models, removed Pistachio player models.
- Changed the dye to use the new model coloring method.
- Some small fixes regarding new update.
- Fixed ammo displaying for gravity gun.
- Boosted arrest time.
- Fixed bug with prop killing not taking karma.
:10/12/2012
- Updated EntityTakeDamage hook to use new arguments.
- Added lockpicking.
:10/8/2012
- Fixed vehicles sometimes not unlocking.
- Fixed weapons and items duplicating when used.
- Added item use menu instead of holding down certain buttons.
- Added vehicle honking.
- Removed bus from being on sale.
- Vehicles will now autolock to prevent theft. (Hoge...)
- Added prevention for mailbox/atm duplicates.
:9/29/2012
- Mailbox items that are being ordered should save time.
- Added prop refunding.
- You'll only need to pay for props if your karma is under one.
- Fixed some networking issues with mailbox.
- Added a loading bar to the loading screen to show progress.
- Fixed punching going through fences and ignoring distance.
- Fixed some small stuff.
:9/24/2012
- Icon for scoreboard should now update for players.
- Voice icon should update as well.
- Some unrecorded changes, small things...
:9/21/2012
- Fixed some minor issues.
- Fixed some issues with the chatbox.
- Added ATM system.
:9/16/2012
- Changed Mayor and Officer to require a certain amount of karma.
- Lowered gun costs.
- Fixed issue with gravity gun punting making doors go up.
- Fixed some variables not resetting on death.
:9/15/2012
- Changed saving interval to 5 minutes rather than 10.
- Fixed mailbox saving.
- Implemented new menu skin.
- Fixed /resign setting the wrong team.
- Fixed giving zero items when you didn't get paid.
- Fixed items not dropping with gravity gun punt.
- Fixed items being able to be used when arrested/tied.
:9/13/2012
- Added ps_showmyvote 1/0 to toggle showing your vote.
- Added rope and the ability to untie by pressing Use on someone.
- Added /Pm to private message other players.
- Mayors now need a reason to warrant.
- Leaving /Job blank will now make you unemployed.
- Player information should be dynamicly placed rather than hard coded.
:9/12/2012
- Added /Broadcast for mayors.
- Made headbobbing disabled by default.
- Added ps_showooc 1/0 to toggle the visibility of OOC chat.
- Changed mailboxes to glow red if no items, green if there are items.
- Police have a slight stamina boost.
:9/8/2012
- Fixed items being picked up with E when it shouldn't.
- Fixed scoreboard staying stuck if Lua got updated.
- Added new citizen models.
- Added Dye item.
- Added rank icons in scoreboard, along with some gradients.
:9/3/2012
- Breaching can now be done by officers, but you lose karma without a warrant.
- Added /TakeOwnership and /AllowOwnership
- Fixed chatmodes conflicting with commands.
- Added storage.
- Added command for super admins to set stock of items.
- Added /Holster to holster your weapon.
:9/2/2012
- Added item damage.
- Added money printers.
- Added weapons.
:9/1/2012
- Added headbobbing effects.
- Added first-person death.
- Added "ps_headbob" convar which also accepts decimals from 0 trough 1.
- Changed the death sounds.
- Weight if items will now affect your walking and running speed.
:8/31/2012
- Fixed hats removing players.
:8/30/2012
- Added more hats.
- Added developer particles.
- Added item base inheritance.
- Items will just spawn at a certain distance if dropped too far.
- Fixed persisting variables saving with wrong data type.
:8/28/2012
- Added hats.
- Changed stamina so you tire out when it reaches 0.
:8/27/2012
- Fixed item's stocks increasing by only one day's worth when it's been over one day.
- Fixed item prices resetting once the Lua refreshed.
:8/25/2012
- Added stock system to items.
- Fixed money floating when dropped.
- Fixed data for the map not loading properly.
- Fixed stocks resetting with the Lua refresh.
- Fixed panel scrolling for good.
- Changed the market/inventory to use categories.
:8/24/2012
- Added mailbox system.
- Added paycheck item.
- Changed payday to use the mailbox system.
:8/23/2012
- Fixed networking not working with entities outside PVS. Thanks ArmageddonSrc!
- Administrator commands will be hidden from the help menu.
:8/22/2012
- Added modules system.
- Added /doorsetteam for administrators.
- Added /doorsetunownable for administrators.
- Added item name coloring.
:8/21/2012
- Added punching ability.
- Added knocking on doors.
- Fixed bug in /dropmoney causing errors.
:8/20/2012
- Changed it so door/entity info only draws when being looked at.
- Added flashlight time.
:8/17/2012
- Added scrolling panel object to use for menus that need it.
- Fixed ability to use the properties on objects you don't have access to.
- Changed it so vehicles now start off locked, forcing you to buy them with F2.
:8/16/2012
- Added access library.
- Fixed spawn time not having a minimum time of five seconds.
:8/15/2012
-Initial playable release.
]];

function PANEL:Init()
	self.list = vgui.Create("ps_ListPanel", self);
	self.list:Dock(FILL);

	local explodedString = string.Explode("\n", changeLog);

	for k, v in ipairs(explodedString) do
		local isHeader = (string.sub(v, 1, 1) == ":");
		local label = self.list:AddItem("DLabel");

		if (isHeader) then
			label:SetFont("ps_TitleFont");
			label:SetTextColor( Color(100, 100, 100, 255) );

			v = string.sub(v, 2);
		else
			label:SetTextColor( Color(80, 80, 80, 255) );

			v = "   "..v;
		end;

		label:SetText(v);
	end;
end;

vgui.Register("ps_ChangeLog", PANEL, "Panel");