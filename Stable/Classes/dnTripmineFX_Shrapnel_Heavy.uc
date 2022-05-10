//=============================================================================
// dnTripmineFX_Shrapnel_Heavy.                   June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnTripmineFX_Shrapnel_Heavy expands dnTripmineFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnNumber=12
     SpawnPeriod=0.070000
     PrimeCount=1
     MaximumParticles=36
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.2100000
     UseZoneGravity=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=2.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=1772.000000,Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=768.000000,Z=768.000000)
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
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
     bIgnoreBList=True
     bUnlit=True
}
