class UMenuStartGameClientWindow extends UMenuBotmatchClientWindow;

// Window
var UWindowSmallButton DedicatedButton;
var localized string DedicatedText;
var localized string DedicatedHelp;
var localized string ServerText;

var UWindowPageControlPage ServerTab;

function Created()
{
	Super.Created();

	// Dedicated
	DedicatedButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-156, WinHeight-24, 48, 16));
	DedicatedButton.SetText(DedicatedText);
	DedicatedButton.SetHelpText(DedicatedHelp);

	ServerTab = Pages.AddPage(ServerText, class'UMenuServerSetupSC');
}

function Resized()
{
	Super.Resized();
	DedicatedButton.WinLeft = WinWidth-152;
	DedicatedButton.WinTop = WinHeight-20;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case DedicatedButton:
				DedicatedPressed();
				return;
			default:
				Super.Notify(C, E);
				return;
		}
	default:
		Super.Notify(C, E);
		return;
	}
}

function DedicatedPressed()
{
	local string URL;
	local GameInfo NewGame;
	local string LanPlay;

	if(UMenuServerSetupPage(UMenuServerSetupSC(ServerTab.Page).ClientArea).bLanPlay)
		LanPlay = " -lanplay";

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;
	URL = URL $ "?Listen";

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ConsoleCommand("RELAUNCH "$URL$LanPlay$" -server log="$GameClass.Default.ServerLogName);
}

// Override botmatch's start behavior
function StartPressed()
{
	local string URL, Checksum;
	local GameInfo NewGame;

	// Reset the game class.
	GameClass.Static.ResetGame();

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;
	URL = URL $ "?Listen";
	class'StatLog'.Static.GetPlayerChecksum(GetPlayerOwner(), Checksum);
	if (Checksum == "")
		URL = URL $ "?Checksum=NoChecksum";
	else
		URL = URL $ "?Checksum="$Checksum;

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

defaultproperties
{
	StartText="Start"
	DedicatedText="Dedicated"
	DedicatedHelp="Press to launch a dedicated server."
	ServerText="Server"
	bNetworkGame=True
}