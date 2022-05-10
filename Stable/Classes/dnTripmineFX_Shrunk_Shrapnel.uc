//=============================================================================
// dnTripmineFX_Shrunk_Shrapnel.                  June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnTripmineFX_Shrunk_Shrapnel expands dnTripmineFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnTripmineFX_Shrunk_Sparks')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnTripmineFX_Shrunk_Shrapnel_White')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnTripmineFX_Shrunk_Shrapnel_Heavy')
     SpawnNumber=8
     SpawnPeriod=0.070000
     MaximumParticles=24
     Lifetime=2.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=512.000000,Z=384.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
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
     DrawScaleVariance=0.0250000
     StartDrawScale=0.0250000
     EndDrawScale=0.0250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.210000
     TimeWarp=0.750000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Masked
}
