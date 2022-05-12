//=============================================================================
// ChallengeDominationHUD.
//=============================================================================
class ChallengeDominationHUD extends ChallengeTeamHUD;

simulated function PostRender( canvas Canvas )
{
	local int TeamScore;
	local int X, Y;
	local float XL, YL;
	local ControlPoint CP;
	local NavigationPoint N;
	local Texture CPTexture;

	Super.PostRender( Canvas );

	if ( bHideHud 
		|| ((Canvas.ClipX <= 400) && ((PlayerPawn(Owner).bShowScores) || bForceScores)) )
		return;

	if ( TournamentConsole(PlayerPawn(Owner).Player.Console).bShowSpeech == True )
		return;

	X = 0;
	Y = Canvas.ClipY - 384 * Scale;
	Canvas.Style = Style;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('ControlPoint') )
		{
			CP = ControlPoint(N);
			if (CP.ControllingTeam != None) 
				CPTexture = TeamIcon[CP.ControllingTeam.TeamIndex];
			else
				CPTexture = texture'I_TeamN';

			Canvas.DrawColor = BaseColor;
			Canvas.SetPos(X,Y);
			Canvas.DrawIcon(CPTexture, Scale);
			Y -= 140 * Scale;
		}

	// separate name drawing to reduce texture changes
	Y = Canvas.ClipY - 384 * Scale;
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('ControlPoint') )
		{
			CP = ControlPoint(N);
			if (CP.ControllingTeam != None) 
				Canvas.DrawColor = TeamColor[CP.ControllingTeam.TeamIndex];
			else
				Canvas.DrawColor = WhiteColor;
			Canvas.SetPos(0, 0);
			Canvas.StrLen(CP.PointName, XL, YL);
			Canvas.SetPos(0, Y + 96 * Scale - YL);
			Canvas.DrawText(CP.PointName);
			Y -= 140 * Scale;
		}
}

simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
{
	local float XL, YL;

	if ( !Other.IsA('ControlPoint') )
		return false;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.DrawColor = RedColor;
	Canvas.DrawColor.R = 255 * (IdentifyFadeTime / 3.0);

	Canvas.StrLen(ControlPoint(Other).PointName, XL, YL);
	Canvas.SetPos(Canvas.ClipX/2 - XL/2, Canvas.ClipY - 74);
	Canvas.DrawText(ControlPoint(Other).PointName);

	return true;
}

defaultproperties
{
	ServerInfoClass=class'ServerInfoDOM'
	bAlwaysHideFrags=false
}