//=============================================================================
// dnWallWaterSplash.                                             created by AB
//=============================================================================
class dnWallWaterSplash expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=0.225000
     InitialVelocity=(Z=100.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=50.000000)
     Apex=(Z=-32.000000)
     BounceElasticity=0.250000
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.WaterImpact.waterimpact3dRC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.050000
     EndDrawScale=0.150000
     AlphaVariance=0.250000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     TriggerType=SPT_None
     PulseSeconds=0.001000
     bHidden=True
     bAlwaysVisible=True
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     TimeWarp=0.350000
}
