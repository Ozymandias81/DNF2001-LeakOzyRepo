//=============================================================================
// Z1_MoneyRoom_GoldStack. 				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MoneyRoom_GoldStack expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=13.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.moneyr_goldstac'
}
