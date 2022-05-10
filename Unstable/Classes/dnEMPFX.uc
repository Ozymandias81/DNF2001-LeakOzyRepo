//=============================================================================
// dnEMPFX. 							October 10th, 2000 - Charlie Wiederhold
//=============================================================================
class dnEMPFX expands SoftParticleSystem;

// EMP Glow Effect
// Does NOT do damage. 
// Spawns the purple haze that happens after an object disables

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     MaximumParticles=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.lensflares.genwinflare2BC'
     StartDrawScale=0.100000
     EndDrawScale=2.500000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     DestroyOnDismount=True
}
