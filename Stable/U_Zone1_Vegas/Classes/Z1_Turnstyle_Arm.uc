//=============================================================================
// Z1_Turnstyle_Arm. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Turnstyle_Arm expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=19.000000
     CollisionHeight=27.000000
     Mesh=DukeMesh'c_zone1_vegas.turnst_arm'
}
