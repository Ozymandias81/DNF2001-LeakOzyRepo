//=============================================================================
// dnWaterSplash_Effect1.          Created by Charlie Wiederhold April 14, 2000
//=============================================================================
class dnWaterSplash_Effect1 expands dnWater1_Splash;

// Water splash effect
// Does NOT do damage. 
// Small splash of water to simulate something small landing in water and
// moving at a fast rate.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     spawnNumber=0
     PrimeCount=8
     Lifetime=0.750000
     LifetimeVariance=0.000000
     InitialVelocity=(Y=1236.000000,Z=256.000000)
     InitialAcceleration=(Z=-384.000000)
     MaxVelocityVariance=(X=64.000000,Y=64.000000,Z=64.000000)
     MaxAccelerationVariance=(X=64.000000,Y=64.000000,Z=32.000000)
     DieOnBounce=False
     Textures(0)=Texture't_generic.particle_efx.pflare5EBC'
     DieOnLastFrame=False
     EndDrawScale=2.000000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     TriggerOnSpawn=False
     TriggerType=SPT_None
     PulseSeconds=0.000000
     DrawScale=4.000000
     bUnlit=True
     CollisionRadius=32.000000
}
