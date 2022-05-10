//=============================================================================
// dnJetski_Torpedo.               Created by Charlie Wiederhold April 20, 2000
//=============================================================================
class dnJetski_Torpedo expands dnJetski;

// Jetski guy torpedo class

#exec OBJ LOAD FILE=..\meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\textures\m_dnweapon.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=None,MountType=MOUNT_Actor,MountMeshItem=None)
     MountOnSpawn(1)=(ActorClass=None,MountType=MOUNT_Actor,MountMeshItem=None)
     MountOnSpawn(2)=(SetMountOrigin=False,MountOrigin=(X=0.000000,Z=0.000000))
     Mesh=DukeMesh'c_dnWeapon.missle_jetski'
     DrawScale=0.750000
}
