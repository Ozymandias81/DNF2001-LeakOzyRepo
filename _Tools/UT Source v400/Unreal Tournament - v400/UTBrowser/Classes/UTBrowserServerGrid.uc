class UTBrowserServerGrid expands UBrowserServerGrid;

var UWindowGridColumn ngStats;
var localized string ngStatsName;
var localized string EnabledText;
var UBrowserServerList ConnectToServer;
var bool bWaitingForNgStats;

var UWindowMessageBox AskNgStats;
var localized string AskNgStatsTitle;
var localized string AskNgStatsText;

function CreateColumns()
{
	Super.CreateColumns();

	ngStats	= AddColumn(ngStatsName, 80);
}


function DrawCell(Canvas C, float X, float Y, UWindowGridColumn Column, UBrowserServerList List)
{
	switch(Column)
	{
	case ngStats:
		if(UTBrowserServerList(List).bNGWorldStats)
			Column.ClipText( C, X, Y, EnabledText );
		break;
	default:
		Super.DrawCell(C, X, Y, Column, List);
		break;
	}
}

function int Compare(UBrowserServerList T, UBrowserServerList B)
{
	switch(SortByColumn)
	{
	case ngStats:
		if(UTBrowserServerList(T).bNGWorldStats == UTBrowserServerList(B).bNGWorldStats)	
			return ByName(T, B);

		if(UTBrowserServerList(T).bNGWorldStats)
		{
			if(bSortDescending)
				return 1;
			else
				return -1;
		}
		else
		{
			if(bSortDescending)
				return -1;
			else
				return 1;
		}

		break;
	default:
		return Super.Compare(T, B);
		break;
	}
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == AskNgStats)
	{
		AskNgStats = None;
		if(Result == MR_Cancel)
			return;
		else
		if(Result == MR_Yes)
		{
			ShowModal(Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTMenu.ngWorldSecretWindow", class'Class')), 100, 100, 200, 200, Root, True));
			bWaitingForNgStats = True;
		}
		else
		{
			GetPlayerOwner().ngSecretSet = True;
			GetPlayerOwner().SaveConfig();
			ReallyJoinServer(ConnectToServer);
		}
	}
}

function JoinServer(UBrowserServerList Server)
{
	if(Server != None && Server.GamePort != 0) 
	{
		if(!GetPlayerOwner().ngSecretSet && UTBrowserServerList(Server).bNGWorldStats)
		{
			ConnectToServer = Server;
			AskNgStats = MessageBox(AskNgStatsTitle, AskNgStatsText, MB_YesNoCancel, MR_Yes);
		}
		else
			ReallyJoinServer(Server);
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	if(bWaitingForNgStats && !WaitModal())
	{
		ReallyJoinServer(ConnectToServer);
		bWaitingForNgStats = False;
	}
}

function ReallyJoinServer(UBrowserServerList Server)
{
	GetPlayerOwner().ClientTravel("unreal://"$Server.IP$":"$Server.GamePort$UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow')).URLAppend, TRAVEL_Absolute, false);
	GetParent(class'UWindowFramedWindow').Close();
	Root.Console.CloseUWindow();
}

defaultproperties
{
	ngStatsName="ngWorldStats"
	EnabledText="Enabled"
	AskNgStatsTitle="Use ngWorldStats?"
	AskNgStatsText="This server has stat accumulation enabled. Your ngWorldStats password has not been set. If you set a new ngWorldStats password, you can record all of your gameplay stats (Kills, Suicides, etc) online! If you do not set a password you will opt out of stat accumulation.\\n\\nDo you want to set an ngWorldStats password?"
}