class UMenuHelpMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Context, EpicURL, SupportURL, About;

var localized string ContextName;
var localized string ContextHelp;

var localized string EpicGamesURLName;
var localized string EpicGamesURLHelp;

var localized string SupportURLName;
var localized string SupportURLHelp;

var localized string AboutName;
var localized string AboutHelp;

function Created()
{
	Super.Created();

	Context = AddMenuItem(ContextName, None);
	AddMenuItem("-", None);
	SupportURL = AddMenuItem(SupportURLName, None);
	AddMenuItem("-", None);
	EpicURL = AddMenuItem(EpicGamesURLName, None);
	About = AddMenuItem(AboutName, None);
}

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	local UMenuMenuBar MenuBar;

	MenuBar = UMenuMenuBar(GetMenuBar());

	switch(I)
	{
	case Context:
		Context.bChecked = !Context.bChecked;
		MenuBar.ShowHelp = !MenuBar.ShowHelp;
		if (Context.bChecked)
		{
			if(UMenuRootWindow(Root) != None)
				if(UMenuRootWindow(Root).StatusBar != None)
					UMenuRootWindow(Root).StatusBar.ShowWindow();
		} else {
			if(UMenuRootWindow(Root) != None)
				if(UMenuRootWindow(Root).StatusBar != None)
					UMenuRootWindow(Root).StatusBar.HideWindow();
		}
		MenuBar.SaveConfig();
		break;
	case EpicURL:
		GetPlayerOwner().ConsoleCommand("start http://www.epicgames.com/");
		break;
	case SupportURL:
		GetPlayerOwner().ConsoleCommand("start http://www.gtgames.com/support");
		break;
	case About:
		if(class'GameInfo'.Default.DemoBuild == 1)
			Root.CreateWindow(class'UTCreditsWindow', 100, 100, 100, 100);
		else
		{
			GetPlayerOwner().ClientTravel( "UTCredits.unr", TRAVEL_Absolute, False );
			Root.Console.CloseUWindow();
		}
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch(I)
	{
	case Context:
		UMenuMenuBar(GetMenuBar()).SetHelp(ContextHelp);
		break;
	case EpicURL:
		UMenuMenuBar(GetMenuBar()).SetHelp(EpicGamesURLHelp);
		break;
	case SupportURL:
		UMenuMenuBar(GetMenuBar()).SetHelp(SupportURLHelp);
		break;
	case About:
		UMenuMenuBar(GetMenuBar()).SetHelp(AboutHelp);
		break;
	}

	Super.Select(I);
}


defaultproperties
{
	ContextName="&Context Help"
	ContextHelp="Enable and disable this context help area at the bottom of the screen."
	AboutName="&UT Credits"
	AboutHelp="Display credits."
	EpicGamesURLName="About &Epic Games"
	EpicGamesURLHelp="Click to open Epic Games webpage!"
	SupportURLName="Technical Support"
	SupportURLHelp="Click to open the technical support web page at GT Interactive."
}