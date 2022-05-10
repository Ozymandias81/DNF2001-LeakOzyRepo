//=============================================================================
// dnWaterSpray_Effect1.           Created by Charlie Wiederhold April 12, 2000
//=============================================================================
class dnWaterSpray_Effect1 expands dnWater1_Spray;

// Water spray effect
// Does NOT do damage. 
// Large spray of water for use to fake forward motion of an object landing in
// the water.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx

defaultproperties
{
     CreationSound=Sound'a_generic.Water.SplashIn01'
     CreationSoundRadius=8192.000000
     SpawnNumber=0
     PrimeCount=6
     Lifetime=2.000000
     LifetimeVariance=0.000000
     InitialVelocity=(Y=2048.000000,Z=256.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=256.000000)
     MaxAccelerationVariance=(Y=256.000000)
     Apex=(Z=0.000000)
     DieOnBounce=False
     Textures(0)=Texture't_generic.WaterImpact.waterimpact2bRC'
     StartDrawScale=2.000000
     EndDrawScale=4.000000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     TriggerOnSpawn=False
     TriggerType=SPT_None
     PulseSeconds=0.000000
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=1024.000000
     CollisionRadius=256.000000
}
