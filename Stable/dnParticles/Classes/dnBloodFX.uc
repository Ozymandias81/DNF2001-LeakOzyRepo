//=============================================================================
// dnBloodFX. 						  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnBloodFX expands SoftParticleSystem;

// Root of the Blood Splat effects. Creates a small puff of blood on impact.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnBloodFX_BloodChunksBulletImpact')
     SpawnNumber=0
     PrimeCount=2
     PrimeTimeIncrement=0.000000
     MaximumParticles=2
     Lifetime=0.625000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp1aRC'
     StartDrawScale=0.125000
     EndDrawScale=0.250000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaEnd=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
