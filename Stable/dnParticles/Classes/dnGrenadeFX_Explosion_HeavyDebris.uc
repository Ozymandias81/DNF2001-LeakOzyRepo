//=============================================================================
// dnGrenadeFX_Explosion_HeavyDebris.                   June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnGrenadeFX_Explosion_HeavyDebris expands dnGrenadeFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=45
     MaximumParticles=45
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=768.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=768.000000)
     LocalFriction=128.000000
     BounceElasticity=0.500000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.metalshards.metalshard1aRC'
     Textures(1)=Texture't_generic.metalshards.metalshard1bRC'
     Textures(2)=Texture't_generic.metalshards.metalshard1cRC'
     Textures(3)=Texture't_generic.metalshards.metalshard1dRC'
     Textures(4)=Texture't_generic.robotgibs.genrobotgib6RC'
     Textures(5)=Texture't_generic.robotgibs.genrobotgib1RC'
     DrawScaleVariance=0.250000
     StartDrawScale=0.200000
     EndDrawScale=0.200000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
     bIgnoreBList=True
}
