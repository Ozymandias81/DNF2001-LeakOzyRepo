//=============================================================================
// dnExplosion1_Effect2.							Keith Schuler April 12,2000
//=============================================================================
class dnExplosion1_Effect2 expands dnExplosion1;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Rising smoke effect.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     CreationSound=None
     SpawnPeriod=0.300000
     PrimeCount=4
     Lifetime=3.000000
     InitialVelocity=(Z=24.000000)
     MaxVelocityVariance=(X=60.000000,Y=60.000000,Z=32.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     StartDrawScale=0.500000
     EndDrawScale=1.500000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=1.000000
     CollisionRadius=32.000000
     CollisionHeight=32.000000
     bCollideActors=True
}
