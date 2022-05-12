class UMenuMapList expands UWindowListBoxItem;

var string MapName;
var string DisplayName;

function int Compare(UWindowList T, UWindowList B)
{
	if(Caps(UMenuMapList(T).MapName) < Caps(UMenuMapList(B).MapName))
		return -1;

	return 1;
}

// Call only on sentinel
function UMenuMapList FindMap(string FindMapName)
{
	local UMenuMapList I;

	for(I = UMenuMapList(Next); I != None; I = UMenuMapList(I.Next))
		if(I.MapName ~= FindMapName)
			return I;

	return None;
}