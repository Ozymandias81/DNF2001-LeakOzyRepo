//=============================================================================
// dnDeathmatchGameScoreBoard
//=============================================================================
class dnDeathmatchGameScoreBoard extends ScoreBoard;

var				font					MyFont;
var				bool					bInitFonts;
var				PlayerReplicationInfo	Ordered[32];
var				localized string		MapTitle;
var				localized string		Author;
var				localized string		Restart;
var				localized string		Continue;
var				localized string		Ended;
var				localized string		ElapsedTime;
var				localized string		RemainingTime;
var				localized string		FragGoal;
var				localized string		TimeLimit;
var				localized string		PlayerString;
var				localized string		FragsString;
var				localized string		DeathsString;
var				localized string		PingString;
var				localized string		TimeString;
var				localized string		LossString;
var				localized string		FPHString;
var				float					ScoreStart;	// top allowed score start
var				bool					bTimeDown;
var				float					LargeFontScaleX;
var				float					LargeFontScaleY;
var				float					MediumFontScaleX;
var				float					MediumFontScaleY;
var				float					SmallFontScaleX;
var				float					SmallFontScaleY;
var				float					FontScaleX;
var				float					FontScaleY;
var             string					LastKilledByMessage;
var				Texture					LastKilledByIcon;
var				string					ScoreboardWindowType;

var enum EFontSize
{
	FS_Large,
	FS_Medium,
	FS_Small,
	FS_VerySmall,
} FontSize;

var color WhiteColor, RedColor, LightGreenColor, DarkGreenColor, 
		  GreenColor, CyanColor, BlueColor, GoldColor, PurpleColor, 
		  TurqColor, GrayColor, LightBlueColor, DarkBlueColor,
		  BlackColor, OrangeColor;


//=============================================================================
//CreateScoreboardWindow
//=============================================================================
function CreateScoreboardWindow( Canvas C )
{
	PlayerPawn(Owner).Player.Console.CreateScoreboard( ScoreboardWindowType, C );
}

//=============================================================================
//SetTextFont
//=============================================================================
function SetFontSize( Canvas C, EFontSize newSize )
{
	C.Font = MyFont;	

	switch ( newSize )
	{
		case FS_Large:
			FontScaleX = 1.5;
			FontScaleY = 1.5;
			break;
		case FS_Medium:
			FontScaleX = 1.0;
			FontScaleY = 1.0;
			break;
		case FS_Small:
			C.Font = C.SmallFont;
			FontScaleX = 1.0;
			FontScaleY = 1.0;
			break;
		case FS_VerySmall:
			FontScaleX = 0.5;
			FontScaleY = 0.5;
			break;
		default:
			break;
	}
}

//=============================================================================
//DrawHeader
//=============================================================================
function DrawHeader( canvas C )
{
	local GameReplicationInfo	GRI;
	local float					XL, YL;
	local font					CanvasFont;

	C.DrawColor	= WhiteColor;
	GRI			= PlayerPawn(Owner).GameReplicationInfo;		
	ScoreStart	= 58.0 / 768.0 * C.ClipY;
	C.bCenter	= true;

	SetFontSize( C, FS_Medium );
	C.TextSize( "Test", XL, YL, FontScaleX, FontScaleY );

	if ( GRI.GameEndedComments != "" )
	{
		C.DrawColor = GoldColor;
		C.SetPos( 0, ScoreStart );
		C.DrawText( GRI.GameEndedComments, true,,,FontScaleX, FontScaleY );
	}
	else
	{
		C.SetPos( 0, ScoreStart );
		DrawVictoryConditions( C );
	}

	C.bCenter	= false;
	C.Font		= CanvasFont;
}

//=============================================================================
//DrawVictoryConditions
//=============================================================================
function DrawVictoryConditions( Canvas C )
{
	local dnDeathmatchGameReplicationInfo GRI;
	local float XL, YL;

	GRI = dnDeathmatchGameReplicationInfo( PlayerPawn( Owner ).GameReplicationInfo );
	
	if ( GRI == None )
		return;

	SetFontSize( C, FS_Medium );
	C.DrawColor	= WhiteColor;
	C.DrawText( GRI.GameName,,,,FontScaleX, FontScaleY );
	C.TextSize( "Test", XL, YL, FontScaleX, FontScaleY );

	C.SetPos( 0, C.CurY - YL + 8 );

	if ( LastKilledByMessage != "" )
	{
		C.DrawColor	= RedColor;
		C.DrawText( LastKilledByMessage,,,,FontScaleX, FontScaleY );
		C.SetPos( 0, C.CurY - YL );
		C.DrawColor	= WhiteColor;
	}

	if ( GRI.FragLimit > 0 )
	{
		C.DrawText( FragGoal @ GRI.FragLimit,,,,FontScaleX, FontScaleY );
		C.TextSize( "Test", XL, YL, FontScaleX, FontScaleY );
		C.SetPos( 0, C.CurY - YL );			
	}

	if ( GRI.TimeLimit > 0 )
	{
		C.DrawText( TimeLimit @ GRI.TimeLimit$":00",,,,FontScaleX, FontScaleY );
	}

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

//=============================================================================
//DrawTrailer
//=============================================================================
function DrawTrailer( canvas C )
{
	local int Hours, Minutes, Seconds;
	local float XL, YL;
	local PlayerPawn PlayerOwner;

	C.bCenter = true;
	C.StrLen("Test", XL, YL);
	C.DrawColor = WhiteColor;

	PlayerOwner = PlayerPawn( Owner );
	
	C.SetPos( 0, C.ClipY - 2 * YL );
	C.DrawText( PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title, true );
	C.SetPos( 0, C.ClipY - YL );
	
	if ( bTimeDown || ( PlayerOwner.GameReplicationInfo.RemainingTime > 0 ) )
	{
		bTimeDown = true;
		if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
			C.DrawText( RemainingTime@"00:00", true,,,FontScaleX, FontScaleY );
		else
		{
			Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
			Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
			C.DrawText(RemainingTime@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true,,,FontScaleX, FontScaleY);
		}
	}
	else
	{
		Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		C.DrawText(ElapsedTime@TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true,,,FontScaleX, FontScaleY);
	}

	if ( PlayerOwner.GameReplicationInfo.GameEndedComments != "" )
	{
		C.bCenter = true;
		C.StrLen("Test", XL, YL);
		C.SetPos(0, C.ClipY - Min(YL*6, C.ClipY * 0.1));
		C.DrawColor = GreenColor;
		if ( Level.NetMode == NM_Standalone )
			C.DrawText(Ended@Continue, true,,,FontScaleX, FontScaleY);
		else
			C.DrawText(Ended, true,,,FontScaleX, FontScaleY);
	}
	else if ( (PlayerOwner != None) && (PlayerOwner.Health <= 0) )
	{
		C.bCenter = true;
		C.StrLen("Test", XL, YL);
		C.SetPos(0, C.ClipY - Min(YL*6, C.ClipY * 0.1));
		C.DrawColor = GreenColor;
		C.DrawText( Restart, true,,,FontScaleX, FontScaleY );
	}
	C.bCenter = false;
}


//=============================================================================
//DrawCategoryHeaders
//=============================================================================
function DrawCategoryHeaders(Canvas C)
{
	local float Offset, XL, YL;

	SetFontSize( C, FS_Medium );

	Offset		= C.CurY;
	C.DrawColor	= WhiteColor;
	
	C.TextSize( PlayerString, XL, YL, FontScaleX, FontScaleY );
	C.SetPos( ( C.ClipX / 8) * 2 - XL/2, Offset );
	C.DrawText( PlayerString,,,,FontScaleX, FontScaleY );

	C.TextSize( FragsString, XL, YL, FontScaleX, FontScaleY );
	C.SetPos( ( C.ClipX / 8 ) * 5 - XL/2, Offset );
	C.DrawText( FragsString,,,,FontScaleX, FontScaleY );	

	C.TextSize( DeathsString, XL, YL, FontScaleX, FontScaleY );
	C.SetPos( ( C.ClipX / 8 ) * 6 - XL/2, Offset );
	C.DrawText( DeathsString,,,,FontScaleX, FontScaleY );
}

//=============================================================================
//SortScores
//=============================================================================
function SortScores(int N)
{
	local int I, J, Max;
	local PlayerReplicationInfo TempPRI;
	
	for ( I=0; I<N-1; I++ )
	{
		Max = I;
		for ( J=I+1; J<N; J++ )
		{
			if ( Ordered[J].Score > Ordered[Max].Score )
				Max = J;
			else if ((Ordered[J].Score == Ordered[Max].Score) && (Ordered[J].Deaths < Ordered[Max].Deaths))
				Max = J;
			else if ((Ordered[J].Score == Ordered[Max].Score) && (Ordered[J].Deaths == Ordered[Max].Deaths) &&
					 (Ordered[J].PlayerID < Ordered[Max].Score))
				Max = J;
		}

		TempPRI = Ordered[Max];
		Ordered[Max] = Ordered[I];
		Ordered[I] = TempPRI;
	}
}

//=============================================================================
//InitFonts
//=============================================================================
function InitFonts( canvas C )
{
	/*
	VerySmallFont	= DukeHUD(DukePlayer(Owner).MyHUD).VerySmallFont;
    SmallFont		= DukeHUD(DukePlayer(Owner).MyHUD).SmallFont;
    MediumFont		= DukeHUD(DukePlayer(Owner).MyHUD).MediumFont;
    LargeFont		= DukeHUD(DukePlayer(Owner).MyHUD).LargeFont;
	HugeFont		= DukeHUD(DukePlayer(Owner).MyHUD).HugeFont;
	*/
	MyFont			= font'MainMenuFont';	
}

//=============================================================================
//DrawNameAndPing
//=============================================================================
function DrawNameAndPing( Canvas C, PlayerReplicationInfo PRI, float XOffset, float YOffset )
{
	local float			XL, YL, XL2, YL2, XL3, YL3;
	local Font			CanvasFont;
	local bool			bLocalPlayer;
	local PlayerPawn	PlayerOwner;
	local int			Time;

	SetFontSize( C, FS_Medium );

	PlayerOwner = PlayerPawn(Owner);
	bLocalPlayer = ( PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName );

	// Draw Name
	if ( bLocalPlayer )
		C.DrawColor = GoldColor;
	else 
		C.DrawColor = CyanColor;

	C.SetPos( C.ClipX * 0.1875, YOffset );
	C.DrawText( PRI.PlayerName,,,,FontScaleX, FontScaleY );

	C.TextSize( "0000", XL, YL, FontScaleX, FontScaleY );

	// Draw Score
	if ( !bLocalPlayer )
		C.DrawColor = LightGreenColor;
	
	C.TextSize( int(PRI.Score), XL2, YL, FontScaleX, FontScaleY );
	C.SetPos( C.ClipX * 0.625 + XL * 0.5 - XL2, YOffset );
	C.DrawText( int( PRI.Score ),false,,,FontScaleX, FontScaleY );

	// Draw Deaths	
	C.TextSize( PRI.Deaths, XL2, YL, FontScaleX, FontScaleY );
	C.SetPos( C.ClipX * 0.75 + XL * 0.5 - XL2, YOffset );
	C.DrawText( PRI.Deaths,false,,,FontScaleX, FontScaleY );

	SetFontSize( C, FS_Small );

	if ( ( C.ClipX > 512 ) && ( Level.NetMode != NM_Standalone ) )
	{
		C.DrawColor = WhiteColor;

		// Draw Time
		Time = Max( 1, ( Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime ) / 60 );		
		C.TextSize( TimeString$": 999", XL3, YL3, FontScaleX, FontScaleY );
		C.SetPos( C.ClipX * 0.75 + XL, YOffset );
		C.DrawText( TimeString$":"@Time,false,,,FontScaleX, FontScaleY );		

		// Draw FPH		
		C.TextSize( FPHString$": 999", XL2, YL2, FontScaleX, FontScaleY );
		C.SetPos( C.ClipX * 0.75 + XL, YOffset + 0.5 * YL );
		C.DrawText( FPHString$": "@int(60 * PRI.Score/Time),false,,,FontScaleX, FontScaleY );				

		XL3 = FMax(XL3, XL2);
		// Draw Ping
		C.SetPos( C.ClipX * 0.75 + XL + XL3 + 16, YOffset );
		C.DrawText( PingString$":"@PRI.Ping,false,,,FontScaleX, FontScaleY );				

		// Draw Packetloss
		C.SetPos( C.ClipX * 0.75 + XL + XL3 + 16, YOffset + 0.5 * YL );
		C.DrawText( LossString$":"@PRI.PacketLoss$"%",false,,,FontScaleX, FontScaleY );				
	}
}

//=============================================================================
//DrawScores
//=============================================================================
function DrawScores( canvas C )
{
	local PlayerReplicationInfo PRI;
	local int					PlayerCount, LoopCount, i;
	local float					XL, YL, Scale;
	local float					YOffset, YStart;
	local font					CanvasFont;

	return;

	// Save font
	CanvasFont	= C.Font;

	C.Style = ERenderStyle.STY_Normal;
    
    // Initialize fonts
    if ( !bInitFonts )
    {
        InitFonts( C );
        bInitFonts = true;
    }

	// Header
	DrawHeader( C );

	// Wipe everything.
	for ( i=0; i<ArrayCount(Ordered); i++ )
		Ordered[i] = None;

	for ( i=0; i<32; i++ )
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				if ( PlayerCount == ArrayCount(Ordered) )
					break;
			}
		}
	}
	SortScores(PlayerCount);
	
	C.SetPos( 0, 160.0/768.0 * C.ClipY );
	
	DrawCategoryHeaders( C );

	SetFontSize( C, FS_Medium );
	C.TextSize( "TEST", XL, YL, FontScaleX, FontScaleY );
	YStart  = C.CurY;
	YOffset = YStart;
	
	if ( PlayerCount > 15 )
		PlayerCount = FMin( PlayerCount, ( C.ClipY - YStart ) / YL - 1 );

	C.SetPos( 0, 0 );
	for ( I=0; I<PlayerCount; I++ )
	{
		YOffset = YStart + I * YL;
		DrawNameAndPing( C, Ordered[I], 0, YOffset );
	}

	// Restore Color and Font
	C.DrawColor = WhiteColor;
	C.Font      = CanvasFont;

	SetFontSize( C, FS_Small );
	DrawTrailer( C );
}

defaultproperties
{
	PlayerString="Players"
	FragsString="Frags"
	DeathsString="Deaths"
	PingString="Ping"
	LossString="Loss"
	TimeString="Time"
	FPHString="FPH"
	FragGoal="Frag Limit:"
	TimeLimit="Time Limit:"

	Restart="You are dead.  Hit [Fire] to respawn!"
	Ended="The match has ended."
	Continue=" Hit [Fire] to continue!"

	WhiteColor=(R=255,G=255,B=255)
	RedColor=(R=255,G=0,B=0)
	LightBlueColor=(R=0,G=0,B=128)
	DarkBlueColor=(R=0,G=0,B=64)
	BlueColor=(R=0,G=0,B=255)
	LightGreenColor=(R=0,G=128,B=0)
	DarkGreenColor=(R=32,G=64,B=32)
	GreenColor=(R=0,G=255,B=0)
	GoldColor=(R=255,G=255,B=0)
	TurqColor=(R=0,G=128,B=255)
	GrayColor=(R=200,G=200,B=200)
	CyanColor=(R=0,G=255,B=255)
	PurpleColor=(R=255,G=0,B=255)
	BlackColor=(R=0,G=0,B=0)
	OrangeColor=(R=255,G=144,B=0)

	LargeFontScaleX=0.5
	LargeFontScaleY=0.5
	MediumFontScaleX=0.4
	MediumFontScaleY=0.4
	SmallFontScaleX=0.2
	SmallFontScaleY=0.2	
	FontScaleX=1.0
	FontScaleY=1.0
	MyFont=font'MainMenuFont'

	ScoreboardWindowType="dnWindow.UDukeScoreboard"
}
