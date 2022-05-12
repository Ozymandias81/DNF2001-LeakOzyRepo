class UMenuToolsMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Console, TimeDemo, ShowLog;

var localized string ConsoleName;
var localized string ConsoleHelp;
var localized string TimeDemoName;
var localized string TimeDemoHelp;
var localized string LogName;
var localized string LogHelp;

function Created()
{
	Super.Created();

	// Add menu items.
	Console = AddMenuItem(ConsoleName, None);
	Console.bChecked = Root.Console.bShowConsole;
	TimeDemo = AddMenuItem(TimeDemoName, None);
	TimeDemo.bChecked = Root.Console.bTimeDemo;
	ShowLog = AddMenuItem(LogName, None);
}

function ShowWindow()
{
	Super.ShowWindow();

	Console.bChecked = Root.Console.bShowConsole;
}

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	switch(I)
	{
	case Console:
		Console.bChecked = !Console.bChecked;
		if (Console.bChecked)
			Root.Console.ShowConsole();
		else
			Root.Console.HideConsole();
		break;
	case TimeDemo:
		TimeDemo.bChecked = !TimeDemo.bChecked;
		GetPlayerOwner().ConsoleCommand("TIMEDEMO "$TimeDemo.bChecked);
		break;
	case ShowLog:
		GetPlayerOwner().ConsoleCommand("SHOWLOG");
		break;
	}

	Super.ExecuteItem(I);
}


function Select(UWindowPulldownMenuItem I)
{
	switch(I)
	{
	case Console:
		UMenuMenuBar(GetMenuBar()).SetHelp(ConsoleHelp);
		break;
	case TimeDemo:
		UMenuMenuBar(GetMenuBar()).SetHelp(TimeDemoHelp);
		break;
	case ShowLog:
		UMenuMenuBar(GetMenuBar()).SetHelp(LogHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
	ConsoleName="System &Console"
	ConsoleHelp="This option brings up the Unreal Console.  You can use the console to enter advanced commands and cheats."
	TimeDemoName="T&imeDemo Statistics"
	TimeDemoHelp="Enable the TimeDemo statistic to measure your frame rate."
	LogName="Show &Log"
	LogHelp="Show the Unreal log window."
}