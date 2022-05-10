//=============================================================================
// dnSparkEffect.										Keith Schuler 4/12/2000
//=============================================================================
class dnSparkEffect expands SoftParticleSystem;

// Spark effect class.
// Does NOT do damage. 
// Uses dnSparkEffect_Effect1

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnSparkEffect_Effect1')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=6.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.250000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     bBurning=True
     bHidden=True
     Style=STY_Translucent
     bUnlit=True
}
