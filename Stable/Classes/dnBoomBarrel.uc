//=============================================================================
// dnBoomBarrel.                              October 20th, 2000 - Stephen Cole
//=============================================================================
class dnBoomBarrel expands dnExplosion1_Spawner1;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

// High radius damage explosion spawned on destruction by G_BoomBarrel
// I wish I was an explosive barrel. Friend to none, waiting for someone to walk by.

defaultproperties
{
     Enabled=True
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Spawner3')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnBoomBarrelFireEffect')
     AdditionalSpawn(2)=(SpawnClass=None)
     MaximumParticles=1
     Lifetime=5.000000
     InitialVelocity=(Z=450.000000)
     InitialAcceleration=(Z=450.000000)
     UseZoneGravity=True
     UseZoneFluidFriction=True
     UseZoneTerminalVelocity=True
     Textures(0)=None
     StartDrawScale=1.000000
     EndDrawScale=1.000000
     DamageAmount=150.000000
     DamageRadius=384.000000
     Style=STY_Normal
     CollisionRadius=19.000000
}
