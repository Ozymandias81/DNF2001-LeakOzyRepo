//=============================================================================
// Z2_DCrane_Hook. 						November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_DCrane_Hook expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=25.000000
     CollisionHeight=34.000000
     Mesh=DukeMesh'c_zone2_dam.dcranehook'
}
