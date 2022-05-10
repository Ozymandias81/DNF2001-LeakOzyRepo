//=============================================================================
// dnExplosion2_Effect2.           Created by Charlie Wiederhold April 12, 2000
//=============================================================================
class dnExplosion2_Effect2 expands dnExplosion2;

// Smoke effect.
// Does NOT do damage. 
// Spawns 8 smoke particles, dies after fading out.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     PrimeCount=8
     Lifetime=3.000000
     InitialVelocity=(Z=32.000000)
     InitialAcceleration=(Z=96.000000)
     MaxVelocityVariance=(X=320.000000,Y=192.000000,Z=48.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     DrawScaleVariance=1.000000
     StartDrawScale=5.000000
     EndDrawScale=7.000000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     CollisionRadius=192.000000
     CollisionHeight=192.000000
}
