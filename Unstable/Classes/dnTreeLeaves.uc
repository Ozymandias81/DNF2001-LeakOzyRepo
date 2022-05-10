//=============================================================================
// dnTreeLeaves.	Keith Schuler	Feb 16,2001
//=============================================================================
class dnTreeLeaves expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\petalumahouse.dtx

defaultproperties
{
     SpawnNumber=0
     SpawnPeriod=0.500000
     PrimeCount=32
     MaximumParticles=32
     Lifetime=0.000000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'petalumahouse.Masked.Tree02'
     DrawScaleVariance=0.100000
     RotationVariance=32768.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.010000
     Style=STY_Masked
     bUnlit=True
     CollisionRadius=96.000000
     CollisionHeight=96.000000
}
