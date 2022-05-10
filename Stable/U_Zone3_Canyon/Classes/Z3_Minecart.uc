//=============================================================================
// Z3_Minecart.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Minecart expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=58.000000
     CollisionHeight=30.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.minecart'
}
