//=============================================================================
// AlternatePath.
//=============================================================================
class AlternatePath extends NavigationPoint;

var() byte Team;
var() float SelectionWeight;
var() bool bReturnOnly;

defaultproperties
{
	SelectionWeight=+1.0000
}