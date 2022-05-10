/*-----------------------------------------------------------------------------
	M_Hair
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class M_Hair extends MountableDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

defaultproperties
{
     MountType=MOUNT_MeshSurface
     MountMeshItem=hair
     Mesh=DukeMesh'c_characters.hair_long1'
     bShadowCast=False
}
