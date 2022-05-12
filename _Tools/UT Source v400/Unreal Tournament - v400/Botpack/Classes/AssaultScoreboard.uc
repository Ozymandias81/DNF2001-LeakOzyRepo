//=============================================================================
// AssaultScoreBoard
//=============================================================================
class AssaultScoreBoard extends TeamScoreBoard;

var localized string AssaultCondition;

function ShowScores( canvas Canvas )
{
	Super.ShowScores(Canvas);

	if ( OwnerHUD.IsA('AssaultHUD') )
		AssaultHUD(OwnerHUD).DrawTimeAt(Canvas, 0.5 * Canvas.ClipX - 80 * Canvas.ClipX/1280, 4);
}

function DrawVictoryConditions(Canvas Canvas)
{
	Canvas.DrawText(AssaultCondition, true);
}

defaultproperties
{
	AssaultCondition="Assault the Base!"
	FragGoal="Score Limit:"
}
