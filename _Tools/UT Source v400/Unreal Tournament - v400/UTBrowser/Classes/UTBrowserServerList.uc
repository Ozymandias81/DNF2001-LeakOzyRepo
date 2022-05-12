class UTBrowserServerList expands UBrowserServerList;

var bool bNGWorldStats;

function bool DecodeServerProperties(string Data)
{
	local int i;

	i=InStr(Data, "\\worldlog\\");
	if(i >= 0 && Mid(Data, i+10, 4) ~= "true")
		bNGWorldStats = True;

	return Super.DecodeServerProperties(Data);
}

function UWindowList CopyExistingListItem(Class<UWindowList> ItemClass, UWindowList SourceItem)
{
	local UTBrowserServerList L;

	L = UTBrowserServerList(Super.CopyExistingListItem(ItemClass, SourceItem));
	L.bNGWorldStats	= UTBrowserServerList(SourceItem).bNGWorldStats;

	return L;
}
