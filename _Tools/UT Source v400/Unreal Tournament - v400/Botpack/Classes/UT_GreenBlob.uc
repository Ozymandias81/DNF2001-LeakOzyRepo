//=============================================================================
// ut_GreenBlob.
//=============================================================================
class UT_GreenBlob extends Effects;

simulated function Setup(vector WallNormal)
{
	Velocity = VRand()*140*FRand()+WallNormal*250;
	DrawScale = FRand()*0.7 + 0.6;
}

auto state Explode
{

	simulated function Landed( vector HitNormal )
	{
		Destroy();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Destroy();
	}
}

defaultproperties
{
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=7.000000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'Botpack.Jgreen'
     Mesh=Mesh'Botpack.BioGelm'
     DrawScale=0.800000
     bUnlit=True
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bCollideWorld=True
     bBounce=True
     NetPriority=2.000000
	 bHighDetail=true
}
