//=============================================================================
// dnWater1_Spray.               created by Allen H. Blum III (c)April 12, 2000
//=============================================================================
class dnWater1_Spray expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=10
     SpawnPeriod=0.000000
     Lifetime=4.000000
     LifetimeVariance=0.500000
     InitialVelocity=(Z=300.000000)
     InitialAcceleration=(Z=512.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=400.000000)
     Apex=(Z=-128.000000)
     BounceElasticity=0.750000
     DieOnBounce=True
     Textures(0)=Texture't_generic.Water.Splash3sah'
     StartDrawScale=2.200000
     EndDrawScale=0.500000
     AlphaStart=0.250000
     AlphaEnd=0.100000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.050000
     bHidden=True
     Style=STY_Translucent
     CollisionRadius=32.000000
     CollisionHeight=0.000000
}
