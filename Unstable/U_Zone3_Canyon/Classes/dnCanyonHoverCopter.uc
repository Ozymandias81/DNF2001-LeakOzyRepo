//=============================================================================
// dnCanyonHoverCopter. 				   March 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCanyonHoverCopter expands dnVehicles;

#exec OBJ LOAD FILE=..\meshes\c_vehicles.dmx
#exec OBJ LOAD FILE=..\textures\m_vehicles.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnHoverCopter_BlueJets',MountType=MOUNT_MeshSurface,MountMeshItem=Mount1,AppendToTag=Thrust1,TakeParentTag=True)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnHoverCopter_BlueJets',MountType=MOUNT_MeshSurface,MountMeshItem=Mount2,AppendToTag=Thrust2,TakeParentTag=True)
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnDroneJet_WingLight1',SetMountOrigin=True,MountOrigin=(X=120.000000,Y=136.000000,Z=-52.000000))
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnDroneJet_WingLight1',SetMountOrigin=True,MountOrigin=(X=120.000000,Y=-136.000000,Z=-52.000000))
     HealthPrefab=HEALTH_UseHealthVar
     VisibilityRadius=25000.000000
     VisibilityHeight=25000.000000
     Health=5000
     bNotTargetable=True
     CollisionRadius=344.000000
     CollisionHeight=88.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_vehicles.edfhovercopter'
}
