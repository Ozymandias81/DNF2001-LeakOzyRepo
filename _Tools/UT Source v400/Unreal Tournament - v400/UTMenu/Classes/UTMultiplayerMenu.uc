class UTMultiplayerMenu expands UMenuMultiplayerMenu;

var config string OnlineServices[10];

var UWindowPulldownMenuItem OnlineServiceItems[10];
var string OnlineServiceCmdType[10];
var string OnlineServiceCmdAction[10];
var string OnlineServiceHelp[10];
var int OnlineServiceCount;

/* Examples:
 * [UTMenu.UTMultiplayerMenu]
 * OnlineServices[0]=Play online for FREE with mplayer.com!,Select this option to play online at mplayer!,CMD,mplayer
 * OnlineServices[1]=Go to the UT messageboard,Select this option to go to the UT messageboard,CMD,start http://www.unrealtournament.net/forum
 */


function string ParseOption(string Input, int Pos)
{
	local int i;

	while(True)
	{
		if(Pos == 0)
		{
			i = InStr(Input, ",");
			if(i != -1)
				Input = Left(Input, i);
			return Input;
		}

		i = InStr(Input, ",");
		if(i == -1)
			return "";

		Input = Mid(Input, i+1);
		Pos--;
	}
}

function Created()
{
	local int i;
	local string S;

	Super.Created();
	
	if(OnlineServices[0] != "")
		AddMenuItem("-", None);

	for(i=0;i<10;i++)
	{
		if(OnlineServices[i] == "")
			break;
	
		if(ParseOption(OnlineServices[i], 0) == "LOCALIZE")
			S = Localize("OnlineServices", ParseOption(OnlineServices[i], 1), "UTMenu");
		else
			S = OnlineServices[i];

		OnlineServiceItems[i] = AddMenuItem(ParseOption(S, 0), None);
		OnlineServiceHelp[i] = ParseOption(S, 1);
		OnlineServiceCmdType[i] = ParseOption(S, 2);
		OnlineServiceCmdAction[i] = ParseOption(S, 3);
	}

	OnlineServiceCount = i;
}

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	local int j;
	local string S;

	for(j=0;j<OnlineServiceCount;j++)
	{
		if(I == OnlineServiceItems[j])
		{
			switch(OnlineServiceCmdType[j])
			{
			case "URL":
				S = GetPlayerOwner().ConsoleCommand("start "$OnlineServiceCmdAction[j]);
				break;
			case "CMD":
				S = GetPlayerOwner().ConsoleCommand(OnlineServiceCmdAction[j]);
				if(S != "")
					MessageBox(OnlineServiceItems[j].Caption, S, MB_OK, MR_OK);
				break;
			case "CMDQUIT":
				S = GetPlayerOwner().ConsoleCommand(OnlineServiceCmdAction[j]);
				if(S != "")
					MessageBox(OnlineServiceItems[j].Caption, S, MB_OK, MR_OK);
				else
					GetPlayerOwner().ConsoleCommand("exit");
				break;
			}
		}
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	local int j;

	for(j=0;j<OnlineServiceCount;j++)
	{
		if(I == OnlineServiceItems[j])
		{
			UMenuMenuBar(GetMenuBar()).SetHelp(OnlineServiceHelp[j]);
		}
	}

	Super.Select(I);
}

defaultproperties
{
	StartGameClassName="UTMenu.UTStartGameWindow"
	UBrowserClassName="UTBrowser.UTBrowserMainWindow"
}
