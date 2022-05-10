//=============================================================================
// dnTeamGameScoreBoard
//=============================================================================
class dnTeamGameScoreBoard extends dnDeathmatchGameScoreboard;

var		localized string				TeamName[4];
var		localized string				OrdersString, InString;
var		localized string				PlayersNotShown;
var()	color							TeamColor[4];
var()	color							AltTeamColor[4];
var		PlayerReplicationInfo			OwnerInfo;
var		dnDeathmatchGameReplicationInfo	OwnerGame;

//=============================================================================
//DrawScores
//=============================================================================
function DrawScores( canvas C )
{
	local PlayerReplicationInfo PRI;
	local int					PlayerCount, i;
	local int					LoopCountTeam[4];
	local float					XL, YL, XOffset, YOffset, XStart;
	local int					PlayerCounts[4];
	local int					LongLists[4];
	local int					BottomSlot[4];
	local font					CanvasFont;

	OwnerInfo		= Pawn(Owner).PlayerReplicationInfo;
	OwnerGame		= dnDeathmatchGameReplicationInfo( PlayerPawn(Owner).GameReplicationInfo );
	C.Style			= ERenderStyle.STY_Normal;
	
	// Initialize fonts
    if ( !bInitFonts )
    {
        InitFonts( C );
        bInitFonts = true;
    }

	// Header
	DrawHeader( C );

	for ( i=0; i<32; i++ )
		Ordered[i] = None;

	for ( i=0; i<32; i++ )
	{	
		if ( PlayerPawn( Owner ).GameReplicationInfo.PRIArray[i] != None )
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			
			if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				PlayerCounts[PRI.Team]++;
			}
		}
	}

	SortScores( PlayerCount );

	SetFontSize( C, FS_Medium );
	C.TextSize( "TEXT", XL, YL, FontScaleX, FontScaleY );

	ScoreStart = C.CurY + YL*2;

	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team < 4 )
		{
			if ( Ordered[I].Team % 2 == 0 )
				XOffset = ( C.ClipX / 4 ) - ( C.ClipX / 8 );
			else
				XOffset = ( ( C.ClipX / 4 ) * 3 ) - ( C.ClipX / 8 );

			C.TextSize( "TEXT", XL, YL, FontScaleX, FontScaleY );			
			C.DrawColor = AltTeamColor[Ordered[I].Team];
			
			YOffset = ScoreStart + ( LoopCountTeam[Ordered[I].Team] * YL ) + 2;

			if ( ( Ordered[I].Team > 1 ) && ( PlayerCounts[Ordered[I].Team-2] > 0 ) )
			{
				BottomSlot[Ordered[I].Team] = 1;
				YOffset = ScoreStart + YL*11 + LoopCountTeam[Ordered[I].Team]*YL;
			}

			// Draw Name and Ping
			if ( ( Ordered[I].Team < 2 ) && ( BottomSlot[Ordered[I].Team] == 0 ) && ( PlayerCounts[Ordered[I].Team+2] == 0 ) )
			{
				LongLists[Ordered[I].Team] = 1;
				DrawNameAndPing( C, Ordered[I], XOffset, YOffset);
			} 
			else if ( LoopCountTeam[Ordered[I].Team] < 8 )
			{
				DrawNameAndPing( C, Ordered[I], XOffset, YOffset);
			}
			LoopCountTeam[Ordered[I].Team] += 2;
		}
	}

	for ( i=0; i<4; i++ )
	{
		SetFontSize( C, FS_Medium );
		
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = (C.ClipX / 4) - (C.ClipX / 8);
			else
				XOffset = ((C.ClipX / 4) * 3) - (C.ClipX / 8);
			
			YOffset = ScoreStart - YL + 2;

			if ( i > 1 )
			{
				if ( PlayerCounts[i-2] > 0 )
				{
					YOffset = ScoreStart + YL*10;
				}
			}

			C.DrawColor = TeamColor[i];
			C.SetPos( XOffset, YOffset );
			C.TextSize( TeamName[i], XL, YL, FontScaleX, FontScaleY );
			C.DrawText( TeamName[i], false,,,FontScaleX, FontScaleY );
			
			//C.TextSize( int( OwnerGame.Teams[i].Score ), XL, YL, FontScaleX, FontScaleY );
			//C.SetPos( XOffset + ( C.ClipX/4 ) - XL, YOffset );
			//C.DrawText( int( OwnerGame.Teams[i].Score ), false,,,FontScaleX, FontScaleY );
				
			if ( PlayerCounts[i] > 4 )
			{
				if ( i < 2 )
					YOffset = ScoreStart + YL*8;
				else
					YOffset = ScoreStart + YL*19;

				SetFontSize( C, FS_Small );
				C.SetPos( XOffset, YOffset );
				
				if ( LongLists[i] == 0 )
					C.DrawText( PlayerCounts[i] - 4 @ PlayersNotShown, false,,,FontScaleX, FontScaleY );
			}
		}
	}

	SetFontSize( C, FS_Small );
	DrawTrailer( C );
	
	C.DrawColor = WhiteColor;
}

//=============================================================================
//DrawScore
//=============================================================================
function DrawScore(Canvas C, coerce string Score, float XOffset, float YOffset)
{
	local float XL, YL;

	C.TextSize( Score, XL, YL, FontScaleX, FontScaleY);
	C.SetPos(XOffset + (C.ClipX/4) - XL, YOffset);
	C.DrawText( Score, false,,,FontScaleX, FontScaleY);
}

//=============================================================================
//DrawNameAndPing
//=============================================================================
function DrawNameAndPing(Canvas C, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local float XL, YL, XL2, YL2;
	local String S, O, L;
	local bool bAdminPlayer;
	local PlayerPawn PlayerOwner;
	local int Time;

	PlayerOwner = PlayerPawn(Owner);

	bAdminPlayer = PRI.bAdmin;

	// Draw Name
	if ( PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName )
		C.DrawColor = GoldColor;

	if ( bAdminPlayer )
		C.DrawColor = WhiteColor;

	C.SetPos( XOffset, YOffset );	
	C.DrawText( PRI.PlayerName, false,,,FontScaleX, FontScaleY );

	if ( C.ClipX > 512 )
	{
		SetFontSize( C, FS_Small );
		C.DrawColor = WhiteColor;

		if (Level.NetMode != NM_Standalone)
		{
			// Draw Time
			Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
			C.TextSize(TimeString$":     ", XL, YL, FontScaleX, FontScaleY);
			C.SetPos(XOffset - XL - 6, YOffset);
			C.DrawText(TimeString$":"@Time, false,,,FontScaleX, FontScaleY);

			// Draw Ping
			C.TextSize(PingString$":     ", XL2, YL2, FontScaleX, FontScaleY);
			C.SetPos(XOffset - XL2 - 6, YOffset + (YL+1));
			C.DrawText(PingString$":"@PRI.Ping, false,,,FontScaleX, FontScaleY);
		}		

		SetFontSize( C, FS_Medium );
	}

	// Draw Score
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		C.DrawColor = GoldColor;
	else
		C.DrawColor = TeamColor[PRI.Team];

	DrawScore( C, PRI.Kills $"/"$ PRI.Deaths , XOffset, YOffset );

	if ( C.ClipX < 512 )
		return;

	// Draw location, Order
	if ( PRI.Team == OwnerInfo.Team )
	{
		SetFontSize( C, FS_Small );
		if ( PRI.PlayerLocation != None )
			L = PRI.PlayerLocation.LocationName;
		else if ( PRI.PlayerZone != None )
			L = PRI.PlayerZone.ZoneName;
		else 
			L = "";

		if ( L != "" )
		{
			L = InString@L;
			C.TextSize(L, XL2, YL2, FontScaleX, FontScaleY);
			C.SetPos(XOffset, YOffset + YL2*3 + 1);
			C.DrawText(L, false,,,FontScaleX, FontScaleY);
		}

		SetFontSize( C, FS_Medium );
	}
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
	{
		return;
	}

	C.DrawText( GRI.GameName,,,,FontScaleX, FontScaleY );
	C.TextSize( "Test", XL, YL, FontScaleX, FontScaleY );
	C.SetPos( 0, C.CurY - YL );

	if ( GRI.GoalTeamScore > 0 )
	{
		C.DrawText( FragGoal@GRI.GoalTeamScore,,,,FontScaleX, FontScaleY );
		C.TextSize( "Test", XL, YL, FontScaleX, FontScaleY );
		C.SetPos( 0, C.CurY - YL );
	}

	if ( GRI.TimeLimit > 0 )
	{
		C.DrawText( TimeLimit@GRI.TimeLimit$":00",,,,FontScaleX, FontScaleY );
	}
}

//=============================================================================
//defaultproperties
//=============================================================================
defaultproperties
{
	 InString="Location:"
	 OrdersString="Orders:"
	 PlayersNotShown="Player[s] not shown."
	 TeamName(0)="Humans - Kills/Deaths"
	 TeamName(1)="Bugs - Kills/Deaths"
	 TeamColor(0)=(R=255,G=0,B=0)
	 TeamColor(1)=(R=0,G=0,B=255)
	 AltTeamColor(0)=(R=200,G=0,B=0)
	 AltTeamColor(1)=(R=0,G=94,B=187)
}
