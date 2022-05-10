/*-----------------------------------------------------------------------------
	dnDeathmatchGameHUD
-----------------------------------------------------------------------------*/
class dnDeathmatchGameHUD extends DukeHUD;

struct DMStat
{
	var localized string Name;
    var font             Font;
    var color            TextColor;
    var int              Icon;
    var string           Value;
};

// Death messages data struct
var struct DeathEvent
{
	var float		EventTime;
	var texture		Icon;
	var string      KillerName;
	var string      VictimName;
} DeathEvents[7];

var()   globalconfig int    MinPlayers;         // bots fill in to guarantee this level in net game 
var     float               MOTDFadeOutTime;
var     bool                bInitStats;
var     bool                bDebugDMHud;
var     DMStat              PlayerDMStats[8];
var     DMStat              GameDMStats[8];
var     localized string    TeamName[4];        
var()   color               TeamColor[4];
var     float               IdentifyFadeTime;
var     Pawn                IdentifyTarget;
var     localized string    IdentifyName;
var     localized string    IdentifyHealth;
var		int					HighScore;
var     int					Lead;
var     int					Rank;
var     int                 FragLimit;
var     int                 Score;
var     int					PlayerCount;
var     bool				bTiedScore;
var		Texture				LastKilledByIcon;
var		font				MyFont;

const numStats=8;

//============================================================================
//InitDMStats
//============================================================================
simulated function InitDMStats( Canvas C )
{
    local int i;

    for ( i=0; i<numStats; i++ )
    {
        PlayerDMStats[i].Font = MediumFont;
        GameDMStats[i].Font   = MediumFont;
    }
}

//============================================================================
//Tick
//============================================================================
simulated function Tick( float DeltaTime )
{
	local int i;

    Super.Tick( DeltaTime );

    IdentifyFadeTime -= DeltaTime;
	if (IdentifyFadeTime < 0.0)
		IdentifyFadeTime = 0.0;

	MOTDFadeOutTime -= DeltaTime * 35;
	if (MOTDFadeOutTime < 0.0)
		MOTDFadeOutTime = 0.0;

	for ( i=0; i<7; i++ )
	{
		if ( DeathEvents[i].EventTime > 0.0 )
		{
			DeathEvents[i].EventTime -= DeltaTime;			
			if ( DeathEvents[i].EventTime < 0.0 )
			{
				DeathEvents[i].EventTime	= 0.0;
				DeathEvents[i].Icon			= None;
			}
		}
	}
}

//============================================================================
//PostBeginPlay
//============================================================================
simulated function PostBeginPlay()
{
	MOTDFadeOutTime = 255;
	Super.PostBeginPlay();
}


//============================================================================
//UpdatePlayerDMStats
//Called every frame to update stats from the Player Replication Info
//============================================================================
simulated function UpdatePlayerDMStats()
{
    if ( PlayerOwner.PlayerReplicationInfo == None )
        return;

    PlayerDMStats[0].Value = PlayerOwner.PlayerReplicationInfo.PlayerName;    
    PlayerDMStats[1].Value = string(PlayerOwner.PlayerReplicationInfo.Score);
    PlayerDMStats[2].Value = string(PlayerOwner.PlayerReplicationInfo.Deaths);
}

//============================================================================
//TwoDigitString
//============================================================================
function string TwoDigitString(int Num)
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string(Num);
}

//============================================================================
//GetTime
//============================================================================
simulated function string GetTime( int ElapsedTime )
{
    local string String;
    local int Seconds, Minutes, Hours;

	Seconds = ElapsedTime;	
    Minutes = Seconds / 60;
	Hours   = Minutes / 60;
	Seconds = Seconds - (Minutes * 60);
	Minutes = Minutes - (Hours * 60);

	String = TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
    return String;
}

//============================================================================
//UpdateGameDMStats
//Called every frame to update stats from the Game Replication Info
//============================================================================
simulated function UpdateGameDMStats()
{
    local dnDeathmatchGameReplicationInfo GRI;

    if ( PlayerOwner.GameReplicationInfo == None )
        return;

    GRI = dnDeathmatchGameReplicationInfo( PlayerOwner.GameReplicationInfo );
    
    GameDMStats[0].Value = string( GRI.FragLimit );
    GameDMStats[1].Value = string( GRI.TimeLimit );
    GameDMStats[2].Value = GetTime( GRI.ElapsedTime );
    GameDMStats[3].Value = GetTime( GRI.RemainingTime );
	GameDMStats[4].Value = string( GRI.NumPlayers );
	GameDMStats[5].Value = string( GRI.NumSpectators );
}

//============================================================================
//DisplayProgressMessage
//============================================================================
simulated function DisplayProgressMessage( Canvas C )
{
	local int   i;
	local float YOffset, XL, YL;

	C.DrawColor    = TextColor;
	C.bCenter      = true;
	C.Font         = MyFont;
	
    YOffset = 0;
	C.StrLen("TEST", XL, YL);
	
    for ( i=0; i<8; i++ )
	{
		C.SetPos(0, 0.25 * C.ClipY + YOffset);
		C.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		C.DrawText( PlayerPawn(Owner).ProgressMessage[i], false );
		YOffset += YL + 5;
	}

	C.bCenter      = false;
	C.DrawColor.R  = 255;
	C.DrawColor.G  = 255;
	C.DrawColor.B  = 255;
}

//============================================================================
//PostRender
//============================================================================
simulated function PostRender( Canvas C )
{
    Super.PostRender( C );

	HUDSetup( C );

    if ( !bInitStats )
	{
		InitDMStats( C );
		bInitStats = true;
	}

    UpdatePlayerDMStats();
    UpdateGameDMStats();

    if ( PlayerOwner != None )
    {
        // Stats
		if ( bDebugDMHud )
		{
	        DrawPlayerDMStats( C );
		    DrawGameDMStats( C );
		}

        // Progress Messages
        if ( PlayerOwner.ProgressTimeOut > Level.TimeSeconds )
    		DisplayProgressMessage( C );
    }

    // Display Player Identification Info
	if ( !bIsSpectator && PlayerOwner.Health > 0 )
		DrawIdentifyInfo( C, 0, C.ClipY - 64.0 );

	// Message of the Day / Map Info Header
	if ( MOTDFadeOutTime != 0.0 )
	    DrawMOTD( C );

	DrawDeathEvents( C );

    C.DrawColor = WhiteColor;
}

//============================================================================
//DrawPlayerIcon
//============================================================================
function DrawPlayerIcon( Canvas C )
{
	local int i;

	for ( i=0; i<4; i++ )
	{
		if ( MessageQueue[i].Message != None )
		{
			break;
		}
	}

	if ( i == 4 )
		return;

	if ( MessageQueue[i].RelatedPRI.Icon == None )
		return;

	C.DrawColor = WhiteColor;
	C.Style = ERenderStyle.STY_Normal;

	// Draw the Player's Face Icon Texture
	C.SetPos( 6 * HudScaleX, 0 );
	C.DrawTile( MessageQueue[i].RelatedPRI.Icon, 
				IconSize * HUDScaleX, IconSize * HUDScaleY,
				0, 0, 
				MessageQueue[i].RelatedPRI.Icon.USize, MessageQueue[i].RelatedPRI.Icon.VSize );
}

//============================================================================
//DrawDMStats
//============================================================================
simulated function DrawDMStats( Canvas C, float XPos, float YPos, DMStat stats[8], optional float extraSpace )
{
    local string Text;
    local int i;
    local float XL, YL;

	C.DrawColor = TextColor;	

	// Header
	C.SetPos( XPos, YPos );
	for ( i=0; i<numStats; i++ )
	{
		Text  = Text $ stats[i].Name $ "     ";
	}
	C.DrawText( Text, false );
    C.TextSize( Text, XL, YL );
    YPos += YL + extraSpace;

    for ( i=0; i<numStats; i++ )
    {
        if ( stats[i].Name == "" )
            continue;

        Text   = stats[i].Value;
        C.Font = stats[i].Font;

        C.SetPos( XPos, YPos );
        C.DrawText( Text, false );
        C.TextSize( Text, XL, YL );
        YPos += YL + extraSpace;
    }
}

//============================================================================
//CalcDMStatsDimensions
//============================================================================
simulated function CalcDMStatsDimensions( Canvas C, out float width, out float height, DMStat stats[8], optional float extraSpace )
{
    local string Text;
    local int i;
    local float XL, YL;

    for ( i=0; i<numStats; i++ )
    {
        if ( stats[i].Name == "" )
            continue;

        Text = stats[i].Name$" : "$stats[i].Value;
        C.TextSize( Text, XL, YL );
        height += YL + extraSpace;
        if ( XL > width )
            width = XL;
    }
}

//============================================================================
//DrawPlayerDMStats
//============================================================================
simulated function DrawPlayerDMStats( Canvas C )
{
    local int       i;
    local float     YPos,XPos;
    
    // Calculate stats block width/height;
    CalcDMStatsDimensions( C, XPos, YPos, PlayerDMStats, 5 );

    YPos = C.ClipY - YPos;
    XPos = C.ClipX - XPos;
    XPos -= 15;
    YPos -= 10;
    
    DrawDMStats( C, XPos, YPos, PlayerDMStats, 5 );
}


//============================================================================
//DrawGameDMStats
//============================================================================
simulated function DrawGameDMStats( Canvas C )
{
    local int       i;
    local float     YPos,XPos;
    
    // Calculate stats block width/height;
    CalcDMStatsDimensions( C, XPos, YPos, GameDMStats, 5 );
    
    YPos = 15;
    XPos = C.ClipX - XPos;
    XPos -= 15;
    
    DrawDMStats( C, XPos, YPos, GameDMStats, 5 );
}

//============================================================================
//TraceIdentify
//============================================================================
simulated function bool TraceIdentify( Canvas C )
{
	local actor Other;
	local vector HitLocation, HitNormal, X, Y, Z, StartTrace, EndTrace;

	StartTrace = Owner.Location;
	StartTrace.Z += Pawn(Owner).BaseEyeHeight;

	EndTrace = StartTrace + vector(Pawn(Owner).ViewRotation) * 1000.0;

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( (Pawn(Other) != None) && (Pawn(Other).bIsPlayer) )
	{
		IdentifyTarget = Pawn(Other);
		IdentifyFadeTime = 3.0;
	}

	if ( IdentifyFadeTime == 0.0 )
		return false;

	if ( (IdentifyTarget == None) || (!IdentifyTarget.bIsPlayer) ||
		 (IdentifyTarget.bHidden) || (IdentifyTarget.PlayerReplicationInfo == None ))
		return false;

	return true;
}

//============================================================================
//DrawIdentifyInfo
//============================================================================
simulated function DrawIdentifyInfo( Canvas C, float PosX, float PosY )
{
	local float XL, YL, XOffset;
	local string N;
	local Color DrawColor;

	if ( !TraceIdentify( C ) )
		return;

	C.Font		= MyFont;
	C.Style		= ERenderStyle.STY_Translucent;
	DrawColor	= WhiteColor;
	XOffset		= 0.0;
	
	N = IdentifyTarget.PlayerReplicationInfo.PlayerName;
	
	if ( PlayerPawn(Owner).GameReplicationInfo != None )
	{
		if ( PlayerPawn(Owner).GameReplicationInfo.bTeamGame )
		{
			DrawColor = TeamColor[IdentifyTarget.PlayerReplicationInfo.Team];
		}
	}
	
	C.StrLen( N, XL, YL );
	XOffset = C.ClipX/2 - XL/2;
	C.SetPos( XOffset, ( C.ClipY / 2 ) - 50 );
	
	if ( N != "" )
	{		
		C.DrawColor.R = DrawColor.R * ( IdentifyFadeTime / 3.0 );
		C.DrawColor.G = DrawColor.G * ( IdentifyFadeTime / 3.0 );
		C.DrawColor.B = DrawColor.B * ( IdentifyFadeTime / 3.0 );

		C.DrawText( N );
	}

	C.Style = 1;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

//============================================================================
//DrawMOTD
//============================================================================
simulated function DrawMOTD( Canvas C )
{
	local GameReplicationInfo   GRI;
	local float                 XL, YL;

	if ( Owner == None ) 
        return;

	C.Font         = MyFont;
	C.Style        = 3;
	C.DrawColor.R  = MOTDFadeOutTime;
	C.DrawColor.G  = MOTDFadeOutTime;
	C.DrawColor.B  = MOTDFadeOutTime;
	C.bCenter      = true;

	foreach AllActors( class'GameReplicationInfo', GRI )
	{
		if ( GRI.GameName != "Game" )
		{
			C.DrawColor.R = 0;
			C.DrawColor.G = MOTDFadeOutTime / 2;
			C.DrawColor.B = MOTDFadeOutTime;
			C.SetPos( 0.0, 32 );
			C.StrLen( "TEST", XL, YL );
            YL += 5;

			if ( Level.NetMode != NM_Standalone )
				C.DrawText( GRI.ServerName );
			
            C.DrawColor.R = MOTDFadeOutTime;
			C.DrawColor.G = MOTDFadeOutTime;
			C.DrawColor.B = MOTDFadeOutTime;

			C.SetPos( 0.0, 32 + YL );
			C.DrawText( "Game Type: "$GRI.GameName, true );
			C.SetPos(0.0, 32 + 2*YL);
			C.DrawText( "Map Title: "$Level.Title, true );
			C.SetPos( 0.0, 32 + 3*YL );
			C.DrawText( "Author: "$Level.Author, true );
			C.SetPos( 0.0, 32 + 4*YL );
			if ( Level.IdealPlayerCount != "" )
				C.DrawText( "Ideal Player Load:"$Level.IdealPlayerCount, true );

			C.DrawColor.R = 0;
			C.DrawColor.G = MOTDFadeOutTime / 2;
			C.DrawColor.B = MOTDFadeOutTime;

			C.SetPos( 0, 32 + 6*YL );
			C.DrawText( Level.LevelEnterText, true );

			C.SetPos( 0.0, 32 + 8*YL );
			C.DrawText( GRI.MOTDLine1, true );
			C.SetPos( 0.0, 32 + 9*YL );
			C.DrawText( GRI.MOTDLine2, true );
			C.SetPos( 0.0, 32 + 10*YL );
			C.DrawText( GRI.MOTDLine3, true );
			C.SetPos( 0.0, 32 + 11*YL );
			C.DrawText( GRI.MOTDLine4, true );
		}
	}

	C.bCenter      = false;
	C.Style        = 1;
	C.DrawColor.R  = 255;
	C.DrawColor.G  = 255;
	C.DrawColor.B  = 255;
}

/*-----------------------------------------------------------------------------
	Display death messages.
-----------------------------------------------------------------------------*/

//============================================================================
//CopyDeathEvent
//============================================================================
function CopyDeathEvent(out DeathEvent E1, DeathEvent E2)
{
	E1.EventTime  = E2.EventTime;
	E1.Icon       = E2.Icon;
	E1.KillerName = E2.KillerName;
	E1.VictimName = E2.VictimName;
}

//============================================================================
//AddDeathEvent
//============================================================================
simulated function AddDeathEvent( PlayerReplicationInfo KillerPRI, 
								  PlayerReplicationInfo VictimPRI,
								  class<Actor> DT
								)
{
	local int i;

	// Move everything up and add us to the start.
	for ( i=6; i>0; i-- )
	{
		CopyDeathEvent( DeathEvents[i], DeathEvents[i-1] );
	}	

	DeathEvents[0].EventTime     = 5.0;	
	DeathEvents[0].Icon          = Class<DamageType>(DT).Default.Icon;

	if ( KillerPRI != None )
		DeathEvents[0].KillerName    = KillerPRI.PlayerName;
	else
		DeathEvents[0].KillerName    = "";

	if ( VictimPRI != None )
		DeathEvents[0].VictimName    = VictimPRI.PlayerName;
	else
		DeathEvents[0].VictimName    = "";	
}

//============================================================================
//DrawDeathEvents
//============================================================================
simulated function DrawDeathEvents(Canvas C)
{
	local int	i;
	local float XL, YL, XOffset, YOffset, TexWidth, TexHeight;

	C.DrawColor = HUDColor;
	C.Style     = 3;
	C.Font      = MyFont;

	for ( i=0; i<7; i++ )
	{
		if ( DeathEvents[i].Icon != None )
		{
			if ( Style == 3 )
			{
				C.DrawColor.R = HUDColor.R * (DeathEvents[i].EventTime / 5.0);
				C.DrawColor.G = HUDColor.G * (DeathEvents[i].EventTime / 5.0);
				C.DrawColor.B = HUDColor.B * (DeathEvents[i].EventTime / 5.0);
			}

			XOffset   = 10 * HUDScaleX;
			YOffset   = int( C.ClipY - 8 * HUDScaleY - ( 70 * HUDScaleY * ( i+3 ) ) ) + 0.5;
			TexWidth  = DeathEvents[i].Icon.USize * HudScaleY;
			TexHeight = DeathEvents[i].Icon.VSize * HudScaleY;

			// Draw Killer
			if ( DeathEvents[i].KillerName != "" )
				C.StrLen( DeathEvents[i].KillerName, XL, YL );

			C.SetPos( XOffset, YOffset + ( TexHeight / 2 ) + ( YL / 2 ) );
			
			if ( DeathEvents[i].KillerName != "" )
				C.DrawText( DeathEvents[i].KillerName, false );
			
			// Draw Icon
			XOffset += XL + 10;
			C.SetPos( XOffset, YOffset );
			C.DrawIcon( DeathEvents[i].Icon, HUDScaleY );

			// Draw Victim
			XOffset += TexWidth + 10;
			C.SetPos( XOffset, YOffset + ( TexHeight / 2 ) + ( YL / 2 ) );
			
			if ( DeathEvents[i].VictimName != "" )
				C.DrawText( DeathEvents[i].VictimName, false );
		}
	}
	C.DrawColor = WhiteColor;
	C.Style     = 1;
}

//============================================================================
//DebugDMHud
//============================================================================
exec function DebugDMHUD()
{
	bDebugDMHud = !bDebugDMHud;
}


//============================================================================
//FirstDraw
//============================================================================
simulated function FirstDraw(canvas C)
{
	Super.FirstDraw( C );

	IndexItems[11] = spawn(class'HUDIndexItem_DMFrags');
}

//============================================================================
//UpdateRankAndSpread
//============================================================================
function UpdateRankAndSpread()
{
	local PlayerReplicationInfo PRI;	
	local int					i, j;

	PlayerCount = 0;
	HighScore	= -100;
	bTiedScore	= false;
	Rank		= 1;

	if ( PlayerOwner.GameReplicationInfo == None )
		return;
	if ( PlayerOwner.PlayerReplicationInfo == None )
		return;

	for ( i=0; i<32; i++ )
	{
		PRI = PlayerOwner.GameReplicationInfo.PRIArray[i];
		if ( (PRI != None) && ( !PRI.bIsSpectator || PRI.bWaitingPlayer ) )
		{
			PlayerCount++;
			if ( PRI != PlayerOwner.PlayerReplicationInfo )
			{
				if ( PRI.Score > PlayerOwner.PlayerReplicationInfo.Score )
					Rank += 1;
				else if ( PRI.Score == PlayerOwner.PlayerReplicationInfo.Score )
				{
					bTiedScore = true;
					if ( PRI.Deaths < PlayerOwner.PlayerReplicationInfo.Deaths )
						Rank += 1;
					else if ( PRI.Deaths == PlayerOwner.PlayerReplicationInfo.Deaths )
						if ( PRI.PlayerID < PlayerOwner.PlayerReplicationInfo.PlayerID )
							Rank += 1;
				}
				if ( PRI.Score > HighScore )
					HighScore = PRI.Score;
			}
		}
	}

	FragLimit = dnDeathMatchGameReplicationInfo( PlayerOwner.GameReplicationInfo ).FragLimit;
	Score     = int(PlayerOwner.PlayerReplicationInfo.Score);

	Lead = 0;
	if ( PlayerCount > 1 )
		Lead = Score - HighScore;
}

//============================================================================
//Timer
//============================================================================
simulated function Timer(optional int TimerNum)
{
	Super.Timer( TimerNum );
	UpdateRankAndSpread();
}

defaultproperties
{
    TeamName(0)="Humans: "
    TeamName(1)="Bugs: "
    TeamColor(0)=(R=255,G=0,B=0)
    TeamColor(1)=(R=0,G=0,B=255)
    PlayerDMStats(0)=(Name="PlayerName")
    PlayerDMStats(1)=(Name="Frags")
    PlayerDMStats(2)=(Name="Deaths")
    GameDMStats(0)=(Name="FragLimit")
    GameDMStats(1)=(Name="TimeLimit")
    GameDMStats(2)=(Name="Elapsed Time")
    GameDMStats(3)=(Name="Time Remaining")
	GameDMStats(4)=(Name="Num Players")
	GameDMStats(5)=(Name="Num Spectators")
    IdentifyName="Name"
    IdentifyHealth="Health"
	bDrawPlayerIcons=true
	MyFont=font'MainMenuFont'
}
