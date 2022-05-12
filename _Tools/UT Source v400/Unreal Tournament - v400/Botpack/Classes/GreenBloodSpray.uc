//=============================================================================
// GreenBloodSpray.
//=============================================================================
class GreenBloodSpray extends BloodSpray;

simulated function SpawnCloud()
{
	spawn(class'UT_GreenBloodPuff');
}

defaultproperties
{
	Texture=BloodSGrn
     DrawScale=0.400000
     AmbientGlow=80
}
