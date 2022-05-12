//=============================================================================
// TeamScoreBoard
//=============================================================================
class TeamScoreBoard extends TournamentScoreBoard;

var localized string TeamName[4];
var localized string OrdersString, InString;
var localized string PlayersNotShown;
var() color TeamColor[4];
var() color AltTeamColor[4];
var PlayerReplicationInfo OwnerInfo;
var TournamentGameReplicationInfo OwnerGame;

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, i;
	local int LoopCountTeam[4];
	local float XL, YL, XOffset, YOffset, XStart;
	local int PlayerCounts[4];
	local int LongLists[4];
	local int BottomSlot[4];
	local font CanvasFont;

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);	
	Canvas.Style = ERenderStyle.STY_Normal;
	CanvasFont = Canvas.Font;

	// Header
	DrawHeader(Canvas);

	for ( i=0; i<32; i++ )
		Ordered[i] = None;

	for ( i=0; i<32; i++ )
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( !PRI.bIsSpectator )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				PlayerCounts[PRI.Team]++;
			}
		}
	}

	SortScores(PlayerCount);
	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
	Canvas.StrLen("TEXT", XL, YL);
	ScoreStart = Canvas.CurY + YL*2;
	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team % 2 == 0 )
			XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
		else
			XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);

		Canvas.StrLen("TEXT", XL, YL);
		Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
		YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * YL) + 2;
		if (( Ordered[I].Team > 1 ) && ( PlayerCounts[Ordered[I].Team-2] > 0 ))
		{
			BottomSlot[I] = 1;
			YOffset = ScoreStart + YL*11 + LoopCountTeam[Ordered[I].Team]*YL;
		}

		// Draw Name and Ping
		if ((BottomSlot[I] == 0) && (PlayerCounts[Ordered[I].Team+2] == 0))
		{
			LongLists[Ordered[I].Team] = 1;
			DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset);
		} else if (LoopCountTeam[Ordered[I].Team] < 8)
			DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset);
		LoopCountTeam[Ordered[I].Team] += 2;
	}

	for ( i=0; i<4; i++ )
	{
		Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);
			YOffset = ScoreStart - YL + 2;

			if ( i > 1 )
				if (PlayerCounts[i-2] > 0)
					YOffset = ScoreStart + YL*10;

			Canvas.DrawColor = TeamColor[i];
			Canvas.SetPos(XOffset, YOffset);
			Canvas.StrLen(TeamName[i], XL, YL);
			Canvas.DrawText(TeamName[i], false);
			Canvas.StrLen(int(OwnerGame.Teams[i].Score), XL, YL);
			Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset);
			Canvas.DrawText(int(OwnerGame.Teams[i].Score), false);
				
			if ( PlayerCounts[i] > 4 )
			{
				if ( i < 2 )
					YOffset = ScoreStart + YL*8;
				else
					YOffset = ScoreStart + YL*19;
				Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
				Canvas.SetPos(XOffset, YOffset);
				if (LongLists[i] == 0)
					Canvas.DrawText(PlayerCounts[i] - 4 @ PlayersNotShown, false);
			}
		}
	}

	// Trailer
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	DrawTrailer(Canvas);

	Canvas.Font = CanvasFont;
	Canvas.DrawColor = WhiteColor;
}

function DrawScore(Canvas Canvas, float Score, float XOffset, float YOffset)
{
	local float XL, YL;

	Canvas.StrLen(string(int(Score)), XL, YL);
	Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset);
	Canvas.DrawText(int(Score), False);
}

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local float XL, YL, XL2, YL2;
	local BotReplicationInfo BRI;
	local String S, O, L;
	local Font CanvasFont;
	local bool bAdminPlayer;
	local PlayerPawn PlayerOwner;
	local int Time;

	PlayerOwner = PlayerPawn(Owner);

	bAdminPlayer = PRI.bAdmin;

	// Draw Name
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;

	if ( bAdminPlayer )
		Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(XOffset, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);

	if (Canvas.ClipX > 512)
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';
		Canvas.DrawColor = WhiteColor;

		// Draw Time
		Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
		Canvas.StrLen(TimeString$":     ", XL, YL);
		Canvas.SetPos(XOffset - XL - 6, YOffset);
		Canvas.DrawText(TimeString$":"@Time, false);

		if (Level.NetMode != NM_Standalone)
		{
			// Draw Ping
			Canvas.StrLen(PingString$":     ", XL2, YL2);
			Canvas.SetPos(XOffset - XL2 - 6, YOffset + (YL+1));
			Canvas.DrawText(PingString$":"@PRI.Ping, false);

			// Draw Packetloss
			Canvas.StrLen(LossString$":    %", XL, YL);
			Canvas.SetPos(XOffset - XL - 6, YOffset + (YL+1)*2);
			Canvas.DrawText(LossString$":"@PRI.PacketLoss$"%", false);
		}
		Canvas.Font = CanvasFont;
	}

	// Draw Score
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = TeamColor[PRI.Team];
	DrawScore(Canvas, PRI.Score, XOffset, YOffset);

	if (Canvas.ClipX < 512)
		return;

	// Draw location, Order
	if ( PRI.Team == OwnerInfo.Team )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';

		if ( PRI.PlayerLocation != None )
			L = PRI.PlayerLocation.LocationName;
		else if ( PRI.PlayerZone != None )
			L = PRI.PlayerZone.ZoneName;
		else 
			L = "";
		if ( L != "" )
		{
			L = InString@L;
			Canvas.StrLen(L, XL2, YL2);
			Canvas.SetPos(XOffset, YOffset + YL2*3 + 1);
			Canvas.DrawText(L, False);
		}
		O = OwnerGame.GetOrderString(PRI);
		if (O != "")
		{
			O = OrdersString@O;
			Canvas.StrLen(O, XL, YL);
			Canvas.SetPos(XOffset, YOffset + YL*2 + 2);
			Canvas.DrawText(O, False);
		}
		Canvas.Font = CanvasFont;
	}
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

	if ( TGRI.GoalTeamScore > 0 )
	{
		Canvas.DrawText(FragGoal@TGRI.GoalTeamScore);
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.CurY - YL);
	}

	if ( TGRI.TimeLimit > 0 )
		Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
}

defaultproperties
{
	 InString="Location:"
	 OrdersString="Orders:"
	 PlayersNotShown="Player[s] not shown."
	 TeamName(0)="Red Team"
	 TeamName(1)="Blue Team"
	 TeamName(2)="Green Team"
	 TeamName(3)="Gold Team"
	 TeamColor(0)=(R=255,G=0,B=0)
	 TeamColor(1)=(R=0,G=128,B=255)
	 TeamColor(2)=(R=0,G=255,B=0)
	 TeamColor(3)=(R=255,G=255,B=0)
	 AltTeamColor(0)=(R=200,G=0,B=0)
	 AltTeamColor(1)=(R=0,G=94,B=187)
	 AltTeamColor(2)=(R=0,G=128,B=0)
	 AltTeamColor(3)=(R=255,G=255,B=128)
}
