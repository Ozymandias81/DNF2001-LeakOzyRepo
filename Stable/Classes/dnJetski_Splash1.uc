//=============================================================================
// dnJetski_Splash1.               Created by Charlie Wiederhold April 19, 2000
//=============================================================================
class dnJetski_Splash1 expands dnWater1_Spray;

// Splash of water when the jetski emerges from the water
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=True
     CreationSound=Sound'a_generic.Water.SplashIn01'
     SpawnNumber=0
     SpawnPeriod=1.000000
     PrimeCount=8
     PrimeTimeIncrement=0.000000
     MaximumParticles=8
     Lifetime=1.000000
     LifetimeVariance=0.000000
     InitialVelocity=(Y=1236.000000,Z=256.000000)
     InitialAcceleration=(Z=0.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000,Z=64.000000)
     Textures(0)=Texture't_generic.WaterImpact.waterimpact3cRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.250000
     EndDrawScale=1.500000
     AlphaStart=1.000000
     AlphaEnd=0.000000
     TriggerOnSpawn=False
     TriggerType=SPT_None
     PulseSeconds=0.500000
     VisibilityRadius=4096.000000
     VisibilityHeight=1024.000000
}
