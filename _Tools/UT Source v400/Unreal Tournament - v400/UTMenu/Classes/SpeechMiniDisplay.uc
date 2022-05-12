class SpeechMiniDisplay expands NotifyWindow;

var UTFadeTextArea DisplayArea;

var string ArrowString;
var localized string NameString;
var localized string OrdersString;
var localized string LocationString;
var localized string HumanString;

function Created()
{
	Super.Created();

	bAlwaysOnTop = True;
	bLeaveOnScreen = True;

	DisplayArea = UTFadeTextArea(CreateWindow(class'UTFadeTextArea', 100, 100, 100, 100));
	DisplayArea.MyFont = class'UTLadderStub'.Static.GetSmallFont(Root);
	DisplayArea.TextColor.R = 255;
	DisplayArea.TextColor.G = 255;
	DisplayArea.TextColor.B = 255;
	DisplayArea.FadeFactor = 6;
	DisplayArea.bMousePassThrough = True;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	DisplayArea.WinWidth = WinWidth;
	DisplayArea.WinHeight = WinHeight;
	DisplayArea.WinLeft = 0;
	DisplayArea.WinTop = 0;
}

function Reset()
{
	DisplayArea.Clear();
}

function FillInfo(int Index, string Callsign)
{
	local TournamentGameReplicationInfo TRI;
	local PlayerReplicationInfo PRI;
	local string LocationName;
	local int i;

	for (i=0; i<32; i++)
	{
		PRI = GetPlayerOwner().GameReplicationInfo.PRIArray[i];
		if (PRI != None)
		{
			if ( (PRI.TeamID == Index) && (PRI.Team == GetPlayerOwner().PlayerReplicationInfo.Team) )
			{
				DisplayArea.AddText(ArrowString@Callsign);

				if ( PRI.PlayerLocation != None )
					LocationName = PRI.PlayerLocation.LocationName;
				else if ( PRI.PlayerZone != None )
					LocationName = PRI.PlayerZone.ZoneName;
				else
					LocationName = "";
				if (LocationName != "")
					DisplayArea.AddText(LocationString@LocationName);

				TRI = TournamentGameReplicationInfo(GetPlayerOwner().GameReplicationInfo);
				if (TRI != None)
				{
					if ( PRI.IsA('BotReplicationInfo') )
						DisplayArea.AddText(OrdersString@TRI.GetOrderString(PRI));
					else
						DisplayArea.AddText(OrdersString@HumanString);
				}
			}
		}
	}
}

function bool CheckMousePassThrough(float X, float Y)
{
	return True;
}

defaultproperties
{
	ArrowString="<<<"
	NameString="Name:"
	LocationString="Location:"
	OrdersString="Orders:"
	HumanString="None <Human>"
}