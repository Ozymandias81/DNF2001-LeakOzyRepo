//=============================================================================
// dnWallFreezeRay.                                               created by AB
//=============================================================================
class dnWallFreezeRay expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSmoke')
     SpawnPeriod=0.000000
     PrimeTime=0.100000
     Lifetime=2.000000
     RelativeSpawn=True
     InitialVelocity=(X=64.000000,Z=0.000000)
     InitialAcceleration=(Z=700.000000)
     MaxVelocityVariance=(X=128.000000,Y=64.000000,Z=64.000000)
     BounceElasticity=0.250000
     Bounce=True
     ParticlesCollideWithWorld=True
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.iceparticles.iceparticle1aRC'
     Textures(1)=Texture't_generic.iceparticles.iceparticle1bRC'
     Textures(2)=Texture't_generic.iceparticles.iceparticle1cRC'
     DrawScaleVariance=0.040000
     StartDrawScale=0.025000
     EndDrawScale=0.025000
     AlphaEnd=0.000000
     RotationVariance=32768.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.001000
     bHidden=True
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
 	 UpdateWhenNotVisible=true

}
