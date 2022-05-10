//=============================================================================
// Defensepoint.
//=============================================================================
class DefensePoint extends AmbushPoint;

var() byte team;
var() byte priority;
var() name FortTag;	//optional associated fort (for assault game)

defaultproperties
{
     bDirectional=True
     SoundVolume=128
}
