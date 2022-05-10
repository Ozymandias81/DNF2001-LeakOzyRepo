//=============================================================================
// Z2_ElectricCoil. 					November 7th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_ElectricCoil expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=59.000000
     CollisionHeight=100.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.electcoil'
}
