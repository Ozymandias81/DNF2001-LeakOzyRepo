//=============================================================================
// Z2_DCrane_Wheel.						November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_DCrane_Wheel expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=32.000000
     CollisionHeight=30.000000
     Mesh=DukeMesh'c_zone2_dam.dcranewheel'
}
