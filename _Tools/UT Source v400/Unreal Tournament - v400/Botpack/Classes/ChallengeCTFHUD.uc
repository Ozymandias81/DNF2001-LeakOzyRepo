//=============================================================================
// ChallengeCTFHUD.
//=============================================================================
class ChallengeCTFHUD extends ChallengeTeamHUD;

// Blue
#exec TEXTURE IMPORT NAME=I_Capt FILE=TEXTURES\HUD\I_Capt.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=I_Down FILE=TEXTURES\HUD\I_Down.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=I_Home FILE=TEXTURES\HUD\I_Home.PCX GROUP="Icons" FLAGS=2 MIPS=OFF

var CTFFlag MyFlag;

function Timer()
{
	Super.Timer();

	if ( (PlayerOwner == None) || (PawnOwner == None) )
		return;
	if ( PawnOwner.PlayerReplicationInfo.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 0 );
	if ( (MyFlag != None) && !MyFlag.bHome )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 1 );
}

simulated function PostRender( canvas Canvas )
{
	local int X, Y, i;
	local CTFFlag Flag;
	local bool bAlt;

	Super.PostRender( Canvas );		

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None)
		|| ((PlayerOwner.bShowMenu || PlayerOwner.bShowScores) && (Canvas.ClipX < 640)) )
		return;

	Canvas.Style = Style;
	if( !bHideHUD && !bHideTeamInfo )
	{
		X = Canvas.ClipX - 70 * Scale;
		Y = Canvas.ClipY - 350 * Scale;
			
		for ( i=0; i<4; i++ )
		{
			Flag = CTFReplicationInfo(PlayerOwner.GameReplicationInfo).FlagList[i];
			if ( Flag != None )
			{
				Canvas.DrawColor = TeamColor[Flag.Team];
				Canvas.SetPos(X,Y);

				if (Flag.Team == PawnOwner.PlayerReplicationInfo.Team)
					MyFlag = Flag;
				if ( Flag.bHome ) 
					Canvas.DrawIcon(texture'I_Home', Scale * 2);
				else if ( Flag.bHeld )
					Canvas.DrawIcon(texture'I_Capt', Scale * 2);
				else
					Canvas.DrawIcon(texture'I_Down', Scale * 2);
			}
			Y -= 150 * Scale;
		}
	}
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.DrawColor = TeamColor[TI.TeamIndex];
		DrawBigNum(Canvas, int(TI.Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * TI.TeamIndex), 1);
	}
}

defaultproperties
{
	bAlwaysHideFrags=false
	ServerInfoClass=class'ServerInfoCTF'
}

