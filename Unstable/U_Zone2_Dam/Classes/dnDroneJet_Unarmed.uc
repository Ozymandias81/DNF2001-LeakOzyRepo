//=============================================================================
// dnDroneJet_Unarmed.             Created by Charlie Wiederhold April 16, 2000
//=============================================================================
class dnDroneJet_Unarmed expands dnVehicles;

// Normal Drone Jet class
// Does not have any means of attacking
// Uses dnLensFlares, dnDroneJet_EngineFire

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnLensFlares',SetMountOrigin=True,MountOrigin=(X=-166.000000,Y=-80.000000,Z=80.000000))
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnLensFlares',SetMountOrigin=True,MountOrigin=(X=-166.000000,Y=80.000000,Z=80.000000))
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnDroneJet_WingLight2',SetMountOrigin=True,MountOrigin=(X=76.000000,Y=-304.000000,Z=-24.000000))
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnDroneJet_WingLight1',SetMountOrigin=True,MountOrigin=(X=76.000000,Y=304.000000,Z=-24.000000))
     MountOnSpawn(4)=(ActorClass=Class'U_Zone2_Dam.dnDroneJet_EngineFire',SetMountOrigin=True,MountOrigin=(X=-280.000000,Z=-56.000000),SetMountAngles=True,MountAngles=(Yaw=-16384))
     MountOnSpawn(5)=(ActorClass=Class'dnParticles.dnDroneJet_ConTrail',SetMountOrigin=True,MountOrigin=(X=76.000000,Y=-304.000000,Z=-24.000000),SetMountAngles=True,MountAngles=(Yaw=-16384),AppendToTag=ConTrail)
     MountOnSpawn(6)=(ActorClass=Class'dnParticles.dnDroneJet_ConTrail',SetMountOrigin=True,MountOrigin=(X=76.000000,Y=304.000000,Z=-24.000000),SetMountAngles=True,MountAngles=(Yaw=-16384),AppendToTag=ConTrail)
     HealthMarkers(0)=(TriggerEvent=Update_PlanesKilledStatus)
     FallingPhysicsOnDamage=True
     DelayedDamageTime=0.250000
     DelayedDamageAmount=1000
     FragType(0)=None
     NumberFragPieces=0
     DamageOnHitWall=1000
     DamageOnHitWater=1000
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Zone2_Dam.dnDroneJet_BaseGib',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=1024.000000,Y=1024.000000,Z=1024.000000))
     SpawnOnDestroyed(1)=(SpawnClass=Class'U_Zone2_Dam.dnDroneJet_LodgeGib',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=1024.000000,Y=1024.000000,Z=1024.000000))
     SpawnOnDestroyed(2)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_lrtor',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=1024.000000,Y=1024.000000,Z=1024.000000))
     SpawnOnDestroyed(3)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_rrtor',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=1024.000000,Y=1024.000000,Z=1024.000000))
     SpawnOnDestroyed(4)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_rwing',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=1024.000000,Y=1024.000000,Z=1024.000000))
     SpawnOnDestroyed(5)=(SpawnClass=Class'U_Zone2_Dam.dnLargeGibEffect',ChangeMesh=DukeMesh'c_vehicles.drone_pcs_wingw',RotationVariance=(Pitch=16384,Yaw=16384,Roll=16384),VelocityVariance=(X=1024.000000,Y=1024.000000,Z=1024.000000))
     SpawnOnDestroyed(6)=(SpawnClass=Class'dnParticles.dnExplosion2_Spawner1')
     LodMode=LOD_StopMinimum
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     Health=21
     bNotTargetable=True
     CollisionRadius=256.000000
     CollisionHeight=24.000000
     bCollideWorld=False
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_vehicles.drone_jet'
     SoundRadius=255
     SoundVolume=255
     AmbientSound=Sound'a_transport.Airplanes.JetLp01'
}
