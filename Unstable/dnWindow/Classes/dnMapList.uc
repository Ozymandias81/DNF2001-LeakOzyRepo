class dnMapList expands UWindowListBoxItem;

var string MapName;
var string DisplayName;

function int Compare(UWindowList T, UWindowList B)
{
	if(Caps(dnMapList(T).MapName) < Caps(dnMapList(B).MapName))
		return -1;

	return 1;
}

// Call only on sentinel
function dnMapList FindMap(string FindMapName)
{
	local dnMapList I;

	for(I = dnMapList(Next); I != None; I = dnMapList(I.Next))
		if(I.MapName ~= FindMapName)
			return I;

	return None;
}