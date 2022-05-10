//=============================================================================
// dnTripmineFX_Shrapnel.                  June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnTripmineFX_Shrapnel expands dnTripmineFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnTripmineFX_Sparks')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnTripmineFX_Shrapnel_White')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnTripmineFX_Shrapnel_Heavy')
     SpawnNumber=12
     SpawnPeriod=0.070000
     MaximumParticles=36
     Lifetime=2.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=768.000000,Z=512.000000)
     MaxVelocityVariance=(X=768.000000,Y=768.000000,Z=512.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=950.000000
     BounceElasticity=0.100000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.bloodgibs.genbloodgib10RC'
     Textures(1)=Texture't_generic.bloodgibs.genbloodgib6RC'
     Textures(2)=Texture't_generic.bloodgibs.genbloodgib7RC'
     Textures(3)=Texture't_generic.bloodgibs.genbloodgib8RC'
     Textures(4)=Texture't_generic.bloodgibs.genbloodgib9RC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.210000
     TimeWarp=0.750000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
}
