//=============================================================================
// Z1_HugeShock_Large. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_HugeShock_Large expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=88.000000
     CollisionHeight=9.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     bMeshLowerByCollision=False
     Mesh=DukeMesh'c_zone1_vegas.hugeshock_large'
}
