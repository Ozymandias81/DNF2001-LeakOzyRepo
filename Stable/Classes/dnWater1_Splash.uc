//=============================================================================
// dnWater1_Splash.              created by Allen H. Blum III (c)April 12, 2000
//=============================================================================
class dnWater1_Splash expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=3
     SpawnPeriod=0.000000
     Lifetime=4.000000
     LifetimeVariance=0.500000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Apex=(Z=-128.000000)
     BounceElasticity=0.750000
     DieOnBounce=True
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Water.Rain0001'
     DieOnLastFrame=True
     AlphaStart=0.250000
     AlphaEnd=0.100000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=2.000000
     bHidden=True
     Style=STY_Translucent
     CollisionRadius=64.000000
     CollisionHeight=0.000000
}
