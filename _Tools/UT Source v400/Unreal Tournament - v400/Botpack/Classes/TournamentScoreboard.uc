//=============================================================================
// TournamentScoreBoard
//=============================================================================
class TournamentScoreBoard extends ScoreBoard;

var localized string MapTitle, Author, Restart, Continue, Ended, ElapsedTime, RemainingTime, FragGoal, TimeLimit;
var localized string PlayerString, FragsString, DeathsString, PingString;
var localized string TimeString, LossString, FPHString;
var color GreenColor, WhiteColor, GoldColor, BlueColor, LightCyanColor, SilverColor, BronzeColor, CyanColor, RedColor;
var PlayerReplicationInfo Ordered[32];
var float ScoreStart;	// top allowed score start
var bool bTimeDown;
var FontInfo MyFonts;

function Destroyed()
{
	Super.Destroyed();
	if ( MyFonts != None )
		MyFonts.Destroy();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MyFonts = Spawn(class'FontInfo');
}

function DrawHeader( canvas Canvas )
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local font CanvasFont;

	Canvas.DrawColor = WhiteColor;
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

	Canvas.bCenter = True;
	Canvas.StrLen("Test", XL, YL);
	ScoreStart = 58.0/768.0 * Canvas.ClipY;
	CanvasFont = Canvas.Font;
	if ( GRI.GameEndedComments != "" )
	{
		Canvas.DrawColor = GoldColor;
		Canvas.SetPos(0, ScoreStart);
		Canvas.DrawText(GRI.GameEndedComments, True);
	}
	else
	{
		Canvas.SetPos(0, ScoreStart);
		DrawVictoryConditions(Canvas);
	}
	Canvas.bCenter = False;
	Canvas.Font = CanvasFont;
}

function DrawVictoryConditions(Canvas Canvas)
{
	local TournamentGameReplicationInfo TGRI;
	local float XL, YL;

	TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	if ( TGRI == None )
		return;

	Canvas.DrawText(TGRI.GameName);
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, Canvas.CurY - YL);

	if ( TGRI.FragLimit > 0 )
	{
		Canvas.DrawText(FragGoal@TGRI.FragLimit);
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.CurY - YL);
	}

	if ( TGRI.TimeLimit > 0 )
		Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
}

function string TwoDigitString(int Num)
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string(Num);
}

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local float XL, YL;
	local PlayerPawn PlayerOwner;

	Canvas.bCenter = true;
	Canvas.StrLen("Test", XL, YL);
	Canvas.DrawColor = WhiteColor;
	PlayerOwner = PlayerPawn(Owner);
	Canvas.SetPos(0, Canvas.ClipY - 2 * YL);
	if ( (Level.NetMode == NM_Standalone) && Level.Game.IsA('DeathMatchPlus') )
	{
		if ( DeathMatchPlus(Level.Game).bRatedGame )
			Canvas.DrawText(DeathMatchPlus(Level.Game).RatedGameLadderObj.SkillText@PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title, true);
		else if ( DeathMatchPlus(Level.Game).bNoviceMode ) 
			Canvas.DrawText(class'ChallengeBotInfo'.default.Skills[Level.Game.Difficulty]@PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title, true);
		else  
			Canvas.DrawText(class'ChallengeBotInfo'.default.Skills[Level.Game.Difficulty + 4]@PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title, true);
	}
	else
		Canvas.DrawText(PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title, true);

	Canvas.SetPos(0, Canvas.ClipY - YL);
	if ( bTimeDown || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
	{
		bTimeDown = true;
		if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
			Canvas.DrawText(RemainingTime@"00:00", true);
		else
		{
			Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
			Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
			Canvas.DrawText(RemainingTime@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
		}
	}
	else
	{
		Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		Canvas.DrawText(ElapsedTime@TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
	}

	if ( PlayerOwner.GameReplicationInfo.GameEndedComments != "" )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		if ( Level.NetMode == NM_Standalone )
			Canvas.DrawText(Ended@Continue, true);
		else
			Canvas.DrawText(Ended, true);
	}
	else if ( (PlayerOwner != None) && (PlayerOwner.Health <= 0) )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(Restart, true);
	}
	Canvas.bCenter = false;
}

function DrawCategoryHeaders(Canvas Canvas)
{
	local float Offset, XL, YL;

	Offset = Canvas.CurY;
	Canvas.DrawColor = WhiteColor;

	Canvas.StrLen(PlayerString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*2 - XL/2, Offset);
	Canvas.DrawText(PlayerString);

	Canvas.StrLen(FragsString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*5 - XL/2, Offset);
	Canvas.DrawText(FragsString);

	Canvas.StrLen(DeathsString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*6 - XL/2, Offset);
	Canvas.DrawText(DeathsString);
}

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local float XL, YL, XL2, YL2, XL3, YL3;
	local Font CanvasFont;
	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
	local int Time;

	PlayerOwner = PlayerPawn(Owner);

	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

	// Draw Name
	if ( PRI.bAdmin )
		Canvas.DrawColor = WhiteColor;
	else if ( bLocalPlayer ) 
		Canvas.DrawColor = GoldColor;
	else 
		Canvas.DrawColor = CyanColor;

	Canvas.SetPos(Canvas.ClipX * 0.1875, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);

	Canvas.StrLen( "0000", XL, YL );

	// Draw Score
	if ( !bLocalPlayer )
		Canvas.DrawColor = LightCyanColor;

	Canvas.StrLen( int(PRI.Score), XL2, YL );
	Canvas.SetPos( Canvas.ClipX * 0.625 + XL * 0.5 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Score), false );

	// Draw Deaths
	Canvas.StrLen( int(PRI.Deaths), XL2, YL );
	Canvas.SetPos( Canvas.ClipX * 0.75 + XL * 0.5 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Deaths), false );

	if ( (Canvas.ClipX > 512) && (Level.NetMode != NM_Standalone) )
	{
		Canvas.DrawColor = WhiteColor;
		Canvas.Font = MyFonts.GetSmallestFont(Canvas.ClipX);

		// Draw Time
		Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
		Canvas.TextSize( TimeString$": 999", XL3, YL3 );
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL, YOffset );
		Canvas.DrawText( TimeString$":"@Time, false );

		// Draw FPH
		Canvas.TextSize( FPHString$": 999", XL2, YL2 );
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL, YOffset + 0.5 * YL );
		Canvas.DrawText( FPHString$": "@int(60 * PRI.Score/Time), false );

		XL3 = FMax(XL3, XL2);
		// Draw Ping
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL + XL3 + 16, YOffset );
		Canvas.DrawText( PingString$":"@PRI.Ping, false );

		// Draw Packetloss
		Canvas.SetPos( Canvas.ClipX * 0.75 + XL + XL3 + 16, YOffset + 0.5 * YL );
		Canvas.DrawText( LossString$":"@PRI.PacketLoss$"%", false );
	}
}

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

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, i;
	local float XL, YL, Scale;
	local float YOffset, YStart;
	local font CanvasFont;

	Canvas.Style = ERenderStyle.STY_Normal;

	// Header
	Canvas.SetPos(0, 0);
	DrawHeader(Canvas);

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
	
	CanvasFont = Canvas.Font;
	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

	Canvas.SetPos(0, 160.0/768.0 * Canvas.ClipY);
	DrawCategoryHeaders(Canvas);

	Canvas.StrLen( "TEST", XL, YL );
	YStart = Canvas.CurY;
	YOffset = YStart;
	if ( PlayerCount > 15 )
		PlayerCount = FMin(PlayerCount, (Canvas.ClipY - YStart)/YL - 1);

	Canvas.SetPos(0, 0);
	for ( I=0; I<PlayerCount; I++ )
	{
		YOffset = YStart + I * YL;
		DrawNameAndPing( Canvas, Ordered[I], 0, YOffset );
	}
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = CanvasFont;

	// Trailer
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	DrawTrailer(Canvas);

	Canvas.DrawColor = WhiteColor;
	Canvas.Font = CanvasFont;
}

defaultproperties
{
	PlayerString="Player"
	FragsString="Frags"
	DeathsString="Deaths"
	PingString="Ping"
	LossString="Loss"
	TimeString="Time"
	FPHString="FPH"
	MapTitle="in"
	Author="by"
	Restart="You are dead.  Hit [Fire] to respawn!"
	Ended="The match has ended."
	Continue=" Hit [Fire] to continue!"
	ElapsedTime="Elapsed Time: "
	RemainingTime="Remaining Time: "
	WhiteColor=(R=255,G=255,B=255)
	BlueColor=(R=0,G=0,B=255)
	GreenColor=(R=0,G=255,B=0)
	GoldColor=(R=255,G=255,B=0)
	SilverColor=(R=138,G=164,B=166)
	BronzeColor=(R=203,G=147,B=52)
	CyanColor=(R=0,G=128,B=255)
	LightCyanColor=(R=128,G=255,B=255)
	RedColor=(R=255,G=0,B=0)
	FragGoal="Frag Limit:"
	TimeLimit="Time Limit:"
}
