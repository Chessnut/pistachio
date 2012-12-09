local ITEM = {};

ITEM.base = "base_hat";
ITEM.name = "Afro";
ITEM.uniqueID = "hat_afro";
ITEM.model = "models/Combine_Helicopter/helicopter_bomb01.mdl";
ITEM.description = "Some black hair piled into a sphere.";
ITEM.price = 750;
ITEM.offset = {-3, 7, 0};
ITEM.rotation = {90, 180, 90};
ITEM.scale = 0.55;

function ITEM:LayoutEntity(entity)
	entity:SetMaterial("models/props_foliage/tree_deciduous_01a_trunk");
	entity:SetColor( Color(75, 60, 60, 255) );
end;

pistachio.item:Register(ITEM);