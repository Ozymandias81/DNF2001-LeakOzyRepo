//=============================================================================
// dnTripmineFX_Shrunk_Shrapnel_Heavy.                   June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnTripmineFX_Shrunk_Shrapnel_Heavy expands dnTripmineFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnNumber=8
     SpawnPeriod=0.070000
     PrimeCount=1
     MaximumParticles=24
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.2100000
     UseZoneGravity=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     Lifetime=2.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=1024.000000,Z=128.000000)
     MaxVelocityVariance=(X=384.000000,Y=512.000000,Z=512.000000)
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
     DrawScaleVariance=0.10000
     StartDrawScale=0.100000
     EndDrawScale=0.100000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Masked
     bIgnoreBList=True
     bUnlit=True
}
