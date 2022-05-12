//=============================================================================
// LMSScoreBoard
//=============================================================================
class LMSScoreBoard extends TournamentScoreBoard;

var localized string VictoryGoal;

function DrawCategoryHeaders(Canvas Canvas)
{
	local float Offset, XL, YL;

	Offset = Canvas.CurY;
	Canvas.DrawColor = WhiteColor;

	Canvas.StrLen(PlayerString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*2 - XL/2, Offset);
	Canvas.DrawText(PlayerString);

	Canvas.StrLen(FragsString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8)*6 - XL/2, Offset);
	Canvas.DrawText(FragsString);

	if (Level.NetMode != NM_StandAlone)
	{
		Canvas.StrLen(PingString, XL, YL);
		Canvas.SetPos((Canvas.ClipX / 8)*7 - XL/2, Offset);
		Canvas.DrawText(PingString);
	}
}

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local float XL, YL, XL2;
	local Font CanvasFont;

	// Draw Name
	if ( PRI.bAdmin )
		Canvas.DrawColor = WhiteColor;
	else if (PRI.PlayerName == Pawn(Owner).PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;
	else 
		Canvas.DrawColor = CyanColor;
	Canvas.SetPos((Canvas.ClipX / 8) * 1.5, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);

	Canvas.StrLen( "0000", XL, YL );

	// Draw Score
	if ( PRI.Score < 1 )
		Canvas.DrawColor = LightCyanColor;
	else
		Canvas.DrawColor = GoldColor;
	Canvas.StrLen( int(PRI.Score), XL2, YL );
	Canvas.SetPos( (Canvas.ClipX / 8) * 6 + XL/2 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Score), false );

	if (Level.NetMode != NM_Standalone)
	{
		// Draw Ping
		Canvas.DrawColor = LightCyanColor;
		Canvas.StrLen( PRI.Ping, XL2, YL );
		Canvas.SetPos( (Canvas.ClipX / 8) * 7 + XL/2 - XL2, YOffset );
		Canvas.DrawText( PRI.Ping, false );
	}
}

function DrawVictoryConditions(Canvas Canvas)
{
	Canvas.DrawText(VictoryGoal);
}

defaultproperties
{
	VictoryGoal="Be the last one alive!"
	FragsString="Lives"
}
