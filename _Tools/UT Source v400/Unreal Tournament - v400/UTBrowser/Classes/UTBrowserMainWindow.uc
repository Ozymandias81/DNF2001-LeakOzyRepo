class UTBrowserMainWindow expands UBrowserMainWindow;

function BeginPlay()
{
	Super.BeginPlay();

	ClientClass = class'UTBrowserMainClientWindow';
}

defaultproperties
{
	WindowTitleString="Unreal Tournament Server Browser"
}