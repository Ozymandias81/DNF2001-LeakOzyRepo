//=============================================================================
// ShockBeam2.
//=============================================================================
class ShockBeam2 extends ShockBeam;

simulated function Timer()
{
	local ShockBeam r;
	
	if (NumPuffs>0)
	{
		r = Spawn(class'Shockbeam2',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

defaultproperties
{
     Physics=PHYS_None
     Rotation=(Roll=0)
     Style=STY_Modulated
     DrawScale=0.300000
     bFixedRotationDir=False
     RotationRate=(Roll=0)
     DesiredRotation=(Roll=0)
}
