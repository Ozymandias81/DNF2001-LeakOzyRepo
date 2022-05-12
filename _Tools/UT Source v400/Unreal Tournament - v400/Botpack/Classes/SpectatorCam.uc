//=============================================================================
// SpectatorCam.
//=============================================================================
class SpectatorCam extends KeyPoint;

var() bool bSkipView; // spectators skip this camera when flipping through cams
var() float FadeOutTime;	// fade out time if used as EndCam

defaultproperties
{
    CollisionRadius=+00020.000000
    CollisionHeight=+00040.000000
	bDirectional=true
	DrawType=DT_Mesh
	bClientAnim=true
	texture=S_Camera
	FadeOutTime=+5.0
}