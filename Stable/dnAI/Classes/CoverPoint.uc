//=============================================================================
// CoverPoint.uc
// 
// This class is obsolete please REMOVE it!
//=============================================================================
class CoverPoint extends NavigationPoint;

var bool bStrafeOut;
var bool bOccupied;

function Timer( optional int TimerNum )
{
	bOccupied = false;
}

defaultproperties
{
    bStrafeOut=true 
	bDirectional=True
    SoundVolume=128
    Texture=S_Patrol
}
