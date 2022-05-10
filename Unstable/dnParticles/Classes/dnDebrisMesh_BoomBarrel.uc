//=============================================================================
// dnDebrisMesh_BoomBarrel.
//=============================================================================
class dnDebrisMesh_BoomBarrel expands dnDebris;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     PrimeTimeIncrement=0.050000
     MaximumParticles=1
     Lifetime=5.000000
     InitialVelocity=(Z=450.000000)
     InitialAcceleration=(Z=450.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Bounce=True
     DieOnBounce=True
     ParticlesCollideWithWorld=True
     ParticlesCollideWithActors=True
     UseZoneFluidFriction=True
     UseZoneTerminalVelocity=True
     RotationInitial3d=(Pitch=16384,Yaw=16384,Roll=16384)
     RotationVariance3d=(Pitch=16384,Yaw=16384,Roll=16384)
     RotationVelocity3d=(Pitch=16384,Yaw=16384,Roll=16384)
     RotationAcceleration3d=(Pitch=16384,Yaw=16384,Roll=16384)
     DrawType=DT_Mesh
     Style=STY_Masked
     Mesh=DukeMesh'c_generic.Barrel'
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     CollisionRadius=19.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
