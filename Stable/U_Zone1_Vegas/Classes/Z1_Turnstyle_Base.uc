//=============================================================================
// Z1_Turnstyle_Base. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Turnstyle_Base expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=17.000000
     CollisionHeight=13.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.turnst_base'
}
