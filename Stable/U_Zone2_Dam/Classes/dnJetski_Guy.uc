//=============================================================================
// dnJetski_Guy.                   Created by Charlie Wiederhold April 19, 2000
//=============================================================================
class dnJetski_Guy expands dnJetski;

// Jetski Guy class
// Designed to be mounted to the jetski

#exec OBJ LOAD FILE=..\meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\textures\m_characters.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=None,MountType=MOUNT_Actor,MountMeshItem=None)
     MountOnSpawn(1)=(ActorClass=None,MountType=MOUNT_Actor,MountMeshItem=None)
     MountOnSpawn(2)=(SetMountOrigin=False,MountOrigin=(X=0.000000,Z=0.000000))
     Texture=Texture'm_vehicles.edf_refmap1BC'
     Mesh=DukeMesh'c_characters.jetskidude'
}
