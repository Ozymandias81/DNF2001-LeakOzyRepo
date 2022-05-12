class UMenuModMenu expands UWindowPulldownMenu;

var UMenuModMenuItem ModItems;

function SetupMods(UMenuModMenuItem InModItems)
{
	local UMenuModMenuItem I;
	ModItems = InModItems;

	for(I = UMenuModMenuItem(ModItems.Next); I != None; I = UMenuModMenuItem(I.Next))
	{
		I.MenuItem = AddMenuItem(I.MenuCaption, None);
		I.Setup();
	}
}

function Select(UWindowPulldownMenuItem I)
{
	local UMenuModMenuItem L;

	for(L = UMenuModMenuItem(ModItems.Next); L != None; L = UMenuModMenuItem(L.Next))
		if(I == L.MenuItem)
			UMenuMenuBar(GetMenuBar()).SetHelp(L.MenuHelp);

	Super.Select(I);
}

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	local UMenuModMenuItem L;

	for(L = UMenuModMenuItem(ModItems.Next); L != None; L = UMenuModMenuItem(L.Next))
		if(I == L.MenuItem)
			L.Execute();

	Super.ExecuteItem(I);
}