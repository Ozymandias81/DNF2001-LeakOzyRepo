//=============================================================================
// dnJetski.                       Created by Charlie Wiederhold April 19, 2000
//=============================================================================
class dnJetski expands dnVehicles;

// Jetski guy base class
// Has a mounted torpedo

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'U_Zone2_Dam.dnJetski_Guy',MountType=MOUNT_MeshSurface,MountMeshItem=Mount1)
     MountOnSpawn(1)=(ActorClass=Class'U_Zone2_Dam.dnJetski_Torpedo',MountType=MOUNT_MeshSurface,MountMeshItem=Mount2)
     MountOnSpawn(2)=(SetMountOrigin=True,MountOrigin=(X=-48.000000,Z=32.000000))
     FragType(0)=None
     NumberFragPieces=0
     LodMode=LOD_Disabled
     VisibilityRadius=4096.000000
     VisibilityHeight=2048.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     WaterSplashClass=Class'dnParticles.dnWaterSpray_Effect1'
     Mesh=DukeMesh'c_vehicles.Jetski'
}
