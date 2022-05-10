//=============================================================================
// ScoreBoard
//=============================================================================
class ScoreBoard extends Info;

var font RegFont;
var HUD OwnerHUD;

function CreateScoreboardWindow( Canvas C );

function DrawScores( canvas Canvas );

function DrawMiniScores( Canvas Canvas );

function PreRender( Canvas C );

function PostRender( Canvas C );

function PreBeginPlay()
{
}

defaultproperties
{
     bHidden=True
}
